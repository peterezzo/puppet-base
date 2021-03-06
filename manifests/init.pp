# base class should be run on every node to map hiera data to reality
# hiera_hash collapses definitions from all levels of hiera so packages can be
# defined at node/OS/role/common outside of modules and installed all at once
# it also has optional hooks (all off by default, turn on in hiera)
# apply_os_tweaks - apply some minor adjustments to certain operating systems
# cron_puppet_apply - run git pull in /etc/puppet and puppet apply hourly
# create_metadata_facts - enable specified metadata from hiera to be written to facts
# puppet_install_path - path to puppet config in git for cron template
class base (
  $apply_os_tweaks       = false,
  $cron_puppet_apply     = false,
  $create_metadata_facts = true,
  $puppet_install_path   = '/etc/puppet',
) {
  # include fact writer by default, needs array of facts sent to do anything
  if $create_metadata_facts {require base::metadata}

  # apply some specific things away from vendor defaults
  if $apply_os_tweaks {
    case $::osfamily {
      'Debian': { include base::ubuntu }
      'RedHat': { include base::redhat }
      default: {}
    }
  }

  # for agentless setups use a cronjob each hour to sync and apply
  if $cron_puppet_apply {
    file { '/etc/cron.hourly/puppet_apply':
      ensure  => present,
      mode    => '0766',
      content => template("${module_name}/cron-puppet_apply_sh.erb")
    }
  }

  # remainder of file are simply wrappers for hiera calls

  $packages = hiera_hash("${module_name}::packages",{})
  $defaults = { 'ensure' => 'installed' }
  create_resources(package, $packages, $defaults)

  $services = hiera_hash("${module_name}::services",{})
  create_resources(service, $services)

  $files = hiera_hash("${module_name}::files",{})
  create_resources(file, $files)

  $users = hiera_hash("${module_name}::users",{})
  create_resources(user, $users)

  $execs = hiera_hash("${module_name}::execs",{})
  create_resources(exec, $execs)

  # the following resources are dependent on herculesteam/augeasproviders

  $shellvars = hiera_hash("${module_name}::shellvars",{})
  create_resources(shellvar, $shellvars)

  $sysctls = hiera_hash("${module_name}::sysctls",{})
  create_resources(sysctl, $sysctls)
}
