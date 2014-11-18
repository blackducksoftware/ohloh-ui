class users {
  file { "/home/$app_user_name":
    owner   => $app_user_name,
    group   => $app_user_name,
    mode    => "0744",
  }

  group { $app_user_name:
    ensure => present,
    gid    => $app_user_id
  }

  user { $app_user_name:
    ensure     => present,
    uid        => $app_user_id,
    gid        => $app_user_name,
    groups     => [$app_user_name, "sudo", "root"],
    membership => minimum,
    managehome => true,
    require    => Group[$app_user_name]
  }

  exec { "change password for $app_user_name":
    command => "echo  '$app_user_name:password' | chpasswd $app_user_name",
    path => ["/bin", "/usr/sbin"],
    require => User[$app_user_name]
  }

  file { "/home/$app_user_name/.bash_profile":
    owner   => $app_user_name,
    group   => $app_user_name,
    mode    => "0744",
    source  => "puppet:///modules/users/bash_profile",
    require => File["/home/$app_user_name"]
  }

  file { "/home/$app_user_name/.bashrc":
    owner   => $app_user_name,
    group   => $app_user_name,
    mode    => "0744",
    content => template("users/bashrc.erb"),
    require => File["/home/$app_user_name"]
  }
}
