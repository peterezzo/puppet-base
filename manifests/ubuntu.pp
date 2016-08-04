# perform some initial tweaks to debian/ubuntu systems
# cron_apt_autoremove - run apt-get autoremove weekly
# ubuntu_clean_motd - remove landscape bits from Ubuntu's motd
class base::ubuntu (
  $cron_apt_autoremove = true,
  $ubuntu_clean_motd   = true
) {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  # drop a cronjob in to autoremove stale packages on any deb os
  if $cron_apt_autoremove {
    file { '/etc/cron.weekly/apt_autoremove':
      ensure => present,
      mode   => '0766',
      source => "puppet:///modules/${module_name}/cron-apt_autoremove.sh"
    }
  }

  # turn off the landscape bits in motd, specific to ubuntu
  if $::operatingsystem == 'Ubuntu' and $ubuntu_clean_motd {
    file { '/etc/update-motd.d/10-help-text':
      ensure => absent,
    }

    # landscape-common populates /etc/landscape and is required for some reason
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
