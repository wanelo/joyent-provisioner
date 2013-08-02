module Provisioner
  class Exit
    def self.with_message(msg)
      $stderr.puts "Error: #{msg}"
      $stderr.puts Provisioner::USAGE
      exit 1
    end
  end
end
