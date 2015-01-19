class git {
  exec { "apt-get git":
    command => "/usr/bin/apt-get -y install git",
    user => root,
    creates => "/usr/bin/git"
  }
}
