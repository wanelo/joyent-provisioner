require 'mixlib/cli'

module Provisioner
  class CLI
    include Mixlib::CLI

    class << self
      attr_reader :commands

      # Returns a command class by it's name
      def command name
        @commands[name]
      end

      # Returns array of registered command names
      def supported_commands
        commands.keys
      end

      def inherited subclass
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

          option :ssh_user,
                 short: '-l SSH_USERNAME',
                 long: '--user SSH_USERNAME',
                 description: 'SSH user used to connect to server (overrides yml configuration)',
                 required: false

          option :dry,
                 long: '--dry-run',
                 description: 'Dry runs and prints all commands without executing them',
                 boolean: true,
                 required: false

          option :provisioner_type,
                 description: 'The type of provisioner that will be used',
                 long: '--provisioner-type PROVISIONER_TYPE',
                 short: '-p PROVISIONER_TYPE',
                 string: true,
                 default: 'knife'

          option :help,
                 short: '-h',
                 long: '--help',
                 description: 'Show this message',
                 on: :tail,
                 boolean: true,
                 show_options: true,
                 exit: 0
        end

        subclass.class_eval do
          def run(argv = ARGV)
            parse_options argv
            enable_logger if config[:debug]

            if config[:dry]
              provisioner_command(config[:provisioner_type]).shell_commands.each do |command|
                puts command
              end
            else
              provisioner_command(config[:provisioner_type]).run
            end
          end

        end
      end
    end

    attr_reader :args

    def run args = ARGV
      @args = args
      validate!
      command_name = args.shift
      command_class = Provisioner::CLI.command(command_name)
      Provisioner::Exit.with_message("Command '#{command_name}' not found.") if command_class.nil?
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

    def generate_config argv = []
      parse_options argv
      config[:configuration] = Provisioner::Configuration.from_path(config[:config_file])
    end

    def enable_logger
      STDOUT.sync = true
      Provisioner::Logger.enable
    end

  end
end

require 'provisioner/cli/provision'
require 'provisioner/cli/bootstrap'
