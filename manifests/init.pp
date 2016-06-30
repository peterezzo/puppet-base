class base (
    $os_added_packages,
    $os_removed_packages,
){
    # we like DNS to be managed by puppet
    file { '/etc/resolv.conf':
        ensure => present,
        source => "puppet:///modules/base/resolv.conf",
    }

    # we like to keep proxy env variables for easy sudo
    file {'/etc/sudoers.d/proxy':
        ensure => present,
        mode   => 0440,
        source => "puppet:///modules/base/sudoer-proxy",
    }
    file {'/etc/profile.d/proxy.sh':
        ensure => present,
        source => "puppet:///modules/base/profile-proxy",
    }

    # functions to add or delete packages
    # get these lists from hiera or include
    # use array merging syntax
    # do not execute if arrays are blank
    $hiera_added_packages = hiera_array("${module_name}::os_added_packages",undef)
    $stack_added_packages = $hiera_added_packages ? {
        undef   => $os_added_packages,
        default => $hiera_added_packages,
    }
    if $stack_added_packages {
        package { $stack_added_packages: ensure => "installed" }
    }
    $hiera_removed_packages = hiera_array("${module_name}::os_removed_packages",undef)
    $stack_removed_packages = $hiera_removed_packages ? {
        undef   => $os_removed_packages,
        default => $hiera_removed_packages,
    }
    if $stack_removed_packages {
        package { $stack_removed_packages: ensure => "absent" }
    }

    #notify{ "System hostgroup is $hostgroup":}
}
