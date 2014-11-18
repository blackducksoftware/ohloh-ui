class build_essential {
  exec { "apt-get build-essential":
    command => "/usr/bin/apt-get -y install build-essential",
    creates => "/usr/bin/g++",
    user => root
  }
}
