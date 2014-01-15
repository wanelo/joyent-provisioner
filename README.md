# Joyent Cloud Provisioner

[![Gem Version](https://badge.fury.io/rb/joyent-provisioner.png)](http://badge.fury.io/rb/joyent-provisioner)
[![Build status](https://secure.travis-ci.org/wanelo/joyent-provisioner.png)](http://travis-ci.org/wanelo/joyent-provisioner)
[![Code Climate](https://codeclimate.com/github/wanelo/joyent-provisioner.png)](https://codeclimate.com/github/wanelo/joyent-provisioner)

This gem provides a ruby class and a command line tool to simplify provisioning of clusters of hosts in the
cloud environment, based on rules defined in a convenient yml file. It specifically supports Joyent Cloud,
but can be easily extended to support other clouds.

The idea behind it is that working software is better than any documentation. But defining your templates
in the YML file you not only documenting how to build various types of hosts in your infrastructure,
you are also then able to use this configuration/documentation to actually provision or bootstrap these hosts
with ease.

## Installation

Add this line to your application's Gemfile:

    gem 'joyent-provisioner'

And then execute:

    $ bundle

Or install it into your ruby environment as follows:

    $ gem install joyent-provisioner

## Configuration

Provisioner uses a YAML file to define templates of various types of hosts in your application, and
link them with a particular type of Joyent flavors, packages and networks.  Please see 'knife joyent' for
definition of these terms.

Below YAML file defines a single template 'memcached-sessions' within the 'test' environment. It
links the template with a UUID of an appropriate Joyent image, flavor, distribution, and list of
networks. It also specifies Chef run_list to configure these hosts, as well as the host sequence
which is used to provision many hosts in a cluster.

Host sequence can be overridden by command line option --number, which can pass a single number, a ruby
range, or a ruby array as a string.

```yaml
global:
  environment: test
  host_suffix: test
  log_dir: ./tmp
  ssh_user: ops

templates:
  memcached-sessions:
    image: 9ec5c0c-a941-11e2-a7dc-57a6b041988f
    flavor: "g3-highmemory-17.125-smartos"
    distro: smartos-base64
    networks: "42325ea0-eb62-44c1-8eb6-0af3e2f83abc,c8cde927-6277-49ca-82a3-741e8b23b02f"
    run_list: "role[joyent]"
    host_sequence: 1..2
    host_prefix: memcached-sessions
```

After provisioning all hosts in the memcached-sessions template, you should end up with two hosts, like so:

 * memcached-sessions001.test
 * memcached-sessions002.test

The intention is that each environment, such as production or staging, will have it's own YAML file.

## Usage

```bash
Usage:
  [bundle exec] provisioner command ...

Where the command is one of the following:
  provision, bootstrap
```

### Provisioning Hosts

```bash
Usage: provisioner provision --config <path-to-config>.yml [options]
    -c, --config CONFIG_FILE         Path to the config file (YML) (required)
    -g, --debug                      Log status to STDOUT
        --dry-run                    Dry runs and prints all commands without executing them
    -n, --number NUMBER              Ruby range or a number for the host, ie 3 or 1..3 or [2,4,6]
    -t, --template TEMPLATE          Template name (required)
    -h, --help                       Show this message
```

To provision a specific host

```bash
provisioner provision -n 3 -t redis-cluster -c production.yml
```

To provision all hosts defined by host_sequence in a template

```bash
provisioner provision -t redis-cluster -c production.yml
```

Only show the commands that should be run without actually running them:

```bash
provisioner provision -t redis-cluster -c production.yml --dry-run
```

### Bootstrapping Hosts

Bootstrapping hosts skips the provisioning step, and assumes that the host is already provisioned.
It runs 'knife joyent server list' in order to determine host's IP address, and then proceeds
to bootrap the host when the IP is found.

```bash
Usage: provisioner bootstrap --config <path-to-config>.yml [options]
    -c, --config CONFIG_FILE         Path to the config file (YML) (required)
    -g, --debug                      Log status to STDOUT
        --dry-run                    Dry runs and prints all commands without executing them
    -n, --number NUMBER              Ruby range or a number for the host, ie 3 or 1..3 or [2,4,6]
    -t, --template TEMPLATE          Template name (required)
    -h, --help                       Show this message
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

