# base class should be run on every node in domain
# hiera_hash collapses definitions from all levels of hiera so packages can be
# defined at node/OS/role/common outside of modules and installed all at once
# it also has optional hooks (all off by default, turn on in hiera)
# create_admin_user - define admin user and remove defaults (on in common.yaml)
# configure_dns - control resolv.conf files for dns (on in common.yaml)
# configure_proxy - set a proxy via shell variables
# cron_apt_autoremove - run apt-get autoremove weekly (on in Ubuntu.yaml)
# cron_puppet_apply - run git pull & puppet apply hourly (off by default)
# ubuntu_clean_motd - remove landscape bits from Ubuntu's motd (on in Ubuntu.yaml)
class base (
  $create_admin_user   = false,
  $configure_dns       = false,
  $configure_proxy     = false,
  $cron_apt_autoremove = false,
  $cron_puppet_apply   = false,
  $ubuntu_clean_motd   = false,
) {
  # the submodules are all required by base as they are essential functions
  # we must have working dns, proxy, etc before more advanced configurations
  if $create_admin_user {require base::admin_user}
  if $configure_dns {require base::dns}
  if $configure_proxy {require base::proxy}

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
  $shellvars = hiera_hash("${module_name}::shellvars",{})
  create_resources(shellvar, $shellvars)

  # drop a cronjob in to autoremove stale packages
  if $cron_apt_autoremove {
    file { '/etc/cron.weekly/apt_autoremove':
      ensure => present,
      mode   => '0766',
      source => "puppet:///modules/${module_name}/cron-apt_autoremove.sh"
    }
  }

  # for agentless setups use a cronjob each hour to sync and apply
  if $cron_puppet_apply {
    file { '/etc/cron.hourly/puppet_apply':
      ensure => present,
      mode   => '0766',
      source => "puppet:///modules/${module_name}/cron-puppet_apply.sh"
    }
  }

  # turn off the landscape bits in motd, specific to ubuntu
  if $::operatingsystem == 'Ubuntu' and $ubuntu_clean_motd {
    file { '/etc/update-motd.d/10-help-text':
      ensure => absent,
    }

    package { 'landscape-common':
      ensure => present,
      before => File['/etc/landscape/client.conf'],
    }
    file { '/etc/landscape/client.conf':
      ensure => present,
      owner  => 'landscape',
      group  => 'landscape',
      source => "puppet:///modules/${module_name}/ubuntu-client.conf"
    }
  }
}
