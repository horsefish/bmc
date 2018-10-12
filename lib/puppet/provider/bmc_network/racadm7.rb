require 'tempfile'
require 'puppet/util/inifile'
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'racadm', 'racadm.rb'))

Puppet::Type.type(:bmc_network).provide(:racadm7) do
  desc 'Manage BMC network via racadm7.'

  has_feature :racadm

  confine osfamily: [:redhat, :debian]
  confine exists: '/opt/dell/srvadmin/bin/idracadm7'

  mk_resource_methods

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  def self.prefetch(resources)
    resources.each_value do |type|
      racadm_out = Racadm.racadm_call(
        {
          bmc_username: type.value(:bmc_username),
          bmc_password: type.value(:bmc_password),
          bmc_server_host: type.value(:bmc_server_host),
        },
        ['get', 'iDRAC.IPv4'],
      )
      idrac_ipv4 = Racadm.parse_racadm racadm_out
      racadm_out = Racadm.racadm_call(
        {
          bmc_username: type.value(:bmc_username),
          bmc_password: type.value(:bmc_password),
          bmc_server_host: type.value(:bmc_server_host),
        },
        ['get', 'iDRAC.NIC'],
      )
      idrac_nic = Racadm.parse_racadm racadm_out

      type.provider = new(
        ipv4_ip_address: idrac_ipv4['Address'],
        ipv4_dns1: idrac_ipv4['DNS1'],
        ipv4_dns2: idrac_ipv4['DNS2'],
        ipv4_dns_from_dhcp: Bmc.boolean_to_symbol(Racadm.s_to_bool(idrac_ipv4['DNSFromDHCP'])),
        ipv4_gateway: idrac_ipv4['Gateway'],
        ipv4_netmask: idrac_ipv4['Netmask'],
        ip_source: Racadm.s_to_bool(idrac_ipv4['DHCPEnable']) ? :dhcp : :static,
        ipv4_enable: (Racadm.s_to_bool idrac_ipv4['Enable']),
        auto_config: (Racadm.s_to_bool idrac_nic['AutoConfig']),
        auto_detect: Bmc.boolean_to_symbol(Racadm.s_to_bool(idrac_nic['AutoDetect'])),
        autoneg: Bmc.boolean_to_symbol(Racadm.s_to_bool(idrac_nic['Autoneg'])),
        dedicated_nic_scan_time: idrac_nic['DedicatedNICScanTime'],
        dns_domain_from_dhcp: Bmc.boolean_to_symbol(Racadm.s_to_bool(idrac_nic['DNSDomainFromDHCP'])),
        dns_domain_name: idrac_nic['DNSDomainName'],
        dns_domain_name_from_dhcp: Bmc.boolean_to_symbol(Racadm.s_to_bool(idrac_nic['DNSDomainNameFromDHCP'])),
        dns_bmc_name: idrac_nic['DNSRacName'],
        dns_register: idrac_nic['DNSRegister'],
        duplex: idrac_nic['Duplex'],
        enable: Bmc.boolean_to_symbol(Racadm.s_to_bool(idrac_nic['Enable'])),
        failover: idrac_nic['Failover'],
        mtu: idrac_nic['MTU'],
        selection: idrac_nic['Selection'],
        shared_nic_scan_time: idrac_nic['SharedNICScanTime'],
        speed: idrac_nic['Speed'],
        vlan_enable: Bmc.boolean_to_symbol(Racadm.s_to_bool(idrac_nic['VLanEnable'])),
        vlan_id: idrac_nic['VLanID'],
        vlan_port: idrac_nic['VLANPort'],
        vlan_priority: idrac_nic['VLanPriority'],
      )
    end
  end

  def flush
    return unless @property_flush
    file = Tempfile.new('bmc_network')
    @ini_file = Puppet::Util::IniConfig::PhysicalFile.new(file.path)

    begin
      case resource[:ip_source]
      when :dhcp, 'dhcp'
        add_key_value_pair('iDRAC.IPv4', 'DHCPEnable', 'Enabled')
      when :static, 'static'
        add_key_value_pair('iDRAC.IPv4', 'DHCPEnable', 'Disabled')
        # when :none, 'none', :bios, 'bios'
        # Nothing to do
      end

      add_key_value_pair('iDRAC.IPv4', 'Address', resource[:ipv4_ip_address])
      add_key_value_pair('iDRAC.IPv4', 'DNS1', resource[:ipv4_dns1])
      add_key_value_pair('iDRAC.IPv4', 'DNS2', resource[:ipv4_dns2])
      add_key_value_pair('iDRAC.IPv4', 'DNSFromDHCP', Racadm.bool_to_s(resource[:ipv4_dns_from_dhcp]))
      add_key_value_pair('iDRAC.IPv4', 'Gateway', resource[:ipv4_gateway])
      add_key_value_pair('iDRAC.IPv4', 'Netmask', resource[:ipv4_netmask])
      add_key_value_pair('iDRAC.IPv4', 'Enable', resource[:ipv4_enable])

      add_key_value_pair('iDRAC.NIC', 'Enable', Racadm.bool_to_s(resource[:enable]))
      add_key_value_pair('iDRAC.NIC', 'DNSRacName', resource[:dns_bmc_name])
      add_key_value_pair('iDRAC.NIC', 'DNSDomainFromDHCP', Racadm.bool_to_s(resource[:dns_domain_from_dhcp]))
      add_key_value_pair('iDRAC.NIC', 'DNSDomainNameFromDHCP', Racadm.bool_to_s(resource[:dns_domain_name_from_dhcp]))
      add_key_value_pair('iDRAC.NIC', 'DNSDomainName', resource[:dns_domain_name])
      add_key_value_pair('iDRAC.NIC', 'AutoConfig', Racadm.bool_to_s(resource[:auto_config]))
      add_key_value_pair('iDRAC.NIC', 'AutoDetect', Racadm.bool_to_s(resource[:auto_detect]))
      add_key_value_pair('iDRAC.NIC', 'Autoneg', Racadm.bool_to_s(resource[:autoneg]))
      add_key_value_pair('iDRAC.NIC', 'DedicatedNICScanTime', resource[:dedicated_nic_scan_time])
      add_key_value_pair('iDRAC.NIC', 'Failover', resource[:failover])
      add_key_value_pair('iDRAC.NIC', 'MTU', resource[:mtu])
      add_key_value_pair('iDRAC.NIC', 'Selection', resource[:selection])
      add_key_value_pair('iDRAC.NIC', 'SharedNICScanTime', resource[:shared_nic_scan_time])
      add_key_value_pair('iDRAC.NIC', 'Speed', resource[:speed])
      add_key_value_pair('iDRAC.NIC', 'VLanEnable', Racadm.bool_to_s(resource[:vlan_enable]))
      add_key_value_pair('iDRAC.NIC', 'VLanID', resource[:vlan_id])
      add_key_value_pair('iDRAC.NIC', 'VLANPort', resource[:vlan_port])
      add_key_value_pair('iDRAC.NIC', 'VLanPriority', resource[:vlan_priority])

      @ini_file.store
      Racadm.racadm_call(resource, ['set', '-f', file.path])
    ensure
      file.close
      file.unlink
    end
  end

  def add_key_value_pair(section_name, key, value)
    section = @ini_file.get_section(section_name)
    section = @ini_file.add_section(section_name) if section.nil?
    section[key] = value
  end

  def ip_source=(value)
    @property_flush[:ip_source] = value
  end

  def ipv4_ip_address=(value)
    @property_flush[:ipv4_ip_address] = value
  end

  def ipv4_dns1=(value)
    @property_flush[:ipv4_dns1] = value
  end

  def ipv4_dns2=(value)
    @property_flush[:ipv4_dns2] = value
  end

  def ipv4_dns_from_dhcp=(value)
    @property_flush[:ipv4_dns_from_dhcp] = value
  end

  def ipv4_enable=(value)
    @property_flush[:ipv4_enable] = value
  end

  def ipv4_gateway=(value)
    @property_flush[:ipv4_gateway] = value
  end

  def ipv4_netmask=(value)
    @property_flush[:ipv4_netmask] = value
  end

  def auto_config=(value)
    @property_flush[:auto_config] = value
  end

  def auto_detect=(value)
    @property_flush[:auto_detect] = value
  end

  def autoneg=(value)
    @property_flush[:autoneg] = value
  end

  def dedicated_nic_scan_time=(value)
    @property_flush[:dedicated_nic_scan_time] = value
  end

  def dns_domain_from_dhcp=(value)
    @property_flush[:dns_domain_from_dhcp] = value
  end

  def dns_domain_name=(value)
    @property_flush[:dns_domain_name] = value
  end

  def dns_domain_name_from_dhcp=(value)
    @property_flush[:dns_domain_name_from_dhcp] = value
  end

  def dns_bmc_name=(value)
    @property_flush[:dns_bmc_name] = value
  end

  def enable=(value)
    @property_flush[:enable] = value
  end

  def failover=(value)
    @property_flush[:failover] = value
  end

  def mtu=(value)
    @property_flush[:mtu] = value
  end

  def selection=(value)
    @property_flush[:selection] = value
  end

  def shared_nic_scan_time=(value)
    @property_flush[:shared_nic_scan_time] = value
  end

  def speed=(value)
    @property_flush[:speed] = value
  end

  def vlan_enable=(value)
    @property_flush[:vlan_enable] = value
  end

  def vlan_id=(value)
    @property_flush[:vlan_id] = value
  end

  def vlan_port=(value)
    @property_flush[:vlan_port] = value
  end

  def vlan_priority=(value)
    @property_flush[:vlan_priority] = value
  end
end
