require 'helper'

class AzureActivityLogInputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  ### for activity log
  CONFIG_ACTIVITY_LOG = %[
    tag azureactivitylog
    tenant_id test_tenant_id
    subscription_id test_subscription_id
    client_id test_client_id
    client_secret test_client_secret
    select_filter eventName,id,resourceGroupName,resourceProviderName,operationName,status,eventTimestamp,correlationId
    event_channels test_event_channels
    interval 300
  ]

  def create_driver_activity_log(conf = CONFIG_ACTIVITY_LOG)
    Fluent::Test::InputTestDriver.new(Fluent::AzureActivityLogInput).configure(conf)
  end

  def test_configure_activity_log
    d = create_driver_activity_log
    assert_equal 'azureactivitylog', d.instance.tag
    assert_equal 'test_tenant_id', d.instance.tenant_id
    assert_equal 'test_subscription_id', d.instance.subscription_id
    assert_equal 'test_client_id', d.instance.client_id
    assert_equal 'test_client_secret', d.instance.client_secret
    assert_equal 'eventName,id,resourceGroupName,resourceProviderName,operationName,status,eventTimestamp,correlationId', d.instance.select_filter
    assert_equal 'test_event_channels', d.instance.event_channels
    assert_equal 300, d.instance.interval
  end

end
