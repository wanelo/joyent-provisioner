require 'mixlib/cli'

module Provisioner
  class CLI
    include Mixlib::CLI
    include Provisioner::Helper::Exit

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

        end
      end

    end

    attr_reader :args

    def run(args = ARGV)
      @args = args
      validate!
      command_class = Provisioner::CLI.command(args.shift)
      command_class.new.run(args)
    end

    protected

    def template_configuration
      Provisioner::Configuration.from_path(config[:config_file])
    end

    private

    def validate!
      error_exit_with_msg('No command given') if args.empty?
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