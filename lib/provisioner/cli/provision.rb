require 'mixlib/cli'
class Provisioner::CLI::Provision < Provisioner::CLI
  banner 'Usage: provisioner provision --config <path-to-config>.yml [options] '

  def provisioner_command(type = 'knife')
    command_class = type.capitalize
    provisioner = Kernel::const_get("Provisioner::Command::#{command_class}")

    @provisioner ||= provisioner.new(
      template_configuration.for_template(config[:template]), config
    )
  end

end
