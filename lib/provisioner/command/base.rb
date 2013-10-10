module Provisioner
  module Command
    class Base
      attr_accessor :image, :flavor, :distro, :networks, :run_list,
                    :host_sequence, :host_prefix, :environment, :host_suffix,
                    :host_presuffix, :log_dir, :host_number, :options, :ssh_user,
                    :tags

      def initialize(template_configuration, options = {})
        @options = options
        @host_number = options[:number]
        template_configuration.each_pair do |key, value|
          self.send("#{key}=", value)
        end
        @ssh_user = options[:ssh_user] if options[:ssh_user]
        raise "Log path is required" unless @log_dir
        Dir.mkdir(log_dir) unless Dir.exists?(log_dir)
      end

      def run
        shell_commands.each do |command|
          shellout command
          sleep 0.5
        end
      end

      def shell_commands_for host_number
        raise 'Abstract method, implement in subclasses'
      end

      def shell_commands
        host_numbers.map do |i|
          shell_commands_for(i.to_i)
        end.flatten
      end

      protected

      def host_numbers
        @host_numbers ||= begin
          return [host_number] if host_number
          eval "(#{host_sequence}).to_a"
        end
      end

      def host_name(number)
        host_name = sprintf('%s%03d', host_prefix, number)
        host_name += ".#{host_presuffix}" if host_presuffix
        host_name += ".#{host_suffix}" if host_suffix
        host_name
      end

      def shellout(command)
        puts "Running provision command:"
        puts command
        system(command)
      end
    end
  end
end

require_relative 'provision'
require_relative 'bootstrap'
