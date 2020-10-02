# @summary Send corrective changes to ServiceNOW
#
# @param url URL for API integration
# @param puppet_console URL of the Puppet Console
# @param debug optional flag to activate debugging messages 

class reporting_servicenow (
  Stdlib::Httpsurl $url = 'https://instance.service-now.com/api/now/table/incident',
  Stdlib::Httpsurl $puppet_console = 'https://puppet.example.com',
  Boolean $debug = false
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
    content => epp("${module_name}/${module_name}.yamlepp"),
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
