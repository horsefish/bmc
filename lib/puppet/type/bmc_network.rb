require 'resolv'

Puppet::Type.newtype(:bmc_network) do
  @doc = "A resource type to handle BMC LAN."

  feature :racadm, 'Dell racadmin specific.'

  newparam(:channel, :namevar => true) do
    desc 'Channel number network defaults to 1'
  end

  newproperty(:ipsrc) do
    desc 'The IP address source:
    - none unspecified
    - static manually configured static IP address
    - dhcp address obtained by BMC running DHCP
    - bios address loaded by BIOS or system software'
    newvalues(:static, :dhcp, :none, :bios)
    defaultto :dhcp
  end

  newproperty(:ipaddr) do
    desc 'The IP address for this channel.'
    validate do |value|
      unless value =~ Resolv::IPv4::Regex || value =~ Resolv::IPv6::Regex
        raise Puppet::Error, "%s is not a valid ip address" % value
      end
    end
  end

  newproperty(:gateway) do
    desc 'The default gateway IP address.'
    validate do |value|
      unless value =~ Resolv::IPv4::Regex || value =~ Resolv::IPv6::Regex
        raise Puppet::Error, "%s is not a valid ip address" % value
      end
    end
  end

  newproperty (:netmask) do
    desc 'The netmask for this channel.'
    validate do |value|
      unless value =~ Resolv::IPv4::Regex || value =~ Resolv::IPv6::Regex
        raise Puppet::Error, "%s is not a valid ip address" % value
      end
    end
  end

  newproperty(:dns1, :required_features => :racadm) do
    desc 'Static Preferred DNS Server'
    validate do |value|
      unless value =~ Resolv::IPv4::Regex || value =~ Resolv::IPv6::Regex
        raise Puppet::Error, "%s is not a valid ip address" % value
      end
    end
    defaultto '0.0.0.0'
  end

  newproperty(:dns2, :required_features => :racadm) do
    desc 'Static Alternate DNS Server'
    validate do |value|
      unless value =~ Resolv::IPv4::Regex || value =~ Resolv::IPv6::Regex
        raise Puppet::Error, "%s is not a valid ip address" % value
      end
    end
    defaultto '0.0.0.0'
  end

  newparam(:bmc_username) do
    desc 'username used to connect with bmc service. '
    defaultto 'root'
  end

  newparam(:bmc_password) do
    desc 'password used to connect with bmc service.'
  end

  newparam(:bmc_server_host) do
    desc 'RAC host address. Defaults to ipmitool lan print > IP Address'
    validate do |value|
      unless value =~ Resolv::IPv4::Regex || value =~ Resolv::IPv6::Regex
        raise Puppet::Error, "%s is not a valid ip address" % value
      end
    end
  end
end