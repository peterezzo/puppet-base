# do configuration of resolv.conf and /etc/hosts
# nameservers - array of dns nameservers to configure
# domains - array of domains to search
class base::dns (
  $nameservers = false,
  $domains     = false,
) {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  # configure DNS if this is a nix machine, by horribly bad detection
  if ($::kernel != 'windows') {
    file { '/etc/resolv.conf':
      ensure  => present,
      content => template("${module_name}/resolv_conf.erb")
    }
  } else {
    fail("The ${name} module is not supported on an ${::osfamily} based system.")
  }

  # setup host entries in addition to dns
  $hosts = hiera_hash("${name}::hosts",{})
  create_resources(host, $hosts)
}
