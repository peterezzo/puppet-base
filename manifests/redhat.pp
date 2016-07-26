# perform some initial tweaks to redhat systems
# cron_yum_autoremove - run yum autoremove weekly
class base::redhat (
  $cron_yum_autoremove = true,
) {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  # drop a cronjob in to autoremove stale packages on any rpm os
  if $cron_yum_autoremove {
    file { '/etc/cron.weekly/yum_autoremove':
      ensure => present,
      mode   => '0766',
      source => "puppet:///modules/${module_name}/cron-yum_autoremove.sh"
    }
  }
}
