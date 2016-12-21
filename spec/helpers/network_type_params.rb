module Helpers
  def network_type_params(name: 'test', ipsrc: 'static', ipaddr: '10.10.10.10', gateway: '10.10.10.254', netmask: '255.255.255.0', channel: 1, provider_name: 'ipmitool')
    {
        :name => name,
        :ipsrc => ipsrc,
        :ipaddr => ipaddr,
        :gateway => gateway,
        :netmask => netmask,
        :channel => channel,
        :provider => provider_name
    }
  end
end
