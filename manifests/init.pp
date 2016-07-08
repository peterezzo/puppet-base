# base class should be run on every node in domain
# hiera_hash collapses definitions from all levels of hiera so packages can be
# defined at node/OS/role/common outside of modules and installed all at once
# it also has optional hooks (all off by default, turn on in hiera)
# resolvconf - control resolv.conf files for dns (on in common.yaml) TODO: hiera
# create_admin_user - define admin user and remove defaults (on in common.yaml)
# profile_proxy_vars - set a proxy via shell variables TODO: hiera
# sudo_env_keep - keep proxy variables when executing sudo (off by default)
# cron_apt_autoremove - run apt-get autoremove weekly (on in Ubuntu.yaml)
# cron_puppet_apply - run git pull & puppet apply hourly (off by default)
class base (
  $resolvconf          = false,
  $create_admin_user   = false,
  $profile_proxy_vars  = false,
  $sudo_env_keep       = false,
  $cron_apt_autoremove = false,
  $cron_puppet_apply   = false,
) {
  # start off by making admin user before anything else if wanted
  if $create_admin_user {
    require base::admin_user
  }

  # install/remove packages
  # install if not otherwise advised
  $packages = hiera_hash("${module_name}::packages",{})
  $defaults = { 'ensure' => 'installed' }
  create_resources(package, $packages, $defaults)

  # control running/bootup status of services
  $services = hiera_hash("${module_name}::services",{})
  create_resources(service, $services)

  # create/delete basic files
  $files = hiera_hash("${module_name}::files",{})
  create_resources(file, $files)

  # create/delete regular users
  # see base::admin_user for admins
  $users = hiera_hash("${module_name}::users",{})
  create_resources(user, $users)

  # create/delete basic env variables
  # someday

  # we like DNS to be managed by puppet
  if resolvconf {
    file { '/etc/resolv.conf':
      ensure => present,
      source => "puppet:///modules/${module_name}/resolv.conf"
    }
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

  # drop a cronjob in to autoremove stale packages
  if cron_apt_autoremove {
    file { '/etc/cron.weekly/apt_autoremove':
      ensure => present,
      mode   => '0766',
      source => "puppet:///modules/${module_name}/cron-apt_autoremove.sh"
    }
  }

  # drop a cronjob in to refresh our config hourly
  if cron_puppet_apply {
    file { '/etc/cron.hourly/puppet_apply':
      ensure => present,
      mode   => '0766',
      source => "puppet:///modules/${module_name}/cron-puppet_apply.sh"
    }
  }
}