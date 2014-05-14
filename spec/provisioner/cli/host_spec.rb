
require 'spec_helper'

describe 'provision cli' do
  let(:provision_path) { 'bin' }

  def execute(command)
    `#{provision_path}/#{command} --dry-run`.strip
  end

  describe 'host number is provided' do
    let(:expected_command) {'knife joyent server create --image 9ec5c0c-a941-11e2-a7dc-57a6b041988f --flavor g3-highmemory-17.125-smartos --distro smartos-base64 --networks 42325ea0-eb62-44c1-8eb6-0af3e2f83abc,c8cde927-6277-49ca-82a3-741e8b23b02f --environment test --node-name memcached-sessions545.test --run-list role[joyent] 2>&1 > ./tmp/memcached-sessions545.test_provision.log &'}
    it 'reads the configuration and generates command from memcached-sessions' do
      result = execute('provisioner provision --number 545 --config conf/configuration.yml.example --template memcached-sessions')
      expect(result).to eq(expected_command)
    end

    it 'accepts short options' do
      result = execute('provisioner provision -n 545 -c conf/configuration.yml.example -t memcached-sessions')
      expect(result).to eq(expected_command)
    end

    let(:expected_command_ssh) {'knife joyent server create --image 9ec5c0c-a941-11e2-a7dc-57a6b041988f --flavor g3-highmemory-17.125-smartos --distro smartos-base64 --networks 42325ea0-eb62-44c1-8eb6-0af3e2f83abc,c8cde927-6277-49ca-82a3-741e8b23b02f --environment test --node-name memcached-sessions-ssh545.test --run-list role[joyent] --ssh-user ops 2>&1 > ./tmp/memcached-sessions-ssh545.test_provision.log &'}
    it 'reads the configuration and generates command from memcached-sessions2' do
      result = execute('provisioner provision --number 545 --config conf/configuration.yml.example --template memcached-sessions-ssh')
      expect(result).to eq(expected_command_ssh)
    end


  end

  describe 'host number is not provided' do
    it 'returns a command per host' do
      result = execute('provisioner provision --config conf/configuration.yml.example --template memcached-sessions')
      commands = result.split("\n")
      expect(commands.size).to eq(2)
      expect(commands[0]).to include('memcached-sessions001.test')
      expect(commands[1]).to include('memcached-sessions002.test')
    end
  end
end


