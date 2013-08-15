require 'spec_helper'

describe Provisioner::Configuration do

  let(:config) { Provisioner::Configuration.from_path('spec/fixtures/test.yml') }

  describe '#for_template' do
    let(:template_configuration) { config.for_template('memcached-sessions') }
    it 'returns a configuration for a template' do
      expect(template_configuration['image']).to eq('9ec5c0c-a941-11e2-a7dc-57a6b041988f')
    end

    it 'includes global configuration' do
      expect(template_configuration['environment']).to eq('test')
      expect(template_configuration['host_suffix']).to eq('test')
      expect(template_configuration['log_dir']).to eq('./tmp')
      expect(template_configuration['ssh_user']).to eq('ops')
    end
  end
end
