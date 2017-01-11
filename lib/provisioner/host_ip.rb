require 'yaml'

module Provisioner
  class HostIP
    def self.ip_for(host)
      Provisioner::Exit.with_message("Unable to find IP for host: #{host}\nMake sure 'knife joyent server list' runs successfully\n\n") unless ips[host]
      ips[host]
    end

    private

    def self.ips
      @ips = {}
      server_list.each do |server|
        # example line
        # c1cdc4a3-366d-690a-a56f-8c0968a5fb23  twemproxy305.prod  running  smartmachine g4-highcpu-4G  10.100.18.240 4.00 GB 100 GB

        # 4330e738-2bca-ee10-f9a6-e9a1b3fcfdec  vpn001.prod running  virtualmachine  sdc:jpc:ubuntu-12.04:2.4.  g3-highcpu-1.75-kvm  9.12.42.172,10.100.114.217  1.75 GB  75 GB
        zone, hostname, status, type, flavor, ips = server.split(/\s+/).compact
        next if ips.nil?
        @ips[hostname] = (ips.split(',') || []).first
      end
      @ips
    end

    def self.server_list
      @server_list ||= `knife joyent server list | tail -n +2 | grep -v "Total  "`.split("\n")
    end
  end
end
