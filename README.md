# fluent-plugin-azuremonitorlog, a plugin for [Fluentd](http://fluentd.org) 
## Overview

[Azure Monitor log](https://docs.microsoft.com/en-us/rest/api/monitor/ActivityLogs/List) input plugin. 

This plugin gets the monitor activity logs from Azure Monitor API to fluentd.

## Installation

To use this plugin, you need to have Azure Service Principal.<br/>
Create an Azure Service Principal through [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli?toc=%2fazure%2fazure-resource-manager%2ftoc.json) or [Azure portal](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal).

Install plugin from RubyGems:
```
$ gem install fluent-plugin-azuremonitorlog
```

## Configuration

```config
<source>
  @type azuremonitorlog
  tag azuremonitorlog
  tenant_id [Azure_Tenant_ID]
  subscription_id [Azure_Subscription_Id]
  client_id [Azure_Client_Id]
  client_secret [Azure_Client_Secret]
  
  select [selected fields to query]
  filter [filter the query query] (default: eventChannels eq 'Admin, Operation')
  interval [interval in seconds] (default: 300)
  api_version [api version] (default: 2015-04-01)
</source>
```

Documentation for select and filter can be found [here](https://docs.microsoft.com/en-us/rest/api/monitor/ActivityLogs/List#activitylogs_list_uri_parameters)

### Example for source config

```config
<source>
    @type azuremonitorlog
    tag azuremonitorlog
    tenant_id [Azure_Tenant_ID]
    subscription_id [Azure_Subscription_Id]
    client_id [Azure_Client_Id]
    client_secret [Azure_Client_Secret]
    select_filter eventName,id,resourceGroupName,resourceProviderName,operationName,status,eventTimestamp,correlationId,submissionTimestamp,level
</source>

```
Start fluentd:

```
$ fluentd -c ./fluentd.conf
```

output example: 
```
{
	"correlationId": "00000000-0000-0000-0000-000000000000",
	"eventName": {
		"value": "EndRequest",
		"localizedValue": "End request"
	},
	"id": "/subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/myresourcegroup/events/00000000-0000-0000-0000-000000000000/ticks/636444295616045190",
	"resourceGroupName": "myresourcegroup",
	"resourceProviderName": {
		"value": "Microsoft.Resources",
		"localizedValue": "Microsoft Resources"
	},
	"operationName": {
		"value": "Microsoft.Resources/subscriptions/resourcegroups/write",
		"localizedValue": "Update resource group"
	},
	"status": {
		"value": "Succeeded",
		"localizedValue": "Succeeded"
	},
	"eventTimestamp": "2017-10-24T08:12:41.604519Z"
}
```

## Test

Run tests:

```
$ rake test
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
