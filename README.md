# Provisioner

[![Build status](https://secure.travis-ci.org/wanelo/provisioner.png)](http://travis-ci.org/wanelo/provisioner)

Provision clusters of hosts in the cloud based on rules defined in a convenient yml file.

## Installation

Add this line to your application's Gemfile:

    gem 'provisioner'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install provisioner

## Usage

To provision a specific host
provision -n 3 -t redis-cluster -c production.yml

To provision all hosts for a template
provision -t redis-cluster -c production.yml

Only show the commands
provision -t redis-cluster -c production.yml --dry-run

For help
provision -h


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

