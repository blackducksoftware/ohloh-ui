class nginx {
  file { "/etc/nginx":
    owner   => root,
    group   => root,
    mode    => "0644",
    ensure  => "directory"
  }

  exec { "apt-get nginx":
    command => "/usr/bin/apt-get -y install nginx-full",
    creates => "/usr/sbin/nginx",
    user => root,
    require => File["/etc/nginx"]
  }
}
