class postgres_client {
  exec { "allow agt-get postgres":
    command => "/usr/bin/apt-add-repository 'deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main'",
    user => root,
    creates => "/usr/bin/psql",
    require => File["/etc/apt/apt.conf"]
  }

  exec { "apt-get postgres":
    command => "/usr/bin/apt-get -y update && apt-get -y install postgresql-9.3 postgresql-client-9.3 libpq-dev",
    user => root,
    creates => "/usr/bin/psql",
    require => Exec["allow agt-get postgres"]
  }

  exec { "setup ohloh_user":
    command => "/usr/bin/psql -c \"CREATE USER ohloh_user SUPERUSER;ALTER USER ohloh_user WITH PASSWORD 'password';\"",
    user => postgres,
    creates => "/usr/bin/psql",
    require => Exec["apt-get postgres"]
  }

  exec { "roll back to sql_ascii":
    command => "/usr/bin/psql -c \"update pg_database set encoding=0 where datname ILIKE 'template%';\"",
    user => postgres,
    creates => "/usr/bin/psql",
    require => Exec["setup ohloh_user"]
  }

  exec { "mark psql as being set up":
    command => "/usr/bin/touch /tmp/psql_configured",
    user => postgres,
    creates => "/tmp/psql_configured",
    require => Exec["roll back to sql_ascii"]
  }
}
