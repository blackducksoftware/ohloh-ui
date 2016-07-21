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
boot2docker ssh
echo 'EXTRA_ARGS="--insecure-registry coreos.blackducksoftware.com:5000"' | sudo tee -a /var/lib/boot2docker/profile
sudo /etc/init.d/docker restart
exit
eval "$(boot2docker shellinit)"
```
Build the application:

```
cd ~/src/ohloh-ui
rake docker:build
rake docker:run
rake docker:status
rake docker:open
rake docker:tag
```

To see which builds are available for running, look here:

http://coreos.blackducksoftware.com:5000/v1/repositories/ohloh-ui/tags

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

** TEST **
