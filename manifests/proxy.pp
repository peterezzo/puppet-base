# configure proxy settings
class base::proxy (
  $http_proxy        = false,
  $https_proxy       = false,
  $ftp_proxy         = false,
  $socks_proxy       = false,
  $no_proxy          = false,
  $configure_apt     = true,
  $configure_profile = true,
  $configure_sudo    = true
) {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $::kernel == 'windows' {
    fail("The ${name} module is not supported on an ${::osfamily} based system.")
  }

  if $http_proxy or $https_proxy or $ftp_proxy or $socks_proxy {
    # set basic shell variables through template
    file { '/etc/profile.d/proxy.sh':
      ensure  => present,
      content => template("${module_name}/proxy_vars-profile.erb")
    }

    # keep proxy variables within sudo
    if $configure_sudo {
      file { '/etc/sudoers.d/env_keep':
        ensure => present,
        mode   => '0440',
        source => "puppet:///modules/${module_name}/sudoers-env_keep"
      }
    }

    if $::osfamily == 'Debian' and $configure_apt {
      file { '/etc/apt.conf.d/01proxy':
        ensure  => present,
        content => template("${module_name}/proxy_vars-apt.erb")
      }
    }
  } else {
    fail("${name} called without any proxy variables set")
  }
}
