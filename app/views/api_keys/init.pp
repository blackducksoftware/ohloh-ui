class memcached {
  file { "/etc/memcached.conf":
    owner   => root,
    group   => root,
    mode    => "0644",
    source  => "puppet:///modules/memcached/memcached.conf"
  }

  exec { "apt-get install memcached":
    command => "/usr/bin/apt-get install memcached",
    user => root,
    creates => "/usr/bin/memcached",
    require => File["/etc/memcached.conf"]
  }
}
