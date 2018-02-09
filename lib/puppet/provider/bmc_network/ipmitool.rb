require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'ipmi', 'ipmitool.rb'))

Puppet::Type.type(:bmc_network).provide(:ipmitool) do
  desc 'Manage BMC network via ipmitool.'

  confine osfamily: [:redhat, :debian]

  commands ipmitool: 'ipmitool'

  mk_resource_methods

  def self.prefetch(resources)
    resources.each do |_key, type|
      ipmitool_out = ipmitool('lan', 'print', type.value(:channel))
      lan_print = Ipmitool.parse_lan(ipmitool_out)
      type.provider = new(
        channel: type.value(:channel),
        ip_source: lan_print['IP Address Source'],
        ipv4_ip_address: lan_print['IP Address'],
        ipv4_gateway: lan_print['Default Gateway IP'],
        ipv4_netmask: lan_print['Subnet Mask'],
      )
    end
  end

  def ip_source(value)
    ipmitool('lan', 'set', @property_hash[:channel], 'ipsrc', value)
  end

  def ipv4_ip_address(value)
    ipmitool('lan', 'set', @property_hash[:channel], 'ipaddr', value)
  end

  def ipv4_gateway(value)
    ipmitool('lan', 'set', @property_hash[:channel], 'defgw', 'ipaddr', value)
  end

  def ipv4_netmask(value)
    ipmitool('lan', 'set', @property_hash[:channel], 'netmask', value)
  end
end
