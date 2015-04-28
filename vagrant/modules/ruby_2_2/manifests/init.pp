class ruby_2_2 {
  exec { "check the ruby2.2 apt-get key":
    command => "/usr/bin/gpg --keyserver pgpkeys.mit.edu --recv-key 7FCC7D46ACCC4CF8",
    creates => "/usr/bin/ruby2.2",
    user => root
  }

  exec { "trust the ruby2.2 apt-get key":
    command => "/usr/bin/gpg -a --export 7FCC7D46ACCC4CF8 | sudo apt-key add -",
    user => root,
    creates => "/usr/bin/ruby2.2",
    require => Exec["check the ruby2.2 apt-get key"]
  }

  exec { "allow agt-get ruby2.2":
    command => "/bin/echo | /usr/bin/apt-add-repository ppa:brightbox/ruby-ng",
    user => root,
    creates => "/usr/bin/ruby2.2",
    require => Exec["trust the ruby2.2 apt-get key"]
  }

  exec { "apt-get ruby2.2":
    command => "/usr/bin/apt-get -y update && apt-get -y install ruby2.2 ruby2.2-dev",
    user => root,
    creates => "/usr/bin/ruby2.2",
    require => Exec["allow agt-get ruby2.2"]
  }
}
