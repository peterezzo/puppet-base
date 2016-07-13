# configure proxy settings
# http_proxy = url with proto and port (http://host:port) of http proxy
# https_proxy = url with proto and port of https proxy
# ftp_proxy = url with proto and port of ftp proxy
# no proxy = array of domains to not proxy (example.com, etc.com)
# configure_apt = setup apt proxy configuration
# configure_profile = setup global environment vars for proxy
# configure_sudo = add proxy vars to env_keep (all applicable)
class base::proxy (
  $http_proxy        = false,
  $https_proxy       = false,
  $ftp_proxy         = false,
  $no_proxy          = false,
  $configure_apt     = false,
  $configure_profile = true,
  $configure_sudo    = true
) {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $::kernel == 'windows' {
    fail("The ${name} module is not supported on an ${::osfamily} based system.")
  }

  if $http_proxy or $https_proxy or $ftp_proxy {
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

    # off by default as you can also use apt class for this
    if $configure_apt {
      file { '/etc/apt.conf.d/01proxy':
        ensure  => present,
        content => template("${module_name}/proxy_vars-apt.erb")
      }
    }
  } else {
    fail("${name} called without any proxy variables set")
  }
}
