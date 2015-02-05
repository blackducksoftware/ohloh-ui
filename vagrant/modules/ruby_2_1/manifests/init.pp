class ruby_2_1 {
  exec { "allow agt-get ruby2.1":
    command => "/bin/echo | /usr/bin/apt-add-repository ppa:brightbox/ruby-ng",
    user => root,
    creates => "/usr/bin/ruby2.1",
    require => File["/etc/apt/apt.conf"]
  }

  exec { "apt-get ruby2.1":
    command => "/usr/bin/apt-get -y update && apt-get -y install ruby2.1 ruby2.1-dev",
    user => root,
    creates => "/usr/bin/ruby2.1",
    require => Exec["allow agt-get ruby2.1"]
  }
}
