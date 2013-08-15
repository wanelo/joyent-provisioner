require 'spec_helper'

describe Provisioner::Command::Bootstrap do
  describe '#shell_commands' do
    context 'host is specified' do

      let(:subject) { Provisioner::Command::Bootstrap.new(template_configuration, '1') }

      let(:template_configuration) { {
          image: '9ec5c0c-a941-11e2-a7dc-57a6b041988f',
          flavor: 'g3-highmemory-17.125-smartos',
          distro: 'smartos-base64',
          networks: '42325ea0-eb62-44c1-8eb6-0af3e2f83abc,c8cde927-6277-49ca-82a3-741e8b23b02f',
          host_sequence: '1..2',
          host_suffix: 'test',
          host_presuffix: 'c1',
          host_prefix: 'memcached-sessions',
          environment: 'test',
          log_dir: './tmp',
          run_list: 'role[joyent]',
          ssh_user: 'ops'
      } }

      let(:expected_bootstrap_command) { [
          'knife bootstrap 1.2.3.4',
          '--distro smartos-base64',
          '--environment test',
          '--node-name memcached-sessions001.c1.test',
          '--run-list role[joyent]',
          '--ssh-user ops',
          '2>&1 > ./tmp/memcached-sessions001.c1.test_provision.log &'
      ].join(' ') }

      it 'returns command string' do
        Provisioner::Command::Bootstrap::HostCommand.any_instance.stub(:ip_for_host) { '1.2.3.4' }
        shell_commands = subject.shell_commands

        expect(shell_commands[0]).to eq("ssh 1.2.3.4 -l ops 'sudo rm -rf /etc/chef'")
        expect(shell_commands[1]).to eq(expected_bootstrap_command)
      end
    end
  end
end

