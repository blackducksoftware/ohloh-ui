class imagemagick {
  exec { "apt-get imagemagick":
    command => "/usr/bin/apt-get -y install imagemagick libmagickcore-dev libmagickwand-dev",
    creates => "/usr/bin/convert",
    user => root
  }
}
