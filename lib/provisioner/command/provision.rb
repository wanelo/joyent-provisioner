require 'json'

module Provisioner
  module Command
    class Provision < Base

      private

      def shell_commands_for(number)
        host_name = host_name(number)
        command = [
            "knife joyent server create",
            "--image #{image}",
            "--flavor #{flavor}",
            "--distro #{distro}",
            "--networks #{networks}",
            "--environment #{environment}",
            "--node-name #{host_name}",
        ]


        log_path = "#{log_dir}/#{host_name}_provision.log"
        command << "--run-list #{run_list}" if run_list
        command << "--ssh-user #{ssh_user}" if ssh_user
        command << "--tags '#{encoded_tags}'" if tags
        command << "2>&1 > #{log_path} &"

        command.join(' ')
      end

      def encoded_tags
        JSON.dump(tags)
      end

    end
  end
end
