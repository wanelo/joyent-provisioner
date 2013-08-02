require 'mixlib/cli'
require 'pry'

class Provisioner::CLI::Host < Provisioner::CLI

  banner 'Usage: provision host [options] --config config.yml'


  option :template,
         short: '-t TEMPLATE',
         long: '--template TEMPLATE',
         description: 'Template name',
         required: true

  option :number,
         short: '-n NUMBER',
         long: '--number NUMBER',
         description: 'Ruby range or a number for the host, ie 3 or 1..3 or [2,4,6]',
         required: false

  option :dry,
         long: '--dry-run',
         description: 'Dry runs and prints all commands without executing them',
         boolean: true,
         required: false

  option :help,
         short: '-h',
         long: '--help',
         description: 'Show this message',
         on: :tail,
         boolean: true,
         show_options: true,
         exit: 0

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