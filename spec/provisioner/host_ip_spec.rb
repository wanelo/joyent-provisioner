require 'spec_helper'

describe Provisioner::HostIP do

  before do
    Provisioner::HostIP.stub(:server_list){ ['app001.stage 1.1.1.1', 'app002.stage 1.1.1.2']}
  end


  describe '.ip_for' do
    it 'returns the IP address given a hostname' do
      expect(Provisioner::HostIP.ip_for('app001.stage')).to eq('1.1.1.1')
    end
  end
end
