require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'ipmi', 'ipmitool.rb'))

Puppet::Type.type(:bmc_network).provide(:ipmitool) do

  desc "Manage BMC network via ipmitool."

  confine :osfamily => [:redhat, :debian]
  defaultfor :osfamily => [:redhat, :debian]

  commands :ipmitool => 'ipmitool'

  mk_resource_methods

  def initialize(value={})
    super(value)
    #This is to overcome that namevar doesn't support defaultto
    if value.name.to_s == value.title.to_s
      channel = 1
    else
      channel = value.name
    end
    ipmitool_out = ipmitool('lan', 'print', channel)
    lan_print =  Ipmi::Ipmitool.parseLan(ipmitool_out)
    @property_hash[:channel] = channel
    @property_hash[:ipsrc] = lan_print['IP Address Source']
    @property_hash[:ipaddr] = lan_print['IP Address']
    @property_hash[:gateway] = lan_print['Default Gateway IP']
    @property_hash[:netmask] = lan_print['Subnet Mask']
  end

  def ipsrc=value
    ipmitool('lan', 'set', @property_hash[:channel], 'ipsrc', value)
  end

  def ipaddr=value
    ipmitool('lan', 'set', @property_hash[:channel], 'ipaddr', value)
  end

  def gateway=value
    ipmitool('lan', 'set', @property_hash[:channel], 'defgw', 'ipaddr', value)
  end

  def netmask=value
    ipmitool('lan', 'set', @property_hash[:channel], 'netmask', value)
  end
end
