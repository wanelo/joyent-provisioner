require 'mixlib/cli'
require 'pry'

class Provisioner::CLI::Provision < Provisioner::CLI
  banner 'Usage: provisioner provision --config <path-to-config>.yml [options] '

  def provisioner_command
    Provisioner::Command::Provision.new(template_configuration.for_template(config[:template]), config)
  end

end
