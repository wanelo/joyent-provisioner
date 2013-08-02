module Provisioner
  module Command
    class Host < Base

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
        ].join(' ')

        log_path = "#{log_dir}/#{host_name}_provision.log"
        command << " --run-list #{run_list}" if run_list
        command << " 2>&1 > #{log_path} &"
      end

    end
  end
end
