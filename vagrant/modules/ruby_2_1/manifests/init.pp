class ruby_2_1 {
  exec { "check the ruby2.1 apt-get key":
    command => "/usr/bin/gpg --keyserver pgpkeys.mit.edu --recv-key 7FCC7D46ACCC4CF8",
    creates => "/usr/bin/ruby2.1",
    user => root
  }

  exec { "trust the ruby2.1 apt-get key":
    command => "/usr/bin/gpg -a --export 7FCC7D46ACCC4CF8 | sudo apt-key add -",
    user => root,
    creates => "/usr/bin/ruby2.1",
    require => Exec["check the ruby2.1 apt-get key"]
  }

  exec { "allow agt-get ruby2.1":
    command => "/bin/echo | /usr/bin/apt-add-repository ppa:brightbox/ruby-ng",
    user => root,
    creates => "/usr/bin/ruby2.1",
    require => Exec["trust the ruby2.1 apt-get key"]
  }

  exec { "apt-get ruby2.1":
    command => "/usr/bin/apt-get -y update && apt-get -y install ruby2.1 ruby2.1-dev",
    user => root,
    creates => "/usr/bin/ruby2.1",
    require => Exec["allow agt-get ruby2.1"]
  }
}
