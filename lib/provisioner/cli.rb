require 'mixlib/cli'

module Provisioner
  class CLI
    include Mixlib::CLI

    class << self

      def command(name)
        @commands[name]
      end

      def inherited(subclass)
        @commands ||= {}
        @commands[subclass.name.split("::").last.downcase] = subclass

        subclass.instance_eval do
          option :config_file,
                 short: '-c CONFIG_FILE',
                 long: '--config CONFIG_FILE',
                 description: 'Path to the config file (YML)',
                 required: true

          option :debug,
                 short: '-g',
                 long: '--debug',
                 description: 'Log status to STDOUT',
                 boolean: true,
                 required: false,
                 default: false

          option :template,
                 short: '-t TEMPLATE',
                 long: '--template TEMPLATE',
                 description: 'Template name',
                 required: true

          option :number,
                 short: '-n NUMBER',
                 long: '--number NUMBER',
                 description: 'Ruby range or a number for the host, ie 3 or 1..3 or [2,4,6]',
                 required: false

          option :dry,
                 long: '--dry-run',
                 description: 'Dry runs and prints all commands without executing them',
                 boolean: true,
                 required: false

          option :help,
                 short: '-h',
                 long: '--help',
                 description: 'Show this message',
                 on: :tail,
                 boolean: true,
                 show_options: true,
                 exit: 0
        end
      end

    end

    attr_reader :args

    def run(args = ARGV)
      @args = args
      validate!
      command_name = ['bootstrap'].include?(args[0]) ? args.shift : 'host'
      command_class = Provisioner::CLI.command(command_name)
      command_class.new.run(args)
    end

    protected

    def template_configuration
      Provisioner::Configuration.from_path(config[:config_file])
    end

    private

    def validate!
      Provisioner::Exit.with_message('No command given') if args.empty?
      @command = args.first
    end

    def generate_config(argv)
      parse_options argv
      config[:configuration] = Provisioner::Configuration.from_path(config[:config_file])
    end

    def enable_logger
      STDOUT.sync = true
      Provisioner::Logger.enable
    end

  end
end

require 'provisioner/cli/host'
require 'provisioner/cli/bootstrap'