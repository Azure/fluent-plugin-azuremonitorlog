require 'helper'

class AzureMonitorLogInputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  ### for monitor log
  CONFIG_MONITOR_LOG = %[
    tag azuremonitorlog
    tenant_id test_tenant_id
    subscription_id test_subscription_id
    client_id test_client_id
    client_secret test_client_secret
    select eventName,id,resourceGroupName,resourceProviderName,operationName,status,eventTimestamp,correlationId
    filter eventChannels eq 'Admin, Operation'
    interval 300
    api_version 2015-04-01
  ]

  def create_driver_monitor_log(conf = CONFIG_MONITOR_LOG)
    Fluent::Test::InputTestDriver.new(Fluent::AzureMonitorLogInput).configure(conf)
  end

  def test_configure_monitor_log
    d = create_driver_monitor_log
    assert_equal 'azuremonitorlog', d.instance.tag
    assert_equal 'test_tenant_id', d.instance.tenant_id
    assert_equal 'test_subscription_id', d.instance.subscription_id
    assert_equal 'test_client_id', d.instance.client_id
    assert_equal 'test_client_secret', d.instance.client_secret
    assert_equal 'eventName,id,resourceGroupName,resourceProviderName,operationName,status,eventTimestamp,correlationId', d.instance.select
    assert_equal 'eventChannels eq \'Admin, Operation\'', d.instance.filter
    assert_equal 300, d.instance.interval
    assert_equal '2015-04-01', d.instance.api_version
  end

  def test_set_query_options
    d = create_driver_monitor_log
    query_options = d.instance.set_query_options(d.instance.filter, {})
    assert_equal '2015-04-01', query_options[:query_params]['api-version']
    assert_equal 'eventChannels eq \'Admin, Operation\'', query_options[:query_params]['$filter']
    assert_equal 'eventName,id,resourceGroupName,resourceProviderName,operationName,status,eventTimestamp,correlationId', query_options[:query_params]['$select']
  end

end
