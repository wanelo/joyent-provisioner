require 'mixlib/cli'
require 'pry'

class Provisioner::CLI::Host < Provisioner::CLI

  banner 'Usage: provision [options] --config config.yml'

  def run(argv = ARGV)
    parse_options argv
    enable_logger if config[:debug]

    if config[:dry]
      puts provisioner_command.shell_commands
    else
      provisioner_command.run
    end
  end

  def provisioner_command
    Provisioner::Command::Host.new(template_configuration.for_template(config[:template]), config[:number])
  end

end