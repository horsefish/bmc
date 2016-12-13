require "resolv"

Puppet::Type.newtype(:bmc_network) do
  @doc = "BMC user network type"

  require 'ipaddr'

  feature :racadm, 'Dell racadmin specific.'

  newparam(:name, :namevar => true) do
    desc 'An arbitrary name used as the identity of the resource.'
  end

  newproperty(:ipsrc) do
    desc 'IP Address Source'
    newvalues(:static, :dhcp, :none, :bios)
    defaultto :dhcp
  end

  newproperty(:ipaddr) do
    desc 'Ip Address'
    validate do |value|
      raise ArgumentError, "%s is not a valid ip address" % value unless (value =~ Resolv::IPv4::Regex || value =~ Resolv::IPv6::Regex)
    end
  end

  newproperty(:gateway) do
    desc 'Gateway'
    validate do |value|
      raise ArgumentError, "%s is not a valid gateway" % value unless (value =~ Resolv::IPv4::Regex || value =~ Resolv::IPv6::Regex)
    end
  end

  newproperty (:netmask) do
    desc 'Subnet Mask'
    validate do |value|
      raise ArgumentError, "%s is not a valid subnet mask" % value unless (value =~ Resolv::IPv4::Regex || value =~ Resolv::IPv6::Regex)
    end
  end

  newparam(:channel) do
    desc 'Channel number network is on, default to 1'
    defaultto 1
  end

=begin
  newparam(:dns1, :required_features => :racadm) do
    desc 'Static Preferred DNS Server'
    validate do |value|
      raise ArgumentError, "%s is not a valid ip address" % value unless (value =~ Resolv::IPv4::Regex || value =~ Resolv::IPv6::Regex)
    end
    defaultto '0.0.0.0'
  end
=end

end