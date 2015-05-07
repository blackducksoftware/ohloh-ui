class ohloh_dependencies {
  include apt
  include build_essential
  include nginx
  include imagemagick
  include postgres_client
  include memcached
  include users
  include git
}

class ruby_install {
  include rbenv
}

class passenger_install {
  include passenger
}

class bundle_gems {
  exec { "install bundler":
    command => "rbenv rehash && gem install bundler",
    creates => "/home/$app_user_name/.rbenv/versions/$app_ruby_version/bin/bundle",
    cwd => $app_mount_point,
    user => $app_user_name,
    environment => [ "HOME=/home/$app_user_name" ],
    path => "/home/$app_user_name/.rbenv/shims:/home/$app_user_name/.rbenv/bin:/usr/local/bin:/usr/bin:/bin"
  }

  exec { "bundle install":
    command => "bundle install",
    cwd => $app_mount_point,
    user => $app_user_name,
    environment => [ "HOME=/home/$app_user_name" ],
    path => "/home/$app_user_name/.rbenv/shims:/home/$app_user_name/.rbenv/bin:/usr/local/bin:/usr/bin:/bin",
    require => Exec["install bundler"]
  }
}

class restart_nginx {
  exec { "restart nginx":
    command => "/usr/bin/service nginx restart",
    user => root
  }
}

class { "ohloh_dependencies": } ->
class { "ruby_install": } ->
class { "passenger_install": } ->
class { "bundle_gems": } ->
class { "restart_nginx": }
