class ohloh_dependencies {
  include build_essential
  include nginx
  include imagemagick
  include postgres_client
  include memcached
  include ruby_2_1
  include users
}

class passenger_install {
  include passenger
}

class bundle_gems {
  exec { "install bundler":
    command => "/usr/bin/gem install bundler",
    creates => "/usr/local/bin/bundle",
    user => root
  }

  exec { "bundle install":
    command => "/usr/local/bin/bundle install",
    path => ['/bin', '/usr/bin', '/usr/local/bin'],
    cwd => $app_mount_point,
    user => root,
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
class { "passenger_install": } ->
class { "bundle_gems": } ->
class { "restart_nginx": }
