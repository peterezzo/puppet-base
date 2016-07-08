# base::admin_user class builds the common admin user for the domain
# right now ONLY supports ONE user (at least cleanly)
# this requires the name, ssh-key-type, and ssh_key to be explicitly set in hiera
# does not set a password for user, but this can changed
# inherited from base by default
class base::admin_user (
  $remove_default_users = true,
  $user_has_password    = false
) {

  $username = hiera("${module_name}::admin_user::username")
  $ssh_key_type = hiera("${module_name}::admin_user::ssh-key-type")
  $ssh_key = hiera("${module_name}::admin_user::ssh-key")

  # i only use RHEL-clones and Ubuntu LTS at the moment
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

  if $user_has_password {
    # define user with password, get it from hiera now
    # sudo wheel default uses password
    $password = hiera("${module_name}::admin_user::password")
    user { $username:
      ensure     => 'present',
      name       => $username,
      managehome => true,
      password   => $password,
      groups     => $groups,
      shell      => '/bin/bash',
    }
  } else {
    # define user without the password
    user { $username:
      ensure     => 'present',
      name       => $username,
      managehome => true,
      groups     => $groups,
      shell      => '/bin/bash',
    }

    # add a sudoers file since wheel expects password normally
    file { "/etc/sudoers.d/${username}-nopasswd":
      ensure  => 'present',
      content => "${username} ALL=(ALL) NOPASSWD:ALL\n",
      mode    => '0440',
    }
  }

  ssh_authorized_key { $username:
    user    => $username,
    type    => $ssh_key_type,
    key     => $ssh_key,
    require => User[$username]
  }

  if $remove_default_users {
    $builtins = [ 'centos', 'ubuntu' ]
    user { $builtins:
      ensure     => 'absent',
      managehome => true,
    }
  }
}