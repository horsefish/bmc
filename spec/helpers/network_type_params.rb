module Helpers
  def network_type_params(name: 'test', ip_source: 'static', ipv4_ip_address: '10.10.10.10', ipv4_gateway: '10.10.10.254', ipv4_netmask: '255.255.255.0', channel: 1, provider_name: 'ipmitool')
    if provider_name == ''
      {
          :name => name,
          :ip_source => ip_source,
          :ipv4_ip_address => ipv4_ip_address,
          :ipv4_gateway => ipv4_gateway,
          :ipv4_netmask => ipv4_netmask,
          :channel => channel,
      }
    else
      {
          :name => name,
          :ip_source => ip_source,
          :ipv4_ip_address => ipv4_ip_address,
          :ipv4_gateway => ipv4_gateway,
          :ipv4_netmask => ipv4_netmask,
          :channel => channel,
          :provider => provider_name
      }
    end
  end
end
