OhlohUI
=======

Getting Started:
----------------

* Install Vagrant
* Clone this repository
* **`cd vagrant`**
* **`vagrant up`**

The initial provisioning of the virtual machine will take roughly five minutes.

After the inital sync, you need only run **`vagrant provision`** as that will
run bundle install and restart the server for you. That should take just a few seconds.

Experimental Docker Support:
----------------------------

Install boot2docker:
```
brew update
brew install boot2docker
boot2docker init
boot2docker up
eval "$(boot2docker shellinit)"
```
Build the application:

```
cd ~/src/ohloh-ui
docker build -t ohloh-ui .
docker run --name ohloh-ui-app-server -p 9090:3000 -d ohloh-ui
open http://$(boot2docker ip 2>/dev/null):9090/p/rails
```

Pull Request Poller:
--------------------

* Runs all tests and generates code coverage information
* Runs Rubocop
* Runs Brakeman
* Runs haml-lint

To view the automated Pull Request testing statuses,
go to: stage-utility-1:8080/job/ohloh-ui-pull-request-sanitizer/

If you wish to run a similar thing locally do this:

* **`rake && rubocop && brakeman -q && haml-lint .`**

Note Mac OS X
-------------------

For Mac OS X, the following commands need to be executed to circumvent ps_ts_dict error:

* **`CREATE USER ohloh_user SUPERUSER;ALTER USER ohloh_user WITH PASSWORD 'password';`**
* **`update pg_database set encoding=0 where datname ILIKE 'template%';`**

Once these commands are executed to setup the template for the host database, execute
**`rake db:test:prepare`**

Afterwards testing should execute as normal.
