require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'puppet_x', 'bmc.rb'))
require 'resolv'

Puppet::Type.newtype(:bmc_network) do
  @doc = "A resource type to handle BMC LAN."

  feature :racadm, 'Dell racadmin specific.'

  newparam(:name, :namevar => true) do
    desc 'Identification of network'
  end

  newparam(:channel) do
    desc 'IPMI network channel number defaults to 1'
    defaultto 1
  end

  newproperty(:ip_source) do
    desc 'The IP address source:
    - none unspecified
    - static manually configured static IP address
    - dhcp address obtained by BMC running DHCP
    - bios address loaded by BIOS or system software'
    newvalues(:static, :dhcp, :none, :bios)
    defaultto :dhcp
  end

  newproperty(:ipv4_ip_address) do
    desc 'The IPv4 address for the bmc.'
    validate do |value|
      unless value =~ Resolv::IPv4::Regex || value =~ Resolv::IPv6::Regex
        raise Puppet::Error, "%s is not a valid ip address" % value
      end
    end
  end

  newproperty(:ipv4_gateway) do
    desc 'The default gateway IPv4 address.'
    validate do |value|
      unless value =~ Resolv::IPv4::Regex || value =~ Resolv::IPv6::Regex
        raise Puppet::Error, "%s is not a valid ip address" % value
      end
    end
  end

  newproperty (:ipv4_netmask) do
    desc 'The netmask for bmc ipv4 network.'
    validate do |value|
      unless value =~ Resolv::IPv4::Regex || value =~ Resolv::IPv6::Regex
        raise Puppet::Error, "%s is not a valid ip address" % value
      end
    end
  end

  newproperty(:ipv4_dns1, :required_features => :racadm) do
    desc 'Static Preferred DNS Server'
    validate do |value|
      unless value =~ Resolv::IPv4::Regex || value =~ Resolv::IPv6::Regex
        raise Puppet::Error, "%s is not a valid ip address" % value
      end
    end
    defaultto '0.0.0.0'
  end

  newproperty(:ipv4_dns2, :required_features => :racadm) do
    desc 'Static Alternate DNS Server'
    validate do |value|
      unless value =~ Resolv::IPv4::Regex || value =~ Resolv::IPv6::Regex
        raise Puppet::Error, "%s is not a valid ip address" % value
      end
    end
    defaultto '0.0.0.0'
  end

  newproperty(:dns_domain_name, :required_features => :racadm) do
    desc 'In the DNS domain name, parameter is only valid if dns_domain_from_dhcp is set to false.'
    validate do |value|
      raise Puppet::Error, "%s f up to 254 ASCII characters. At least one of the characters " +
          "must be alphabetic. Characters are restricted to alphanumeric, " +
          " '-', and '.'." % value if value.length >= 255
    end
  end

  newproperty(:dns_bmc_name, :required_features => :racadm) do
    desc 'The bmc dns name'
    validate do |value|
      raise Puppet::Error, "%s String of up to 63 ASCII characters" % value if value.length >= 64
    end
  end

  newproperty(:enable, :boolean => true, :required_features => :racadm) do
    desc 'Enables or Disables the bmc network interface controller.'
    defaultto true
    munge { |value| Bmc.munge_boolean(value) }
  end

  newproperty(:dns_domain_from_dhcp, :boolean => true, :required_features => :racadm) do
    desc 'Specifies that the bmc DNS domain name must be assigned from the network DHCP server.'
    defaultto false
    munge { |value| Bmc.munge_boolean(value) }
  end

  newproperty(:dns_domain_name_from_dhcp, :boolean => true, :required_features => :racadm) do
    desc 'Specifies that the bmc DNS domain name must be assigned from the network DHCP server.'
    defaultto false
    munge { |value| Bmc.munge_boolean(value) }
  end

  newparam(:bmc_username) do
    desc 'username used to connect with bmc service.'
  end

  newparam(:bmc_password) do
    desc 'password used to connect with bmc service.'
  end

  newparam(:bmc_server_host) do
    desc 'bmc host address.'
    validate do |value|
      unless value =~ Resolv::IPv4::Regex || value =~ Resolv::IPv6::Regex
        raise Puppet::Error, "%s is not a valid ip address" % value
      end
    end
  end
end