require_relative 'cli'
module Provisioner
  USAGE = <<-EOF

Usage:
  [bundle exec] provisioner command ...

Where the command is one of the following:
  #{Provisioner::CLI.supported_commands.join(', ')}
EOF
end
