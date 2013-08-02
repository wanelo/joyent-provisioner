module Provisioner
  module Helper
    module Exit
      def error_exit_with_msg(msg)
        $stderr.puts "Error: #{msg}"
        $stderr.puts Provisioner::USAGE
        exit 1
      end
    end
  end
end
