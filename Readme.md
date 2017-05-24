OhlohUI
=======

Dependencies:
----------------

* OhlohUI uses the ruby version 2.2.5. Please install ruby 2.
* OhlohUI uses the postgresql database. Please install postgresql and create a new user on it.

Getting Started:
----------------

```
$ git clone git@github.com:blackducksoftware/ohloh-ui.git
$ cd ohloh-ui
$ gem install bundler
$ bundle install
```

The OhlohUI data is split between two databases in production. The development setup needs to reflect the same.
The database names are configured in a file specific to each environment. For development, create a file **env.development**, with the following contents.

```
DB_HOST = localhost
DB_NAME =
DB_USERNAME =
DB_PASSWORD =

FOREIGN_DB_HOST = localhost
FOREIGN_DB_NAME =
FOREIGN_DB_USERNAME =
FOREIGN_DB_PASSWORD =

TEST_DB_HOST = localhost
TEST_DB_NAME =
TEST_DB_USERNAME =
TEST_DB_PASSWORD =
```

The *_USERNAME and *_PASSWORD entries need to reflect the user created in postgresql. The *DB_NAME entries should be new database names. These will be created during our setup.

```
$ rake db:create
$ rake db:structure:load
$ rake db:second_base:structure:load
```

Setup a default admin user. The arguments are optional. By default a user with the login **admin_user**, password **admin_password** and email **admin@example.com** will be created.

```
$ ruby script/setup_default_admin.rb <login> <passsword> <email>
```

This might throw a bunch of errors about relations and constraints already existing. Please ignore them and proceed.

```
$ rails s
```

Visit **localhost:3000** to checkout the site.

Tests:
--------------------

```
$ rake test
```

Pull Request Builder:
--------------------

The OhlohUI CI uses the following task to verify PR compatibility.

```
$ rake ci:all_tasks
```

This runs:
* rubocop
* haml-lint
* brakeman
* bundle audit
* teaspoon
* rake test

Note Mac OS X
-------------------

For Mac OS X, the following commands need to be executed to circumvent ps_ts_dict error:

* **`CREATE USER ohloh_user SUPERUSER;ALTER USER ohloh_user WITH PASSWORD 'password';`**
* **`update pg_database set encoding=0 where datname ILIKE 'template%';`**

Once these commands are executed to setup the template for the host database, execute
**`rake db:test:prepare`**

Afterwards testing should execute as normal.
