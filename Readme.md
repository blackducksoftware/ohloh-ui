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
DB_ENCODING = 'UTF-8'

DB_HOST = localhost
DB_NAME =
DB_USERNAME =
DB_PASSWORD =

FOREIGN_DB_HOST = localhost
FOREIGN_DB_NAME =
FOREIGN_DB_USERNAME =
FOREIGN_DB_PASSWORD =
```

The default DB encoding was set to SQL_ASCII to support data encoded by older ruby. For new data, the UTF-8 encoding should work fine. The *_USERNAME and *_PASSWORD entries need to reflect the user created in postgresql. The *DB_NAME entries should be new database names. These will be created during our setup.

```
$ rake db:create
$ rake db:structure:load
$ rake db:second_base:structure:load
```

This might throw a bunch of errors about relations and constraints already existing. Please ignore them and proceed.

Setup a default admin user. The arguments are optional. By default a user with the login **admin_user**, password **admin_password** and email **admin@example.com** will be created.

```
$ ruby script/setup_default_admin.rb <login> <passsword> <email>
```

```
$ rails s
```

Visit **localhost:3000** to checkout the site.

Tests:
--------------------

Add the following to the **.env.development** file. Fill in the blank values appropriately. Modify **.env.test** to reflect the values that were added here.

```
TEST_DB_HOST = localhost
TEST_DB_NAME =
TEST_DB_USERNAME =
TEST_DB_PASSWORD =

FOREIGN_TEST_DB_HOST = localhost
FOREIGN_TEST_DB_NAME =
FOREIGN_TEST_DB_USERNAME =
FOREIGN_TEST_DB_PASSWORD =
```

Then run the following:

```
$ rake db:test:prepare
$ rake test
```

Integration Tests:
--------------------

The following packages need to be installed to make the feature specs work:

#### Mac OSX

```sh
$ brew install brew-cask
$ brew cask install google-chrome
$ brew install chromedriver
```

#### Ubuntu

```sh
$ sudo apt-get install chromium-browser
$ sudo apt-get install chromium-chromedriver
$ sudo ln -s /usr/lib/chromium-browser/chromedriver /usr/bin/chromedriver
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
* spinach
