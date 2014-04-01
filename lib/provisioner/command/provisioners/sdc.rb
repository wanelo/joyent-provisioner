require 'json'
require 'provisioner/command/provision'

module Provisioner
  module Command
    class Sdc < Provision

      private

      def shell_commands_for(number)
        host_name = host_name(number)
        command = [
          'sdc-createmachine',
          "--dataset #{image}",
          "--package #{package}",
          "--networks #{networks}",
          "--name #{host_name}",
        ]


        log_path = "#{log_dir}/#{host_name}_provision.log"
        command << "#{encoded_tags}" if tags
        command << "2>&1 > #{log_path} &"

        command.join(' ')
      end

      def encoded_tags
        tags.map{|key,value| %Q(--tag "#{key}"="#{JSON.dump(value)}")}.join(' ')
      end
    end
  end
end
