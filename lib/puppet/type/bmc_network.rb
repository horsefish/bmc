require "resolv"

Puppet::Type.newtype(:bmc_network) do
  @doc = "BMC user network type"

  require 'ipaddr'

  feature :racadm, 'Dell racadmin specific.'

  newparam(:channel, :namevar => true) do
    desc 'Channel number network defaults to 1'
  end

  newproperty(:ipsrc) do
    desc 'IP Address Source'
    newvalues(:static, :dhcp, :none, :bios)
    defaultto :dhcp
  end

  newproperty(:ipaddr) do
    desc 'Ip Address'
    validate do |value|
      unless (value =~ Resolv::IPv4::Regex || value =~ Resolv::IPv6::Regex)
        raise ArgumentError, "%s is not a valid ip address" % value
      end
    end
  end

  newproperty(:gateway) do
    desc 'Gateway'
    validate do |value|
      unless (value =~ Resolv::IPv4::Regex || value =~ Resolv::IPv6::Regex)
        raise ArgumentError, "%s is not a valid ip address" % value
      end
    end
  end

  newproperty (:netmask) do
    desc 'Subnet Mask'
    validate do |value|
      unless (value =~ Resolv::IPv4::Regex || value =~ Resolv::IPv6::Regex)
        raise ArgumentError, "%s is not a valid ip address" % value
      end
    end
  end

  newproperty(:dns1, :required_features => :racadm) do
    desc 'Static Preferred DNS Server'
    validate do |value|
      unless (value =~ Resolv::IPv4::Regex || value =~ Resolv::IPv6::Regex)
        raise ArgumentError, "%s is not a valid ip address" % value
      end
    end
    defaultto '0.0.0.0'
  end

  newproperty(:dns2, :required_features => :racadm) do
    desc 'Static Alternate DNS Server'
    validate do |value|
      unless (value =~ Resolv::IPv4::Regex || value =~ Resolv::IPv6::Regex)
        raise ArgumentError, "%s is not a valid ip address" % value
      end
    end
    defaultto '0.0.0.0'
  end

  newparam(:username, :required_features => :racadm) do
    desc 'username used to connect with bmc service.'
    defaultto 'root'
  end

  newparam(:password, :required_features => :racadm) do
    desc 'password used to connect with bmc service.'
  end

  newparam(:bmc_server_host, :required_features => :racadm) do
    desc 'RAC host address. Defaults to ipmitool lan print > IP Address'
    validate do |value|
      unless (value =~ Resolv::IPv4::Regex || value =~ Resolv::IPv6::Regex)
        raise ArgumentError, "%s is not a valid ip address" % value
      end
    end
  end
end