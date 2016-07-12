# configure proxy settings
class base::proxy (
  $profile_proxy_vars = "${module_name}::profile_proxy_vars",
  $sudo_env_keep = "${module_name}::sudo_env_keep"
) {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if ($::kernel == 'windows') {
    fail("The ${name} module is not supported on an ${::osfamily} based system.")
  }

  # set our proxy badly
  if profile_proxy_vars {
    file { '/etc/profile.d/proxy.sh':
      ensure => present,
      source => "puppet:///modules/${module_name}/profile-proxy_vars.sh"
    }
  }

  # keep proxy variables within sudo
  if sudo_env_keep {
    file { '/etc/sudoers.d/env_keep':
      ensure => present,
      mode   => '0440',
      source => "puppet:///modules/${module_name}/sudoers-env_keep"
    }
  }
}