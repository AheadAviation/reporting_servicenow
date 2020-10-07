require 'spec_helper'
describe 'reporting_servicenow' do
  on_supported_os.each do |_os, os_facts|
    context 'with default values for all parameters' do
      let(:pre_condition) do
        <<-EOF
        # mock pe_in_setting
        define pe_ini_setting (
          $ensure,
          $path,
          $section,
          $setting,
          $value,
        ) { }

        # mock pe_ini_subsetting
        define pe_ini_subsetting (
          $ensure,
          $path,
          $section,
          $setting,
          $subsetting,
          $subsetting_separator,
        ) { }

        service { 'pe-puppetserver':
        }
        EOF
      end
      let(:facts) do
        os_facts.merge(
          'path' => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/puppetlabs/bin:/root/bin',
        )
      end
      
      it {
        is_expected.to compile

        is_expected.to contain_pe_ini_setting('reporting_servicenow_enable_reports')
          .with(
            'ensure'  => 'present',
            'path'    => '/dev/null/puppet.conf',
            'section' => 'agent',
            'setting' => 'report',
            'value'   => true,
          )

        is_expected.to contain_pe_ini_subsetting('reporting_servicenow_report_handler')
          .with(
            'ensure'               => 'present',
            'path'                 => '/dev/null/puppet.conf',
            'section'              => 'master',
            'setting'              => 'reports',
            'subsetting'           => 'reporting_servicenow',
            'subsetting_separator' => ',',
          )
          .that_notifies('Service[pe-puppetserver]')

        is_expected.to contain_file('/dev/null/reporting_servicenow.yaml')
          .with(
            'ensure'  => 'present',
            'owner'   => 'pe-puppet',
            'group'   => 'pe-puppet',
            'mode'    => '0644',
            'replace' => false,
          )
          .with_content(%r{api_url: https://instance.service-now.com/api/now/table/incident})
          .with_content(%r{username: admin})
          .with_content(%r{console_url: https://puppet.example.com})
          .with_content(%r{debug: false})
          .with_content(%r{category: software})
          .with_content(%r{subcategory: Operating System})
          .with_content(%r{caller_id: 7816f79cc0a8017511c5a33be04be441})
          .with_content(%r{assignment_group: Service Desk})

        is_expected.to contain_package('gcc')
          .with(
            'ensure' => 'present',
          )
        is_expected.to contain_package('gcc-c++')
          .with(
            'ensure' => 'present',
          )
        is_expected.to contain_package('libstdc++')
          .with(
            'ensure' => 'present',
          )
        is_expected.to contain_package('make')
          .with(
            'ensure' => 'present',
          )
        is_expected.to contain_package('rest-client-server')
          .with(
            'ensure'   => '2.1.0',
            'name'     => 'rest-client',
            'provider' => 'puppetserver_gem',
          )
          .that_notifies(['Exec[reset-gem-perms]', 'Service[pe-puppetserver]'])

        is_expected.to contain_exec('reset-gem-perms')
          .with(
            'path'        => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/puppetlabs/bin:/root/bin',
            'command'     => 'find /opt/puppetlabs/puppet/lib/ruby/gems/ -type d -exec chmod a+rx {} \; ; find /opt/puppetlabs/puppet/lib/ruby/gems/ -type f -exec chmod a+r {} \; ; chmod a+rx /opt/puppetlabs/puppet/bin/*', # lint:ignore:140chars
            'refreshonly' => true,
            'logoutput'   => true,
          )
      }
    end
  end
end
