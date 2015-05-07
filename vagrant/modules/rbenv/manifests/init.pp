class rbenv {
  exec { "mkdir /home/$app_user_name/.rbenv":
    command => "/bin/mkdir /home/$app_user_name/.rbenv",
    user => $app_user_name,
    creates => "/home/$app_user_name/.rbenv",
    require => Exec["apt-get git"]
  }

  exec { "git clone rbenv":
    command => "/usr/bin/git clone https://github.com/sstephenson/rbenv.git /home/$app_user_name/.rbenv",
    user => $app_user_name,
    creates => "/home/$app_user_name/.rbenv/bin",
    require => Exec["mkdir /home/$app_user_name/.rbenv"]
  }

  exec { "git clone ruby-build":
    command => "/usr/bin/git clone https://github.com/sstephenson/ruby-build.git /home/$app_user_name/.rbenv/plugins/ruby-build",
    user => $app_user_name,
    creates => "/home/$app_user_name/.rbenv/plugins/ruby-build",
    require => Exec["git clone rbenv"]
  }

  exec { "git clone rbenv-gem-rehash":
    command => "/usr/bin/git clone https://github.com/sstephenson/rbenv-gem-rehash.git /home/$app_user_name/.rbenv/plugins/rbenv-gem-rehash",
    user => $app_user_name,
    creates => "/home/$app_user_name/.rbenv/plugins/rbenv-gem-rehash",
    require => Exec["git clone ruby-build"]
  }

  exec { "install ruby":
    command     => "/home/$app_user_name/.rbenv/bin/rbenv install -k $app_ruby_version",
    timeout     => 0,
    user        => $app_user_name,
    group       => $app_user_name,
    cwd         => "/home/$app_user_name",
    environment => [ "HOME=/home/$app_user_name" ],
    creates     => "/home/$app_user_name/.rbenv/versions/$app_ruby_version",
    path        => "/home/$app_user_name/.rbenv/bin/rbenv:/bin:/usr/bin",
    logoutput   => 'on_failure',
    require     => Exec["git clone rbenv-gem-rehash"]
  }

  exec { "set default ruby":
    command => "/home/$app_user_name/.rbenv/bin/rbenv global $app_ruby_version",
    user => $app_user_name,
    cwd         => "/home/$app_user_name",
    environment => [ "HOME=/home/$app_user_name" ],
    path        => "/home/$app_user_name/.rbenv/bin/rbenv:/bin:/usr/bin",
    require => Exec["install ruby"]
  }
}
