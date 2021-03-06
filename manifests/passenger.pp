# Class: dashboard::passenger
#
# This class configures parameters for the puppet-dashboard module.
#
# Parameters:
#   [*passenger_install*]
#     - Install passenger using puppetlabs/passenger module or assume it is
#       installed by 3rd party
#   [*dashboard_site*]
#     - The ServerName setting for Apache
#
#   [*dashboard_port*]
#     - The port on which puppet-dashboard should run
#
#   [*dashboard_config*]
#     - The Dashboard configuration file
#
#   [*dashboard_root*]
#     - The path to the Puppet Dashboard library
#
#   [*rails_base_uri*]
#     - The base URI for the application
#
#   [*apache_auth*]
#     - Should we do no/false, files or ldap auth?
#
#   [*apache_auth_user*]
#     - User for basic auth.
#
#   [*apache_auth_password*]
#     - Password for basic auth user.
#
#   [*apache_auth_require*]
#     - Apache auth require string
#
#   [*apache_auth_ldap_binddn*]
#     - LDAP bind DN for Apache
#
#   [*apache_auth_ldap_bindpw*]
#     - LDAP bind PW for Apache
#
#   [*apache_auth_ldap_url*]
#     - Apache URL for LDAP with possible selectors
#
#   [*apache_user*]
#     - The apache system user.
#
#   [*puppet_server*]
#     - The puppet server (which has to connect w/o auth).
#
#   [*apache_ssl*]
#     - Should the site run behind ssl?
#
#   [*apache_ssl_cert*]
#     - The server cert.
#
#   [*apache_ssl_key*]
#     - The server key.
#
#   [*apache_redirect_to_ssl*]
#     - should non https be redirected to https?
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class dashboard::passenger (
  $passenger_install = true,
  $dashboard_site,
  $dashboard_port,
  $dashboard_config,
  $dashboard_root,
  $rails_base_uri,
  $apache_auth,
  $apache_auth_user,
  $apache_auth_password,
  $apache_auth_require,
  $apache_auth_ldap_binddn,
  $apache_auth_ldap_bindpw,
  $apache_auth_ldap_url,
  $apache_user,
  $puppet_server,
  $apache_ssl,
  $apache_ssl_cert,
  $apache_ssl_key,
  $apache_redirect_to_ssl,
) inherits dashboard {

  if $passenger_install {
    require ::passenger
  }
  include apache

  file { '/etc/init.d/puppet-dashboard':
    ensure => absent,
  }

  # in debian, the dashboard workers config sources the main config.
  # so we need to keep it
  if $::osfamily != 'Debian' {
    file { 'dashboard_config':
      ensure => absent,
      path   => $dashboard_config,
    }
  }


  apache::vhost { $dashboard_site:
    port              => $dashboard_port,
    priority          => '50',
    docroot           => "${dashboard_root}/public",
    servername        => $dashboard_site,
    options           => 'None',
    override          => 'AuthConfig',
    error_log         => true,
    access_log        => true,
    access_log_format => 'combined',
    custom_fragment   => "RailsBaseURI ${rails_base_uri}",
  }

  if $apache_auth == 'file' {

    file { "${dashboard_root}/htpasswa":
      owner   => $apache_user,
      group   => $dashboard::dashboard_group,
      mode    => '0660',
      content => "${apache_auth_user}:${apache_auth_password}\n",
    }

    Apache::Vhost <|title == $dashboard_site|> {
      directories       => [
      { path            => '/',
        provider        => 'location',
        order           => 'allow,deny',
        allow           => "from ${puppet_server}",
        auth_name       => 'Puppet Dashboard',
        auth_type       => 'Basic',
        auth_user_file  => "${dashboard_root}/htpasswd",
        auth_require    => 'valid-user',
        custom_fragment => 'Satisfy any',}
      ],
      require +> File["${dashboard_root}/htpasswd"],
    }
  } elsif $apache_auth == 'ldap' {

    include apache::mod::authnz_ldap

    Apache::Vhost <|title == $dashboard_site|> {
      directories           => [
      { path                => '/',
        provider            => 'location',
        order               => 'allow,deny',
        allow               => "from ${puppet_server}",
        auth_name           => 'Puppet Dashboard',
        auth_type           => 'Basic',
        auth_basic_provider => 'ldap',
        auth_require        => $apache_auth_require,
        custom_fragment     => "Satisfy any
    AuthLDAPBindDN \"${apache_auth_ldap_binddn}\"
    AuthLDAPBindPassword \"${apache_auth_ldap_bindpw}\"
    AuthLDAPURL \"${apache_auth_ldap_url}\""
        ,}
      ],
    }

  } else {
    # no auth!
  }

  # enable ssl?
  if $apache_ssl {

    # to reuse puppet certificates
    User <|title == $apache_user|> {
      groups +> ['puppet'],
    }

    Apache::Vhost <|title == $dashboard_site|> {
      ssl      => $apache_ssl,
      ssl_cert => $apache_ssl_cert,
      ssl_key  => $apache_ssl_key,
    }

    if $apache_redirect_to_ssl {
      apache::vhost { "${dashboard_site}_redirect_to_ssl":
        servername => $dashboard_site,
        port       => 80,
        priority   => 50,
        docroot    => "${dashboard_root}/public",
        rewrites   => [{
          rewrite_cond => ['%{HTTPS} off'],
          rewrite_rule => ['(.*) https://%{HTTP_HOST}%{REQUEST_URI} [R,L]']
        }],
      }
    }

  }

}
