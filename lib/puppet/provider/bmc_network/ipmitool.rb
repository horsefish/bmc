require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'ipmi', 'ipmitool.rb'))

Puppet::Type.type(:bmc_network).provide(:ipmitool) do

  desc "Manage BMC network via ipmitool."

  confine :osfamily => [:redhat, :debian]
  defaultfor :osfamily => [:redhat, :debian]

  commands :ipmitool => 'ipmitool'

  mk_resource_methods

  def self.prefetch(resources)
    resources.each do |key, type|
      ipmitool_out = ipmitool('lan', 'print', key)
      lan_print = Ipmi::Ipmitool.parseLan(ipmitool_out)
      type.provider = new(
          :channel => key,
          :ipsrc => lan_print['IP Address Source'],
          :ipaddr => lan_print['IP Address'],
          :gateway => lan_print['Default Gateway IP'],
          :netmask => lan_print['Subnet Mask']
      )
    end
  end

  def ipsrc= value
    ipmitool('lan', 'set', @property_hash[:channel], 'ipsrc', value)
  end

  def ipaddr= value
    ipmitool('lan', 'set', @property_hash[:channel], 'ipaddr', value)
  end

  def gateway= value
    ipmitool('lan', 'set', @property_hash[:channel], 'defgw', 'ipaddr', value)
  end

  def netmask= value
    ipmitool('lan', 'set', @property_hash[:channel], 'netmask', value)
  end
end
