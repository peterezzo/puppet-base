# base::admin_user class builds the common admin user for the domain
# right now ONLY supports ONE user (at least cleanly)
# authentication can be by password or by ssh only, or both
# sudo will be password enforced if a password is provided
# usually inherited from base
class base::admin_user (
  $remove_default_users = true,
  $username = false,
  $password = false,
  $ssh_key = false,
  $ssh_key_type = false
) {
  if $username {
  # only support RHEL-clones and Ubuntu LTS at the moment
  case $::osfamily {
    'Debian': {
      # wtf ubuntu why so many?
      $groups = [ 'adm', 'sudo', 'dialout', 'cdrom', 'floppy', 'audio', 'dip', 'video', 'plugdev', 'netdev' ]
    }
    'RedHat': {
      $groups = [ 'adm', 'wheel', 'systemd-journal' ]
    }
    default: {
      fail("The ${module_name} module is not supported on an ${::osfamily} based system.")
    }
  }

  # if password is not provided use no password (cloud instances, public github repo, etc)
  if $password == false {
    user { $username:
      ensure     => 'present',
      name       => $username,
      managehome => true,
      groups     => $groups,
      shell      => '/bin/bash',
    }
    $sudoer = 'NOPASSWD:ALL'
  } else {
    user { $username:
      ensure     => 'present',
      name       => $username,
      managehome => true,
      groups     => $groups,
      shell      => '/bin/bash',
      password   => $password,
    }
    $sudoer = 'ALL'
  }

  # add a sudoers file since wheel expects password normally
  file { "/etc/sudoers.d/${username}-nopasswd":
    ensure  => 'present',
    content => "${username} ALL=(ALL) ${sudoer}\n",
    mode    => '0440',
    require => User[$username],
  }

  # drop a key in if we have one defined
  if (ssh_key != false) and (ssh_key_type != false) {
    ssh_authorized_key { $username:
      user    => $username,
      type    => $ssh_key_type,
      key     => $ssh_key,
      require => User[$username],
    }
  }

  if $remove_default_users {
    $builtins = [ 'centos', 'ubuntu' ]
    user { $builtins:
      ensure     => 'absent',
      managehome => true,
    }
  }
}
}
