# reporting_servicenow

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with reporting_servicenow](#setup)
    * [What reporting_servicenow affects](#what-reporting_servicenow-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with reporting_servicenow](#beginning-with-reporting_servicenow)
1. [Usage - Configuration options and additional functionality](#usage)

## Description

reporting_servicenow uses the Puppet Reporting API to open new incidents in ServiceNow if
there have been corrective changes.

## Setup

### What reporting_servicenow affects

On the Puppet Master, this module:

* Adds configuration to /etc/puppetlabs/puppet/puppet.conf
* Creates the configuration file /etc/puppetlabs/puppet/reporting_servicenow.yaml
* Adds a ruby plugin to commuincate with the ServiceNow API
* Create the log file /var/log/puppetlabs/puppetserver/reporting_servicenow.log

### Setup Requirements

reporting_servicenow requires the rest-client gem.  This will be installed as part of the class, along
with the supporting libraries and compilers need to build it.

### Beginning with reporting_servicenow

There are 4 steps to the reporting_servicenow configuration:

* declare the reporting_servicenow class in a manifest:

```puppet
class { 'reporting_servicenow':
  username               => 'your user',
  password               => 'eyaml encrypted password',
  url                    => 'https://<YOUR SERVICENOW INSTANCE HERE>/api/now/table/incident',
  puppet_console         => 'https://<YOUR CONSOLE HERE>',
  caller_id              => '7816f79cc0a8017511c5a33be04be441',
  auto_resolve_incidents => true
  incident_state         => 6
}
```

* run puppet - This will create the file /etc/puppetlabs/puppet/reporting_servicenow.yaml with content similar to this:

```yaml
---
api_url: "https://<YOUR SERVICENOW INSTANCE HERE>/api/now/table/incident"
console_url: "https://<YOUR CONSOLE HERE>"
debug: false
category: 'software'
subcategory: 'Operating System'
caller_id: '7816f79cc0a8017511c5a33be04be441'
auto_resolve_incidents: true
incident_state: 6
# add servicenow username and password below
username: 'your user'
password: 'Eyaml decrypted password'
```

* Edit /etc/puppetlabs/puppet/reporting_servicenow.yaml. (**NOTE: this file is only created once by puppet and then not
  changed back on subsequent puppet runs.)
  Add the ServiceNow username and password:

```yaml
---
api_url: "https://<YOUR SERVICENOW INSTANCE HERE>/api/now/table/incident"
console_url: "https://<YOUR CONSOLE HERE>"
debug: false
category: 'software'
subcategory: 'Operating System'
caller_id: '7816f79cc0a8017511c5a33be04be441'
auto_resolve_incidents: true
incident_state: 6
# add servicenow username and password below
username: 'your user'
password: 'Eyaml decrypted password'
```

* restart the puppetserver service:

```bash
systemctl restart pe-puppetserver
```

## Usage

Once set up, there is nothing more to do. Corrective changes will be reported to ServiceNow and a simple log entry containing the node, environment and ServiceNow Change Request will be added to /var/log/puppetlabs/puppetserver/reporting_servicenow.log.

```bash
[2017-10-07T18:17:26Z]: Puppet run on ip-172-31-32-95.us-west-2.compute.internal resulted in a status of changed (corrective) in the production environment
[2017-10-07T18:17:26Z]: ServiceNow Change CHG0010009 was created on 2017-10-07 18:17:26
```

There is also debugging log option that can be turned on which will add debug messages to /var/log/puppetlabs/puppetserver/reporting_servicenow.log.
Set ```debug: true``` in /etc/puppetlabs/puppet/reporting_servicenow.yaml and restart the puppetserver service.

When there are corrective changes and debgugging is turned on, your log will contain much for info:

```bash
[2017-10-07T18:27:53Z]: DEBUG: msg: Puppet run resulted in a status of 'unchanged'' in the 'production' environment
[2017-10-07T18:30:13Z]: DEBUG: msg: Puppet run resulted in a status of 'changed (corrective)'' in the 'production' environment
[2017-10-07T18:30:13Z]: DEBUG: payload:
-------
{:active=>"false", :category=>"Puppet Corrective Change", :description=>"Puppet run resulted in a status of 'changed (corrective)'' in the 'production' environment", :escalation=>"0", :impact=>"1", :incident_state=>"3", :priority=>"2", :severity=>"1", :short_description=>"Puppet Corrective Change on ip-172-31-32-95.us-west-2.compute.internal", :state=>"7", :sys_created_by=>"Puppet but not Kermit", :urgency=>"1", :work_notes=>"Node Reports: [code]<a class='web' target='_blank' href='https://puppet.aws.aheadaviation.com/#/node_groups/inventory/node/ip-172-31-32-95.us-west-2.compute.internal/reports'>Reports</a>[/code]"}
-----
[2017-10-07T18:30:13Z]: DEBUG: response:
-------
{"result":{"parent":"","made_sla":"true","caused_by":"","watch_list":"","upon_reject":"cancel","sys_updated_on":"2017-10-07 18:30:15","child_incidents":"0","hold_reason":"","approval_history":"","number":"INC0010010","resolved_by":{"link":"https://dev31247.service-now.com/api/now/table/sys_user/6816f79cc0a8016401c5a33be04be441","value":"6816f79cc0a8016401c5a33be04be441"},"sys_updated_by":"admin","opened_by":{"link":"https://dev31247.service-now.com/api/now/table/sys_user/6816f79cc0a8016401c5a33be04be441","value":"6816f79cc0a8016401c5a33be04be441"},"user_input":"","sys_created_on":"2017-10-07 18:30:15","sys_domain":{"link":"https://dev31247.service-now.com/api/now/table/sys_user_group/global","value":"global"},"state":"7","sys_created_by":"admin","knowledge":"false","order":"","calendar_stc":"0","closed_at":"2017-10-07 18:30:15","cmdb_ci":"","delivery_plan":"","impact":"1","active":"false","work_notes_list":"","business_service":"","priority":"1","sys_domain_path":"/","rfc":"","time_worked":"","expected_start":"","opened_at":"2017-10-07 18:30:15","business_duration":"1970-01-01 00:00:00","group_list":"","work_end":"","caller_id":"","resolved_at":"2017-10-07 18:30:15","approval_set":"","subcategory":"","work_notes":"","short_description":"Puppet Corrective Change on ip-172-31-32-95.us-west-2.compute.internal","close_code":"","correlation_display":"","delivery_task":"","work_start":"","assignment_group":"","additional_assignee_list":"","business_stc":"0","description":"Puppet run resulted in a status of 'changed (corrective)'' in the 'production' environment","calendar_duration":"1970-01-01 00:00:00","close_notes":"","notify":"1","sys_class_name":"incident","closed_by":{"link":"https://dev31247.service-now.com/api/now/table/sys_user/6816f79cc0a8016401c5a33be04be441","value":"6816f79cc0a8016401c5a33be04be441"},"follow_up":"","parent_incident":"","sys_id":"6f9e856f4fe503006ad47d218110c704","contact_type":"","incident_state":"7","urgency":"1","problem_id":"","company":"","reassignment_count":"0","activity_due":"","assigned_to":"","severity":"1","comments":"","approval":"not requested","sla_due":"","comments_and_work_notes":"","due_date":"","sys_mod_count":"0","reopen_count":"0","sys_tags":"","escalation":"0","upon_approval":"proceed","correlation_id":"","location":"","category":"inquiry"}}
-----
[2017-10-07T18:30:13Z]: Puppet run on ip-172-31-32-95.us-west-2.compute.internal resulted in a status of changed (corrective) in the production environment
[2017-10-07T18:30:13Z]: ServiceNow Change CHG0010010 was created on 2017-10-07 18:30:15

```

