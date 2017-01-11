module Provisioner
  module Command
    class Bootstrap < Base

      def use_sudo?
        options[:sudo]
      end

      private

      def shell_commands_for(number)
        host = HostCommand.new(host_name(number), self)

        commands = []
        commands << host.reset_command if reset_chef?
        commands << host.bootstrap_command
      end

      def reset_chef?
        options[:reset]
      end

      class HostCommand
        attr_accessor :name, :context
        def initialize(name, context)
          @name = name
          @context = context
        end

        def ip_for_host
          Provisioner::HostIP.ip_for name
        end

        def reset_command
          "ssh #{ip_for_host} -l #{context.ssh_user} 'sudo rm -rf /etc/chef'"
        end

        def bootstrap_command
          bootstrap_command = [
              'knife bootstrap',
              ip_for_host,
              "--bootstrap-template #{context.distro}",
              "--environment #{context.environment}",
              "--node-name #{name}",
          ]

          bootstrap_command << "--run-list #{context.run_list}" if context.run_list
          bootstrap_command << "--ssh-user #{context.ssh_user}"
          bootstrap_command << '--sudo' if context.use_sudo?
          bootstrap_command << "2>&1 > #{context.log_dir}/#{name}_provision.log &"
          bootstrap_command.join(' ')
        end
      end
    end
  end
end
