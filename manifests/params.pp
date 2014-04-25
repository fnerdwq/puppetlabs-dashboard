# Class: dashboard::params
#
# This class configures parameters for the puppet-dashboard module.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class dashboard::params {

  $dashboard_ensure           = 'present'
  $dashboard_user             = 'puppet-dashboard'
  $dashboard_group            = 'puppet-dashboard'
  $dashboard_password         = 'changeme'
  $dashboard_db               = 'dashboard_production'
  $dashboard_charset          = 'utf8'
  $dashboard_environment      = 'production'
  $dashboard_site             = $::fqdn
  $dashboard_port             = '8080'

  $time_zone                  = undef
  $datetime_format            = '%Y-%m-%d %H:%M %Z'
  $enable_read_only_mode      = false
  $no_longer_reporting_cutoff = 3600
  $use_puppet_certificates    = false
  $cn_name                    = 'dashboard'
  $ca_crl_path                = 'certs/dashboard.de.ca_crl.pem'
  $ca_certificate_path        = 'certs/dashboard.de.ca_cert.pem'
  $certificate_path           = 'certs/dashboard.cert.pem'
  $private_key_path           = 'certs/dashboard.private_key.pem'
  $public_key_path            = 'certs/dashboard.public_key.pem'
  $ca_server                  = "puppet.${::domain}"
  $ca_port                    = 8140
  $enable_inventory_service   = false
  $inventory_server           = "puppet.${::domain}"
  $inventory_port             = 8140
  $use_file_bucket_diffs      = false
  $file_bucket_server         =  "puppet.${::domain}"
  $file_bucket_port           = 8140

  $passenger                       = false
  $mysql_root_pw                   = 'changemetoo'
  $rails_base_uri                  = '/'
  $rack_version                    = '1.1.2'

  $cron_optimize                   = false
  $cron_prune_reports              = undef

  $apache_auth                     = false
  $apache_auth_user                = undef
  $apache_auth_password            = undef
  $puppet_server                   = "puppet.${::domain}"

  $apache_ssl                      = false
  $apache_ssl_cert                 = "${::puppet_ssldir}/certs/${::fqdn}.pem"
  $apache_ssl_key                  = "${::puppet_ssldir}/private_keys/${::fqdn}.pem"
  $apache_redirect_to_ssl          = false

  case $::osfamily {

    'RedHat': {
      $dashboard_config       = '/etc/sysconfig/puppet-dashboard'
      $dashboard_service      = ['puppet-dashboard','puppet-dashboard-workers']
      $dashboard_package      = 'puppet-dashboard'
      $dashboard_root         = '/usr/share/puppet-dashboard'
      $apache_user            = 'apache'
    }

    'Debian': {
      $dashboard_config          = '/etc/default/puppet-dashboard'
      $dashboard_service         = 'puppet-dashboard'
      $dashboard_package         = 'puppet-dashboard'
      $dashboard_root            = '/usr/share/puppet-dashboard'
      $dashboard_workers_service = 'puppet-dashboard-workers'
      $dashboard_workers_config  = '/etc/default/puppet-dashboard-workers'
      $dashboard_num_workers     = '4'
      $dashboard_workers_start   = 'yes'
      $mysql_package_provider    = 'aptitude'
      $ruby_mysql_package        = 'libmysql-ruby1.8'
      $apache_user               = 'www-data'
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem: ${::operatingsystem}, module ${module_name} only support osfamily RedHat and Debian")
    }
  }
}

