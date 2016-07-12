# do configuration of resolv.conf
class base::dns (
  $configure_dns = "${module_name}::configure_dns",
  $nameservers = false,
  $domain = false
) {


  if $configure_dns {
    file { '/etc/resolv.conf':
      ensure => present,
      content => template("${module_name}/resolv_conf.erb")
    }
  }
}
