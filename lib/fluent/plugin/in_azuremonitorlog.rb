require 'fluent/input'
require 'azure_mgmt_monitor'
require 'uri'

class Fluent::AzureMonitorLogInput < Fluent::Input
  Fluent::Plugin.register_input("azuremonitorlog", self)

  # To support log_level option implemented by Fluentd v0.10.43
  unless method_defined?(:log)
    define_method("log") { $log }
  end

  # Define `router` method of v0.12 to support v0.10 or earlier
  unless method_defined?(:router)
    define_method("router") { Fluent::Engine }
  end

  config_param :tag,                :string
  config_param :tenant_id,          :string, :default => nil
  config_param :subscription_id,    :string, :default => nil
  config_param :client_id,          :string, :default => nil
  config_param :client_secret,      :string, :default => nil, :secret => true

  config_param :select,             :string, :default => nil
  config_param :filter,             :string, :default => "eventChannels eq 'Admin, Operation'"
  config_param :interval,           :integer,:default => 300
  config_param :api_version,        :string, :default => '2015-04-01'
  def initialize
    super
  end

  def configure(conf)
    super

    provider = MsRestAzure::ApplicationTokenProvider.new(@tenant_id, @client_id, @client_secret)
    credentials = MsRest::TokenCredentials.new(provider)
    @client = Azure::ARM::Monitor::MonitorManagementClient.new(credentials);
    @client.subscription_id = @subscription_id
  end

  def start
    super
    @watcher = Thread.new(&method(:watch))
  end

  def shutdown
    super
    @watcher.terminate
    @watcher.join
  end

  def set_query_options(filter, custom_headers)
    fail ArgumentError, 'path is nil' if @client.subscription_id.nil?

    request_headers = {}

    # Set Headers
    request_headers['x-ms-client-request-id'] = SecureRandom.uuid
    request_headers['accept-language'] = @client.accept_language unless @client.accept_language.nil?

    {
        middlewares: [[MsRest::RetryPolicyMiddleware, times: 3, retry: 0.02], [:cookie_jar]],
        path_params: {'subscriptionId' => @client.subscription_id},
        query_params: {'api-version' => @api_version, '$filter' => filter, '$select' => @select},
        headers: request_headers.merge(custom_headers || {}),
        base_url: @client.base_url
    }
  end

  private

  def watch
    while true
        log.debug "azure monitorlog: watch thread starting"
        output
        sleep @interval
    end
  end

  def output
      start_time = Time.now - @interval
      end_time = Time.now
      
      log.debug "start time: #{start_time}, end time: #{end_time}"
      filter = "eventTimestamp ge '#{start_time}' and eventTimestamp le '#{end_time}'"

      if !@filter.empty?
        filter += " and #{@filter}"
      end

      monitor_logs_promise = get_monitor_log_async(filter)
      monitor_logs = monitor_logs_promise.value!

      if !monitor_logs.body['value'].nil? and  monitor_logs.body['value'].any?
        monitor_logs.body['value'].each {|val|
          router.emit(@tag, Time.now.to_i, val)
        }
      else
        log.debug "empty"
      end
  end

  def get_monitor_log_async(filter = nil, custom_headers = nil)
    options = set_query_options(filter, custom_headers)
    path_template = '/subscriptions/{subscriptionId}/providers/microsoft.insights/eventtypes/management/values'
    promise = @client.make_request_async(:get, path_template, options)

    promise = promise.then do |result|
      http_response = result.response
      status_code = http_response.status
      response_content = http_response.body
      unless status_code == 200
        error_model = JSON.load(response_content)
        log.error(error_model['error']['message'])
      end

      result.request_id = http_response['x-ms-request-id'] unless http_response['x-ms-request-id'].nil?
      # Deserialize Response
      if status_code == 200
        begin
          result.body = response_content.to_s.empty? ? nil : JSON.load(response_content)
        rescue Exception => e
          log.error("Error occurred in parsing the response")
        end
      end

      result
    end

    promise.execute
  end
end
