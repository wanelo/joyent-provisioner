require 'yaml'

module Provisioner
  class HostIP
    def self.ip_for(host)
      ips[host]
    end

    private

    def self.ips
      @ips = {}
      server_list.each do |server|
        hostname, ip = server.split(' ')
        @ips[hostname] = ip
      end
      @ips
    end

    def self.server_list
      `knife joyent server list | awk '{print $2 " " $6}' | tail +2`.split("\n")
    end
  end
end