# fluent-plugin-azureactivitylog, a plugin for [Fluentd](http://fluentd.org) 
## Overview

***Azure Activity log*** input plugin.

This plugin is simple, it gets the activity logs from Azure Monitor API to fluentd..

## Configuration

```config
<source>
  @type azureactivitylog
  tag azureactivitylog
  tenant_id [Azure_Tenant_ID]
  subscription_id [Azure_Subscription_Id]
  client_id [Azure_Client_Id]
  client_secret [Azure_Client_Secret]
  
  select_filter [selected fields to query]
  event_channels [event channles] (default: Admin, Operation)
  interval [interval in seconds] (default: 300)
</source>
```

### Example for source config

```config
<source>
    @type azureactivitylog
    tag azureactivitylog
    tenant_id [Azure_Tenant_ID]
    subscription_id [Azure_Subscription_Id]
    client_id [Azure_Client_Id]
    client_secret [Azure_Client_Secret]
    select_filter eventName,id,resourceGroupName,resourceProviderName,operationName,status,eventTimestamp,correlationId,submissionTimestamp,level
</source>

```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
