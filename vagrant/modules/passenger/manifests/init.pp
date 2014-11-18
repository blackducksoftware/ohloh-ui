class passenger {
  file { [ "/var/local", "/var/local/config"]:
    owner   => root,
    group   => root,
    mode    => "0644",
    ensure  => "directory"
  }

  file { [ "/var/local/openhub", "/var/local/openhub/releases",
           "/var/local/openhub/shared", "/var/local/openhub/shared/log",
           "/var/local/openhub/shared/pids"]:
    owner   => $app_user_name,
    group   => $app_user_name,
    mode    => "0644",
    ensure  => "directory",
    require => File["/var/local/config"]
  }

  file { "/var/local/openhub/current":
     ensure => "link",
     target => $app_mount_point,
     require => File["/var/local/openhub"]
  }

  file { "/var/local/config/nginx_passenger_common.inc":
    owner   => root,
    group   => root,
    mode    => "0644",
    content => template("passenger/nginx_passenger_common.inc.erb"),
    require => File["/var/local/config"]
  }

  file { "/var/local/config/nginx_passenger_http.inc":
    owner   => root,
    group   => root,
    mode    => "0644",
    content => template("passenger/nginx_passenger_http.inc.erb"),
    require => File["/var/local/config"]
  }

  exec { "check the passenger apt-get key":
    command => "/usr/bin/gpg --keyserver pgpkeys.mit.edu --recv-key 561F9B9CAC40B2F7",
    creates => "/usr/bin/passenger",
    user => root
  }

  exec { "trust the passenger apt-get key":
    command => "/usr/bin/gpg -a --export 561F9B9CAC40B2F7 | sudo apt-key add -",
    user => root,
    creates => "/usr/bin/passenger",
    require => Exec["check the passenger apt-get key"]
  }

  exec { "allow agt-get passenger":
    command => "/usr/bin/apt-add-repository -y 'deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main'",
    user => root,
    creates => "/usr/bin/passenger",
    require => Exec["trust the passenger apt-get key"]
  }

  exec { "apt-get passenger":
    command => "/usr/bin/apt-get -y update && apt-get -y install libcurl4-openssl-dev passenger-dev nginx-extras",
    user => root,
    creates => "/usr/bin/passenger",
    require => [ Exec["allow agt-get passenger"],
                 File["/var/local/config/nginx_passenger_common.inc"],
                 File["/var/local/config/nginx_passenger_http.inc"] ]
  }

  file { "/etc/nginx/nginx.conf":
    owner   => root,
    group   => root,
    mode    => "0644",
    content => template("passenger/nginx.conf.erb"),
    require => Exec["apt-get passenger"]
  }

  file { "/etc/nginx/sites-enabled/default":
    ensure  => purged,
    require => Exec["apt-get passenger"]
  }
}
