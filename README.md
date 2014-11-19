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

* Runs all tests and generates code coverage
* Runs Rubocop
* Runs Brakeman

To view the automated Pull Request testing statuses,
go to: http://stage-utility-1:8080/job/ohloh-ui-pull-requests/
