class apt {
  file { "/etc/apt/apt.conf":
    owner   => root,
    group   => root,
    mode    => "0744",
    source  => "puppet:///modules/apt/apt.conf"
  }
}
