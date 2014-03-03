# Class: puppet::dashboard
#
# This class installs and configures parameters for Puppet Dashboard
#
# Parameters:
#   [*dashboard_ensure*]
#     - The value of the ensure parameter for the
#       puppet-dashboard package
#
#   [*dashboard_user*]
#     - Name of the puppet-dashboard database and
#       system user
#
#   [*dashboard_group*]
#     - Name of the puppet-dashboard group
#
#   [*dashboard_password*]
#     - Password for the puppet-dashboard database use
#
#   [*dashboard_db*]
#     - The puppet-dashboard database name
#
#   [*dashboard_environment*]
#     - The environment (production, test) to use.
#
#   [*dashboard_charset*]
#     - Character set for the puppet-dashboard database
#
#   [*dashboard_site*]
#     - The ServerName setting for Apache
#
#   [*dashboard_port*]
#     - The port on which puppet-dashboard should run
#
#   [*time_zone*]
#     - The timezone of the dashboard page
#
#   [*datetime_format*]
#     - The datetime format to use
#       (see http://ruby-doc.org/core/classes/Time.html#M000298)
#
#   [*enable_read_only_mode*]
#     - Disable the UI actions for editing nodes, classes, groups and reports.
#
#   [*no_longer_reporting_cutoff*]
#     - Amount of time in seconds since last report before a node is considered
#       no longer reporting
#
#   [*use_puppet_certificates*]
#     - Should the puppet certificates be reused for inventory/filebucket
#       (copied to $dashboard_root/certs)
#
#   [*cn_name*]
#     - Node name to use when contacting the puppet master.
#       Will be overridden with $::fqdn if $use_puppet_certificates.
#
#   [*ca_crl_path*]
#
#   [*ca_certificate_path*]
#
#   [*certificate_path*]
#     - Will be overridden if $use_puppet_certificates.
#
#   [*private_key_path*]
#     - Will be overridden if $use_puppet_certificates.
#
#   [*public_key_path*]
#
#   [*ca_server*]
#     -  Hostname of the certificate authority.
#
#   [*ca_port*]
#     - Port for the certificate authority.
#
#   [*enable_inventory_service*]
#     - The "inventory service" allows you to connect to a puppet master to
#       retrieve and node facts
#
#   [*inventory_server*]
#     - Hostname of the inventory server.
#
#   [*inventory_port*]
#     - Port for the inventory server.
#
#   [*use_file_bucket_diffs*]
#     - Set this to true to allow Dashboard to display diffs on files that
#       are archived in the file bucket.
#
#   [*file_bucket_server*]
#     - Hostname of the file bucket server.
#
#   [*file_bucket_port*]
#     - Port for the file bucket server.
#
#   [*mysql_root_pw*]
#     - Password for root on MySQL
#
#   [*passenger*]
#     - Boolean to determine whether Dashboard is to be
#       used with Passenger
#
#   [*passenger_install*]
#     - Boolean to determine if we install passenger using
#       puppetlabs/passenger module or assume it is installed by 3rd party
#       If false, vhost will be created with passenger, but passenger puppet
#       module won't be called
#
#   [*dashboard_config*]
#     - The Dashboard configuration file
#
#   [*dashboard_workers_service*]
#     - The Dashboard workers init service
#
#   [*dashboard_workers_config*]
#     - Default config file for the Dashboard workers service
#
#   [*dashboard_num_workers*]
#     - Number of dashboard workers to spawn
#
#   [*dashboard_workers_start*]
#     - Enable the Dashboard init service
#
#   [*dashboard_root*]
#     - The path to the Puppet Dashboard library
#
#   [*rails_base_uri*]
#     - The base URI for the application
#
#   [*rack_version*]
#     - The version of the rack gem to install
#
#   [*cron_optimize*]
#     - Install cronjob to optimze db (rake db:raw:optimize)
#
#   [*cron_prune_reports*]
#     - Install cronjob to prune old reports, format: '<number> <unit>'
#       where unit: min,hr,day,wk,mon,yr
#
# Actions:
#
# Requires:
# Class['mysql']
# Class['mysql::server']
# Apache::Vhost[$dashboard_site]
#
# Sample Usage:
#   class {'dashboard':
#     dashboard_ensure       => 'present',
#     dashboard_user         => 'puppet-dbuser',
#     dashboard_group        => 'puppet-dbgroup',
#     dashboard_password     => 'changemme',
#     dashboard_db           => 'dashboard_prod',
#     dashboard_environment  => 'production',
#     dashboard_charset      => 'utf8',
#     dashboard_site         => $fqdn,
#     dashboard_port         => '8080',
#     mysql_root_pw          => 'REALLY_change_me',
#     passenger              => true,
#     passenger_install      => true
#   }
#
#  Note: SELinux on Redhat needs to be set separately to allow access to the
#   puppet-dashboard.
#
class dashboard (
  $dashboard_ensure           = $dashboard::params::dashboard_ensure,
  $dashboard_user             = $dashboard::params::dashboard_user,
  $dashboard_group            = $dashboard::params::dashboard_group,
  $dashboard_password         = $dashboard::params::dashboard_password,
  $dashboard_db               = $dashboard::params::dashboard_db,
  $dashboard_environment      = $dashboard::params::dashboard_environment,
  $dashboard_charset          = $dashboard::params::dashboard_charset,
  $dashboard_site             = $dashboard::params::dashboard_site,
  $dashboard_port             = $dashboard::params::dashboard_port,
  $dashboard_config           = $dashboard::params::dashboard_config,
  $dashboard_workers_service  = $dashboard::params::dashboard_workers_service,
  $dashboard_workers_config   = $dashboard::params::dashboard_workers_config,
  $dashboard_num_workers      = $dashboard::params::dashboard_num_workers,
  $dashboard_workers_start    = $dashboard::params::dashboard_workers_start,
  $time_zone                  = $dashboard::params::time_zone,
  $datetime_format            = $dashboard::params::datetime_format,
  $enable_read_only_mode      = $dashboard::params::enable_read_only_mode,
  $no_longer_reporting_cutoff = $dashboard::params::no_longer_reporting_cutoff,
  $use_puppet_certificates    = $dashboard::params::use_puppet_certificates,
  $cn_name                    = $dashboard::params::cn_name,
  $ca_crl_path                = $dashboard::params::ca_crl_path,
  $ca_certificate_path        = $dashboard::params::ca_certificate_path,
  $certificate_path           = $dashboard::params::certificate_path,
  $private_key_path           = $dashboard::params::private_key_path,
  $public_key_path            = $dashboard::params::public_key_path,
  $ca_server                  = $dashboard::params::ca_server,
  $ca_port                    = $dashboard::params::ca_port,
  $enable_inventory_service   = $dashboard::params::enable_inventory_service,
  $inventory_server           = $dashboard::params::inventory_server,
  $inventory_port             = $dashboard::params::inventory_port,
  $use_file_bucket_diffs      = $dashboard::params::use_file_bucket_diffs,
  $file_bucket_server         = $dashboard::params::file_bucket_server,
  $file_bucket_port           = $dashboard::params::file_bucket_port,
  $mysql_root_pw              = $dashboard::params::mysql_root_pw,
  $passenger                  = $dashboard::params::passenger,
  $passenger_install          = $dashboard::params::passenger_install,
  $mysql_package_provider     = $dashboard::params::mysql_package_provider,
  $ruby_mysql_package         = $dashboard::params::ruby_mysql_package,
  $dashboard_config           = $dashboard::params::dashboard_config,
  $dashboard_root             = $dashboard::params::dashboard_root,
  $rails_base_uri             = $dashboard::params::rails_base_uri,
  $rack_version               = $dashboard::params::rack_version,
  $cron_optimize              = $dashboard::params::cron_optimize,
  $cron_prune_reports         = $dashboard::params::cron_prune_reports
) inherits dashboard::params {

  class { 'mysql::server':
    root_password => $mysql_root_pw,
  }

  # fixes issue of wrong error.log (default) owner on Debian systems
  if $::osfamily == 'Debian' {
    file {'/var/log/mysql/error.log':
      owner   => 'mysql',
      require => Class['mysql::server'],
    }
  }

  class { 'mysql::bindings':
    ruby_enable => true,
  }

  if $passenger {
    class { 'dashboard::passenger':
      dashboard_site    => $dashboard_site,
      dashboard_port    => $dashboard_port,
      dashboard_config  => $dashboard_config,
      dashboard_root    => $dashboard_root,
      rails_base_uri    => $rails_base_uri,
      passenger_install => $passenger_install,
    }
    # debian needs the configuration files for dashboard to start the
    # dashboard workers
    if $::osfamily == 'Debian' {
      file { 'dashboard_config':
        ensure  => present,
        path    => $dashboard_config,
        content => template("dashboard/config.${::osfamily}.erb"),
        owner   => root,
        group   => root,
        mode    => '0644',
        require => Package[$dashboard::params::dashboard_package],
      }
      file { 'dashboard_workers_config':
        ensure  =>  present,
        path    => $dashboard_workers_config,
        content => template("dashboard/workers.config.${::osfamily}.erb"),
        owner   => root,
        group   => root,
        mode    => '0644',
        require => Package[$dashboard::params::dashboard_package]
      }
      # enable the workers service
      service { $dashboard_workers_service:
        ensure     => running,
        enable     => true,
        hasrestart => true,
        subscribe  => File['/etc/puppet-dashboard/database.yml'],
        require    => Exec['db-migrate']
      }

    }
  } else {
    file { 'dashboard_config':
      ensure  => present,
      path    => $dashboard_config,
      content => template("dashboard/config.${::osfamily}.erb"),
      owner   => root,
      group   => root,
      mode    => '0644',
      require => Package[$dashboard::params::dashboard_package],
    }

    service { $dashboard::params::dashboard_service:
      ensure     => running,
      enable     => true,
      hasrestart => true,
      subscribe  => [ File['/etc/puppet-dashboard/database.yml'],
                      File['/etc/puppet-dashboard/settings.yml'] ],
      require    => Exec['db-migrate']
    }
  }

  # should we reuse the puppet certificates?
  if $use_puppet_certificates {
    $_cn_name          = $::fqdn
    $_private_key_path = "certs/${::fqdn}.private_key.pem"
    $_certificate_path = "certs/${::fqdn}.cert.pem"

    file { "${dashboard_root}/certs":
      ensure => directory,
      mode   => '0644',
      owner  => $dashboard_user,
      group  => $dashboard_group,
    }
    file { "${dashboard_root}/${_private_key_path}":
      ensure => present,
      mode   => '0600',
      owner  => $dashboard_user,
      group  => $dashboard_group,
      source => "${::puppet_ssldir}/private_keys/${::fqdn}.pem",
    }
    file { "${dashboard_root}/${_certificate_path}":
      ensure  => present,
      mode    => '0644',
      owner   => $dashboard_user,
      group   => $dashboard_group,
      source  => "${::puppet_ssldir}/certs/${::fqdn}.pem",
      require => File["${dashboard_root}/${_private_key_path}"],
      before  => File["${dashboard_root}/config/settings.yml"],
    }
  } else {
    $_cn_name          = $cn_name
    $_private_key_path = $private_key_path
    $_certificate_path = $certificate_path
  }

  package { $dashboard::params::dashboard_package:
    ensure  => $dashboard::params::dashboard_version,
    require => [ Package['rdoc'], Package['rack']],
  }

  # Currently, the dashboard requires this specific version
  #  of the rack gem. Using the gem provider by default.
  package { 'rack':
    ensure   => $rack_version,
    provider => 'gem',
  }

  package { ['rake', 'rdoc']:
    ensure   => present,
    provider => 'gem',
  }

  File {
    require => Package[$dashboard::params::dashboard_package],
  }

  file { ["${dashboard_root}/public",
          "${dashboard_root}/tmp",
          "${dashboard_root}/log",
          "${dashboard_root}/spool",
          '/etc/puppet-dashboard']:
    ensure       => directory,
    mode         => '0644',
    owner        => $dashboard_user,
    group        => $dashboard_group,
    recurse      => true,
    recurselimit => '1',
  }

  file {'/etc/puppet-dashboard/database.yml':
    ensure  => present,
    mode    => '0640',
    owner   => $dashboard_user,
    group   => $dashboard_group,
    content => template('dashboard/database.yml.erb'),
  }
  file { "${dashboard_root}/config/database.yml":
    ensure  => 'link',
    mode    => '0640',
    owner   => $dashboard_user,
    group   => $dashboard_group,
    target  => '/etc/puppet-dashboard/database.yml',
    require => File['/etc/puppet-dashboard/database.yml'],
  }

  file {'/etc/puppet-dashboard/settings.yml':
    ensure  => present,
    mode    => '0644',
    owner   => $dashboard_user,
    group   => $dashboard_group,
    content => template('dashboard/settings.yml.erb'),
  }
  file { "${dashboard_root}/config/settings.yml":
    ensure  => 'link',
    mode    => '0644',
    owner   => $dashboard_user,
    group   => $dashboard_group,
    target  => '/etc/puppet-dashboard/settings.yml',
    require => File['/etc/puppet-dashboard/settings.yml'],
  }

  # notify changes if apache service is managed
  if defined(Class['apache::service']) {
    File['/etc/puppet-dashboard/settings.yml'] {
      notify  => Class['apache::service'],
    }
    File["${dashboard_root}/config/settings.yml"] {
      before  => Class['apache::service'],
    }
  }

  file { [ "${dashboard_root}/log/production.log", "${dashboard_root}/config/environment.rb" ]:
    ensure => file,
    mode   => '0644',
    owner  => $dashboard_user,
    group  => $dashboard_group,
  }

  file { '/etc/logrotate.d/puppet-dashboard':
    ensure  => present,
    content => template('dashboard/logrotate.erb'),
    owner   => root,
    group   => root,
    mode    => '0644',
  }

  exec { 'db-migrate':
    command => 'rake RAILS_ENV=production db:migrate',
    cwd     => $dashboard_root,
    path    => '/usr/bin/:/usr/local/bin/',
    creates => "/var/lib/mysql/${dashboard_db}/nodes.frm",
    require => [Package[$dashboard::params::dashboard_package], Mysql::Db[$dashboard_db],
                File["${dashboard_root}/config/database.yml"]],
  }

  mysql::db { $dashboard_db:
    user     => $dashboard_user,
    password => $dashboard_password,
    charset  => $dashboard_charset,
  }

  user { $dashboard_user:
      ensure     => 'present',
      comment    => 'Puppet Dashboard',
      gid        => $dashboard_group,
      shell      => '/bin/false',
      managehome => true,
      home       => "/home/${dashboard_user}",
  }

  group { $dashboard_group:
      ensure => 'present',
  }

  if str2bool($cron_optimize) {
    cron {'dashboard optimize':
      command => "cd ${dashboard_root} && RAILS_ENV=production rake db:raw:optimize 2> /dev/null",
      user    => $dashboard_user,
      hour    => 1,
      minute  => 0,
    }
  }

  if $cron_prune_reports {
    $splitted = split($cron_prune_reports,' ')
    $upto     = $splitted[0]
    $unit     = $splitted[1]

    validate_re($upto, '^\d+$')
    validate_re($unit, ['^min$','^hr$','^day$','^wk$','^mon$','^yr$'])

    cron {'dashboard prune reports':
      command => "cd ${dashboard_root} && RAILS_ENV=production rake reports:prune upto=${upto} unit=${unit} 2> /dev/null",
      user    => $dashboard_user,
      hour    => 1,
      minute  => 5,
    }
  }


}

