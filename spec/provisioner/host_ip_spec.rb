require 'spec_helper'

describe Provisioner::HostIP do
  describe '.ip_for' do
    let(:header) { "ID                                    Name                                    State    Type            Image                        Flavor                        IPs                                   RAM      Disk  Tags\n" }
    let(:server001) { "a67c6340-4bf4-11e3-8f96-0800200c9a66 app001.stage running   smartmachine   sdc:sdc:base64:13.1.0    g3-highmemory-17.125-smartos 1.1.1.1   17.12 GB    420 GB\n" }
    let(:server002) { "eb332d70-4bf4-11e3-8f96-0800200c9a66 app002.stage running smartmachine  sdc:sdc:base64:13.1.0   g3-highmemory-17.125-smartos 1.1.1.2   17.12 GB    420 GB\n" }
    let(:server003) { "eb332d70-4bf4-11e3-8f96-0800200c9a66 app003.stage running smartmachine   sdc:sdc:base64:13.1.0   g3-highmemory-17.125-smartos 1.1.1.3,1.1.1.4   17.12 GB    420 GB\n" }
    let(:servers) { [header, server001, server002, server003].join }

    before do
      double_cmd('knife joyent server list', puts: servers)
    end

    it 'returns the IP address given a hostname' do
      expect(Provisioner::HostIP.ip_for('app001.stage')).to eq('1.1.1.1')
      expect(Provisioner::HostIP.ip_for('app002.stage')).to eq('1.1.1.2')
    end

    context 'server has multiple IPs' do
      it 'returns the first IP' do
        expect(Provisioner::HostIP.ip_for('app003.stage')).to eq('1.1.1.3')
      end
    end
  end
end
