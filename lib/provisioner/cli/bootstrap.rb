require 'mixlib/cli'
require 'pry'

class Provisioner::CLI::Bootstrap < Provisioner::CLI

  banner 'Usage: provisioner bootstrap --config <path-to-config>.yml [options] '

  def run(argv = ARGV)
    parse_options argv
    enable_logger if config[:debug]

    if config[:dry]
      provisioner_command.shell_commands.each do |command|
        puts command.colorize(:green)
      end
    else
      provisioner_command.run
    end
  end

  def provisioner_command
    Provisioner::Command::Bootstrap.new(template_configuration.for_template(config[:template]), config[:number])
  end

end
