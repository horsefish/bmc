require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'ipmi', 'ipmitool.rb'))

Puppet::Type.type(:bmc_network).provide(:ipmitool) do
  confine :osfamily => [:redhat, :debian]
  defaultfor :osfamily => [:redhat, :debian]

  desc "Adminstrates network on BMC interface"

  commands :ipmitool => "ipmitool"

  mk_resource_methods

  def initialize(value={})
    super(value)
    #This is to overcome the that namevar doesn't support defaultto
    if value.name.to_s == value.title.to_s
      channel = 1
    else
      channel = value.name
    end
    ipmitool_out = ipmitool('lan', 'print', channel)
    lanPrint =  Ipmi::Ipmitool.parseLan(ipmitool_out)
    @property_hash[:channel] = channel
    @property_hash[:ipsrc] = lanPrint['IP Address Source']
    @property_hash[:ipaddr] = lanPrint['IP Address']
    @property_hash[:gateway] = lanPrint['Default Gateway IP']
    @property_hash[:netmask] = lanPrint['Subnet Mask']
  end

  def ipsrc=(value)
    ipmitool('lan', 'set', @property_hash[:channel], 'ipsrc', value)
  end

  def ipaddr=(value)
    ipmitool('lan', 'set', @property_hash[:channel], 'ipaddr', value)
  end

  def gateway=(value)
    ipmitool('lan', 'set', @property_hash[:channel], 'defgw', 'ipaddr', value)
  end

  def netmask=(value)
    ipmitool('lan', 'set', @property_hash[:channel], 'netmask', value)
  end
end
