class base::ubuntu {
    # clean up some spam in motd and add some more
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
        source => "puppet:///modules/base/ubuntu/client.conf"
    }
}
