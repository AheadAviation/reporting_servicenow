# @summary Send corrective changes to ServiceNOW
#
# A crrective change will result in an incident in ServiceNOW. The incident will be prefilled with
# the data below. If configured, the incident can be closed automatically.
#
# @param username 
#    ServieNow username, must be able to open incidents, defaults to 'admin'
#
# @param password 
#    ServiceNow password for the above user, needs to be eyaml encrypted
#
# @param url 
#    SewrviceNow URL for API integration
#
# @param puppet_console 
#    URL of the Puppet Console
#
# @param debug 
#    optional flag to activate debugging messages 
#
# @param category 
#    ServiceNow incident category, defaults to 'software'
#
# @param subcategory 
#    ServiceNow incident subcategory, defaults to 'Operating System'
#
# @param caller_id 
#    ServiceNow user sys_id for the user to be inserted as caller
#
# @param assignment_group 
#    ServiceNow incident assignment group, defaults to 'Service Desk'
#
# @param auto_resolve_incident
#    Close the incident with incident_state
#
# @param incident_state
#    ServiceNow state for incident close
#
# @example
#   class { 'reporting_servicenow':
#     username       => 'admin',
#     password       => 'EYaml encrypted very secret password',
#     url            => 'https://<YOUR SERVICENOW INSTANCE HERE>/api/now/table/incident',
#     puppet_console => 'https://<YOUR CONSOLE HERE>',
#   }
#   

class reporting_servicenow (
  Sensitive[String] $password,
  String $username                  = 'admin',
  Stdlib::Httpsurl $url             = 'https://instance.service-now.com/api/now/table/incident',
  Stdlib::Httpsurl $puppet_console  = 'https://puppet.example.com',
  Boolean $debug                    = false,
  String $category                  = 'software',
  String $subcategory               = 'Operating System',
  String $caller_id                 = '',
  String $assignment_group          = 'Service Desk',
  Boolean $auto_resolve_incident    = false,
  Integer $incident_state           = 6,
) {
  pe_ini_setting { "${module_name}_enable_reports":
    ensure  => present,
    path    => "${settings::confdir}/puppet.conf",
    section => 'agent',
    setting => 'report',
    value   => true,
  }

  pe_ini_subsetting { "${module_name}_report_handler" :
    ensure               => present,
    path                 => "${settings::confdir}/puppet.conf",
    section              => 'master',
    setting              => 'reports',
    subsetting           => $module_name,
    subsetting_separator => ',',
    notify               => Service['pe-puppetserver'],
  }

  file { "${settings::confdir}/${module_name}.yaml":
    ensure  => present,
    owner   => 'pe-puppet',
    group   => 'pe-puppet',
    mode    => '0644',
    replace => false,
    content => epp("${module_name}/${module_name}.yaml"),
  }

  # Needed to compile rest-client
  package { ['gcc', 'gcc-c++', 'libstdc++', 'make']:
    ensure => present,
  }

  # Needed to post data to the API
  package { 'rest-client':
    ensure   => '2.1.0',
    provider => 'puppet_gem',
    notify   => [Exec['reset-gem-perms'],Service[ 'pe-puppetserver' ]],
  }

  package { 'rest-client-server':
    ensure   => '2.1.0',
    name     => 'rest-client',
    provider => 'puppetserver_gem',
    notify   => [Exec['reset-gem-perms'],Service[ 'pe-puppetserver' ]],
  }

  # Permissions are often left with 600 so this will fix them
  exec { 'reset-gem-perms':
    path        => $facts['path'],
    command     => 'find /opt/puppetlabs/puppet/lib/ruby/gems/ -type d -exec chmod a+rx {} \; ; find /opt/puppetlabs/puppet/lib/ruby/gems/ -type f -exec chmod a+r {} \; ; chmod a+rx /opt/puppetlabs/puppet/bin/*',  #lint:ignore:140chars
    refreshonly => true,
    logoutput   => true,
  }

}
