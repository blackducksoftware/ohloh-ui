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

Pull Request Poller:
--------------------

* Runs all tests and generates code coverage information
* Runs Rubocop
* Runs Brakeman

To view the automated Pull Request testing statuses,
go to: stage-utility-1:8080/job/ohloh-ui-pull-request-sanitizer/

-------Note------------

Postgresql 9.2 needs to be installed for local testing.
sudo apt-get install postgresql-9.2
