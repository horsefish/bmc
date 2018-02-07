require 'resolv'
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'puppet_x', 'bmc.rb'))

Puppet::Type.newtype(:bmc_network) do
  @doc = 'A resource type to handle BMC LAN.'

  feature :racadm, 'Dell racadmin specific.'

  newparam(:name, namevar: true) do
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
  end

  newproperty(:ipv4_ip_address) do
    desc 'The IPv4 address for the bmc.'
    validate do |value|
      unless value =~ Resolv::IPv4::Regex
        raise Puppet::Error, '%s is not a valid ip address' % value
      end
    end
  end

  newproperty(:ipv4_gateway) do
    desc 'The default gateway IPv4 address.'
    validate do |value|
      unless value =~ Resolv::IPv4::Regex
        raise Puppet::Error, '%s is not a valid ip address' % value
      end
    end
  end

  newproperty(:ipv4_netmask) do
    desc 'The netmask for bmc ipv4 network.'
    validate do |value|
      unless value =~ Resolv::IPv4::Regex
        raise Puppet::Error, '%s is not a valid ip address' % value
      end
    end
  end

  newproperty(:ipv4_dns1, required_features: :racadm) do
    desc 'Static Preferred DNS Server'
    validate do |value|
      unless value =~ Resolv::IPv4::Regex
        raise Puppet::Error, '%s is not a valid ip address' % value
      end
    end
  end

  newproperty(:ipv4_dns2, required_features: :racadm) do
    desc 'Static Alternate DNS Server'
    validate do |value|
      unless value =~ Resolv::IPv4::Regex
        raise Puppet::Error, '%s is not a valid ip address' % value
      end
    end
  end

  newproperty(:ipv4_dns_from_dhcp, required_features: :racadm) do
    desc 'Select this option to obtain Primary and Secondary DNS server addresses from DHCPv4 server.
        If DHCP is not used to obtain the DNS server addresses,
        provide the IP addresses in the Preferred DNS Server and Alternate DNS Server fields.'
    newvalues(:true, :false)
  end

  newproperty(:ipv4_enable, required_features: :racadm) do
    desc 'enable IPv4 protocol support.'
    newvalues(:true, :false)
  end

  newproperty(:dns_domain_name, required_features: :racadm) do
    desc 'In the DNS domain name, parameter is only valid if dns_domain_from_dhcp is set to false.'
    validate do |value|
      if value.length >= 255
        raise Puppet::Error, '%s f up to 254 ASCII characters. At least one of the characters '\
                             'must be alphabetic. Characters are restricted to alphanumeric, '\
                             '\'-\', and \'.\'.' % value
      end
    end
  end

  newproperty(:dns_bmc_name, required_features: :racadm) do
    desc 'The bmc dns name'
    validate do |value|
      raise Puppet::Error, '%s String of up to 63 ASCII characters' % value if value.length >= 64
    end
  end

  newproperty(:enable, required_features: :racadm) do
    desc 'Enables or Disables the bmc network interface controller.'
    newvalues(:true, :false)
    defaultto :true
  end

  newproperty(:dns_domain_from_dhcp, required_features: :racadm) do
    desc 'Specifies that the bmc DNS domain name must be assigned from the network DHCP server.'
    newvalues(:true, :false)
  end

  newproperty(:dns_domain_name_from_dhcp, required_features: :racadm) do
    desc 'Specifies that the bmc DNS domain name must be assigned from the network DHCP server.'
    newvalues(:true, :false)
  end

  newproperty(:auto_config, required_features: :racadm) do
    desc 'Select this option to enable iDRAC to obtain the IPv6 address for the iDRAC NIC from the DHCPv6 server.
          You can configure both static and dynamic IP addresses.'
    newvalues(:true, :false)
  end

  newproperty(:auto_detect, required_features: :racadm) do
    desc 'Enable DHCP Provisionin.'
    newvalues(:true, :false)
  end

  newproperty(:autoneg, required_features: :racadm) do
    desc 'Determines if iDRAC automatically sets the duplex mode and network speed by communicating
          with the nearest router or hub (On) or allows you to set them manually..'
    newvalues(:true, :false)
    defaultto :true
  end

  newproperty(:dedicated_nic_scan_time, required_features: :racadm) do
    desc ''
  end

  newproperty(:failover, required_features: :racadm) do
    desc 'If the NIC selection setting fails, then the traffic is routed over through the failover network.'
  end

  newproperty(:mtu, required_features: :racadm) do
    desc 'Enter the Maximum Transmission Unit (MTU) size on the NIC.'
  end

  newproperty(:selection, required_features: :racadm) do
    desc 'Select one of the following modes to configure the NIC as the primary interface in shared mode.'
  end

  newproperty(:shared_nic_scan_time, required_features: :racadm) do
    desc ''
  end

  newproperty(:speed, required_features: :racadm) do
    desc 'Select the network speed to match your network environment.'
  end

  newproperty(:vlan_enable, required_features: :racadm) do
    desc 'elect this option to enable VLAN ID. Only matched Virtual LAN (VLAN) ID traffic is accepted.
          Clear this option to disable VLAN ID.'
    newvalues(:true, :false)
  end

  newproperty(:vlan_id, required_features: :racadm) do
    desc 'Determines the VLAN ID field of 802.1g fields. Enter a valid value for VLAN ID.'
  end

  newproperty(:vlan_port, required_features: :racadm) do
    desc 'Enter the Maximum Transmission Unit (MTU) size on the NIC.'
  end

  newproperty(:vlan_priority, required_features: :racadm) do
    desc 'Determines the priority field of 802.1g fields.
          Enter a number from 0 to 7 to set the priority of the VLAN ID.'
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
        raise Puppet::Error, '%s is not a valid ip address' % value
      end
    end
  end
end
