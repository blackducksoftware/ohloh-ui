class postgres_client {
  exec { "check the postgresql apt-get key":
    command => "/usr/bin/gpg --keyserver pgpkeys.mit.edu --recv-key 7FCC7D46ACCC4CF8",
    creates => "/usr/bin/psql",
    user => root
  }

  exec { "trust the postgresql apt-get key":
    command => "/usr/bin/gpg -a --export 7FCC7D46ACCC4CF8 | sudo apt-key add -",
    user => root,
    creates => "/usr/bin/psql",
    require => Exec["check the postgresql apt-get key"]
  }

  exec { "allow agt-get postgres":
    command => "/usr/bin/apt-add-repository 'deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main'",
    user => root,
    creates => "/usr/bin/psql",
    require => Exec["trust the postgresql apt-get key"]
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
