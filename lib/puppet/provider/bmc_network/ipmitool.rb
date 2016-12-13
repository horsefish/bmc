require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'ipmi', 'ipmitool.rb'))

Puppet::Type.type(:bmc_network).provide(:ipmitool) do
  confine :osfamily => [:redhat, :debian]
  defaultfor :osfamily => [:redhat, :debian]

  desc "Adminstrates network on BMC interface"

  commands :ipmitool => "ipmitool"

  def lan_print
    ipmitool_out = ipmitool('lan', 'print', resource[:channel])
    Ipmi::Ipmitool.parseLan(ipmitool_out)
  end

  def ipsrc
    lan_print['IP Address Source']
  end

  def ipsrc=(value)
    ipmitool('lan', 'set', resource[:channel], 'ipsrc', value)
  end

  def ipaddr
    lan_print['IP Address']
  end

  def ipaddr=(value)
    ipmitool('lan', 'set', resource[:channel], 'ipaddr', value)
  end

  def gateway
    lan_print['Default Gateway IP']
  end

  def gateway=(value)
    ipmitool('lan', 'set', resource[:channel], 'defgw', 'ipaddr', value)
  end

  def netmask
    lan_print['Subnet Mask']
  end

  def netmask=(value)
    ipmitool('lan', 'set', resource[:channel], 'netmask', value)
  end
end
