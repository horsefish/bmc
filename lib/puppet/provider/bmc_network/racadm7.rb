require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'racadm', 'racadm.rb'))

Puppet::Type.type(:bmc_network).provide(:racadm7) do

  desc "Manage BMC network via racadm7."

  has_feature :racadm

  confine :manufactor_id => :'674'
  confine :osfamily => [:redhat, :debian]
  confine :exists => '/opt/dell/srvadmin/bin/idracadm7'

  defaultfor :osfamily => [:redhat, :debian]

  mk_resource_methods

  def self.prefetch(resources)
    resources.each_value do |type|
      racadm_out = Racadm::Racadm.racadm_call(
          {
              :bmc_username => type.value(:bmc_username),
              :bmc_password => type.value(:bmc_password),
              :bmc_server_host => type.value(:bmc_server_host)
          },
          ['get', 'iDRAC.IPv4'])
      idrac_ipv4 = Racadm::Racadm.parse_racadm racadm_out
      racadm_out = Racadm::Racadm.racadm_call(
          {
              :bmc_username => type.value(:bmc_username),
              :bmc_password => type.value(:bmc_password),
              :bmc_server_host => type.value(:bmc_server_host)
          },
          ['get', 'iDRAC.NIC'])
      idrac_nic = Racadm::Racadm.parse_racadm racadm_out
      type.provider = new(
          :ipv4_ip_address => idrac_ipv4['Address'],
          :ip_source => (idrac_ipv4['DHCPEnable'].eql? 'Enabled') ? :dhcp : :static,
          :ipv4_dns1 => idrac_ipv4['DNS1'],
          :ipv4_dns2 => idrac_ipv4['DNS2'],
          :ipv4_dns_from_dhcp => (idrac_ipv4['DNSFromDHCP'].eql? 'Enabled').to_s,
          :ipv4_enable => (idrac_ipv4['Enable'].eql? 'Enabled').to_s,
          :ipv4_gateway => idrac_ipv4['Gateway'],
          :ipv4_netmask => idrac_ipv4['Netmask'],

          :auto_config => (idrac_nic['AutoConfig'].eql? 'Enabled').to_s,
          :auto_detect => (idrac_nic['AutoDetect'].eql? 'Enabled').to_s,
          :autoneg => (idrac_nic['Autoneg'].eql? 'Enabled').to_s,
          :dedicated_nic_scan_time => idrac_nic['DedicatedNICScanTime'],
          :dns_domain_from_dhcp => (idrac_nic['DNSDomainFromDHCP'].eql? ' Enabled').to_s,
          :dns_domain_name => idrac_nic['DNSDomainName'],
          :dns_domain_name_from_dhcp => (idrac_nic['DNSDomainNameFromDHCP'].eql? 'Enabled').to_s,
          :dns_bmc_name => idrac_nic['DNSRacName'],
          :dns_register => idrac_nic['DNSRegister'],
          :duplex => idrac_nic['Duplex'],
          :enable => (idrac_nic['Enable'].eql? 'Enabled').to_s,
          :failover => idrac_nic['Failover'],
          :mtu => idrac_nic['MTU'],
          :selection => idrac_nic['Selection'],
          :sharednic_scan_time => idrac_nic['SharedNICScanTime'],
          :speed => idrac_nic['Speed'],
          :vlan_enable => (idrac_nic['VLanEnable'].eql? 'Enabled').to_s,
          :vlan_id => idrac_nic['VLanID'],
          :vlan_port => idrac_nic['VLANPort'],
          :vlan_priority => idrac_nic['VLanPriority']
      )
    end
  end

  def ipv4_ip_address= value
    Racadm::Racadm.racadm_call(resource, ['set', 'iDRAC.IPv4.Address', value])
  end

  def ip_source= value
    case value
      when :dhcp, 'dhcp'
        Racadm::Racadm.racadm_call(resource, ['set', 'iDRAC.IPv4.DHCPEnable', 'Enabled'])
      when :static, 'static'
        Racadm::Racadm.racadm_call(resource, ['set', 'iDRAC.IPv4.DHCPEnable', 'Disabled'])
      when :none, 'none', :bios, 'bios'
        # Nothing to do
      else
        raise Puppet::Error, "Unknown ip_source: #{value}"
    end
  end

  def ipv4_dns1= value
    Racadm::Racadm.racadm_call(resource, ['set', 'iDRAC.IPv4.DNS1', value])
  end

  def ipv4_dns2= value
    Racadm::Racadm.racadm_call(resource, ['set', 'iDRAC.IPv4.DNS2', value])
  end

  def ipv4_dns_from_dhcp= value
    Racadm::Racadm.racadm_call(resource, ['set', 'iDRAC.IPv4.DNSFromDHCP', Racadm::Racadm.bool_to_s(value)])
  end

  def ipv4_enable= value
    Racadm::Racadm.racadm_call(resource, ['set', 'iDRAC.IPv4.Enable', Racadm::Racadm.bool_to_s(value)])
  end

  def ipv4_gateway= value
    Racadm::Racadm.racadm_call(resource, ['set', 'iDRAC.IPv4.Gateway', value])
  end

  def ipv4_netmask= value
    Racadm::Racadm.racadm_call(resource, ['set', 'iDRAC.IPv4.Netmask', value])
  end

  def auto_config= value
    Racadm::Racadm.racadm_call(resource, ['set', 'iDRAC.NIC.AutoConfig', Racadm::Racadm.bool_to_s(value)])
  end

  def auto_detect= value
    Racadm::Racadm.racadm_call(resource, ['set', 'iDRAC.NIC.AutoDetect', Racadm::Racadm.bool_to_s(value)])
  end

  def autoneg= value
    Racadm::Racadm.racadm_call(resource, ['set', 'iDRAC.NIC.Autoneg', Racadm::Racadm.bool_to_s(value)])
  end

  def dedicated_nic_scan_time= value
    Racadm::Racadm.racadm_call(resource, ['set', 'iDRAC.NIC.DedicatedNICScanTime', value])
  end

  def dns_domain_from_dhcp= value
    Racadm::Racadm.racadm_call(
        resource, ['set', 'iDRAC.NIC.DNSDomainFromDHCP', Racadm::Racadm.bool_to_s(value)])
  end

  def dns_domain_name= value
    Racadm::Racadm.racadm_call(resource, ['set', 'iDRAC.NIC.DNSDomainName', value])
  end

  def dns_domain_name_from_dhcp= value
    Racadm::Racadm.racadm_call(
        resource, ['set', 'iDRAC.NIC.DNSDomainNameFromDHCP', Racadm::Racadm.bool_to_s(value)])
  end

  def dns_bmc_name= value
    Racadm::Racadm.racadm_call(resource, ['set', 'iDRAC.NIC.DNSRacName', value])
  end

  def enable= value
    Racadm::Racadm.racadm_call(resource, ['set', 'iDRAC.NIC.Enable', Racadm::Racadm.bool_to_s(value)])
  end

  def failover= value
    Racadm::Racadm.racadm_call(resource, ['set', 'iDRAC.NIC.Failover', value])
  end

  def mtu= value
    Racadm::Racadm.racadm_call(resource, ['set', 'iDRAC.NIC.MTU', value])
  end

  def selection= value
    Racadm::Racadm.racadm_call(resource, ['set', 'iDRAC.NIC.Selection', value])
  end

  def sharednic_scan_time= value
    Racadm::Racadm.racadm_call(resource, ['set', 'iDRAC.NIC.SharedNICScanTime', value])
  end

  def speed= value
    Racadm::Racadm.racadm_call(resource, ['set', 'iDRAC.NIC.Speed', value])
  end

  def vlan_enable= value
    Racadm::Racadm.racadm_call(resource, ['set', 'iDRAC.NIC.VLanEnable', Racadm::Racadm.bool_to_s(value)])
  end

  def vlan_id= value
    Racadm::Racadm.racadm_call(resource, ['set', 'iDRAC.NIC.VLanID', value])
  end

  def vlan_port= value
    Racadm::Racadm.racadm_call(resource, ['set', 'iDRAC.NIC.VLANPort', value])
  end

  def vlan_priority= value
    Racadm::Racadm.racadm_call(resource, ['set', 'iDRAC.NIC.VLanPriority', value])
  end

end
