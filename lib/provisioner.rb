require "provisioner/version"
require 'thor'
require 'yaml'

module Provisioner

  class Configuration
    def initialize(path)
      @configuration = YAML.load_file(path)
      @configuration['ips'] = {}
    end

    # returns hash with image, flavor, distro, runlist, networks
    def for_host(type)
      @configuration['clusters'][type]
    end

    def environment
      @configuration['environment']
    end

    def host_suffix
      @configuration['host_suffix']
    end

    def cluster_names
      @configuration['clusters'].keys
    end

    def get_ips
      server_list = `knife joyent server list | awk '{print $2 " " $6}'`.split("\n")
      server_list.each do |server|
        hostname, ip = server.split(' ')
        @configuration['ips'][hostname] = ip
      end
    end

    def ip_for(host)
      @configuration['ips'][host]
    end
  end

  class Provision < Thor
    option :type
    option :environment
    option :config
    option :dry_run
    option :ssh_user

    desc "host HOST_NUMBER", "Create new host"
    long_desc <<-LONGDESC
    > $ ./provision host 0 --config production.yml --type redis-af
    > $ ./provision host 0 --environment production --type redis-af
    LONGDESC

    def host(host_number)
      type = options[:type]
      create_host(host_number, type)
    end

    option :type
    option :environment
    option :config
    option :dry_run
    option :ssh_user

    desc "cluster", "Provision cluster of hosts"
    long_desc <<-LONGDESC
    To provision new hosts for the entire infrastructure environment:
    > $ ./provision cluster --config production.yml
    > $ ./provision cluster --environment production

    To provision new hosts for a specific cluster:
    > $ ./provision cluster --environment production --type redis-af
    > $ ./provision cluster --config production.yml --type redis-af
    LONGDESC

    def cluster
      if options[:type]
        cluster_names = [options[:type]]
      else
        cluster_names = config.cluster_names
      end

      cluster_names.each do |cluster_name|
        cluster_config = config.for_host(cluster_name)
        sequence = cluster_config['host_sequence']
        host_numbers = eval "(#{sequence}).to_a"
        host_numbers.each do |host_number|
          create_host(host_number, cluster_name)
          sleep(1)
        end
      end
    end

    option :type
    option :environment
    option :config
    option :dry_run
    option :ssh_user

    desc "rebootstrap", "Bootstrap over pre-provisioned hosts"
    long_desc <<-LONGDESC
    To re-bootstrap hosts that have already been provisioned:
    > $ ./provision rebootstrap --config production.yml
    > $ ./provision rebootstrap --environment production
    > $ ./provision rebootstrap --type redis-af
    > $ ./provision rebootstrap --ssh-user username (needs to be able to sudo)

    Re-bootstrapping requires a cluster type argument.
    LONGDESC

    def rebootstrap
      if options[:type].nil? || options[:type].empty?
        exit 1
      end

      config.get_ips

      cluster_config = config.for_host(options[:type])
      sequence = cluster_config['host_sequence']
      host_numbers = eval "(#{sequence}).to_a"
      host_numbers.each do |host_number|
        bootstrap_host(host_number, options[:type])
        sleep(0.1)
      end
    end

    private

    def create_host host_number, type
      unless type
        puts '--type is required'
        return
      end

      host_config = config.for_host(type)
      host_number = sprintf("%03d", host_number.to_i)

      environment = config.environment

      host_name = "#{host_config['host_prefix']}-#{host_number}"
      host_name += ".#{config.host_suffix}" if config.host_suffix

      log_directory = './log'
      log_path = "#{log_directory}/#{host_name}_provision.log"
      `mkdir -p #{log_directory}`

      puts "Provisioning '#{host_name}'. Log: #{log_path}"

      command = [
          "knife joyent server create",
          "--image #{host_config['image']}",
          "--flavor #{host_config['flavor']}",
          "--distro #{host_config['distro']}",
          "--networks #{host_config['networks']}",
          "--environment #{environment}",
          "--node-name #{host_name}",
      ]

      command << "--run-list #{host_config['run_list']}" unless host_config['run_list'].empty?
      command << " 2>&1 > #{log_path} &"

      shellout(command.join(' '))
    end

    def bootstrap_host host_number, type
      host_config = config.for_host(type)
      host_number = sprintf("%03d", host_number.to_i)

      environment = config.environment || '_default'
      ssh_user = options[:ssh_user] || 'root'

      host_name = "#{host_config['host_prefix']}-#{host_number}"
      host_name += ".#{config.host_suffix}" if config.host_suffix

      log_directory = './log'
      log_path = "#{log_directory}/#{host_name}_provision.log"
      `mkdir -p #{log_directory}`


      puts "Bootstrapping '#{host_name}'. Log: #{log_path}"

      ip = config.ip_for(host_name)
      shellout("ssh #{ip} -l #{ssh_user} 'sudo rm -rf /etc/chef'")

      command = [
          "knife bootstrap",
          ip,
          "--distro #{host_config['distro']}",
          "--environment #{environment}",
          "--node-name #{host_name}",
      ]

      command << "--run-list #{host_config['run_list']}" unless host_config['run_list'].empty?
      command << "--ssh-user #{ssh_user}"
      command << " 2>&1 > #{log_path} &"

      shellout(command.join(' '))
    end

    def config
      @config ||= begin
        if options[:config]
          configuration_path = options[:config]
        else
          options[:environment]
          configuration_path = "#{options[:environment]}.yml"
        end

        Configuration.new(configuration_path)
      end
    end

    def shellout(command)
      if options[:dry_run]
        puts command
      else
        system(command)
      end
    end
  end

end
