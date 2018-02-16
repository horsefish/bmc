require 'spec_helper'
require 'puppet_x/ipmi/ipmitool'

def user_params(id: nil, name: nil, callin: :true, link_auth: :true, ipmi_msg: :true, channel_priv_limit: 'NO ACCESS')
  {
    id: id,
    name: name,
    callin: callin,
    link_auth: link_auth,
    ipmi_msg: ipmi_msg,
    channel_priv_limit: channel_priv_limit,
  }
end

describe Ipmitool do
  let(:dell_lan_print) do
    output = File.join(File.dirname(__FILE__), '..', '..', '..', 'fixtures', 'bmc', 'dell_ipmitool_lan_print.txt')
    IO.read(output)
  end
  let(:dell_lan_print_reboot) do
    output = File.join(File.dirname(__FILE__), '..', '..', '..', 'fixtures', 'bmc', 'dell_ipmitool_lan_print_reboot.txt')
    IO.read(output)
  end
  let(:ibm_lan_print) do
    output = File.join(File.dirname(__FILE__), '..', '..', '..', 'fixtures', 'bmc', 'ibm_ipmitool_lan_print.txt')
    IO.read(output)
  end
  let(:hp_lan_print) do
    output = File.join(File.dirname(__FILE__), '..', '..', '..', 'fixtures', 'bmc', 'hp_ipmitool_lan_print.txt')
    IO.read(output)
  end
  let(:dell_ipmitool_user_list_1) do
    output = File.join(File.dirname(__FILE__), '..', '..', '..', 'fixtures', 'bmc', 'dell_ipmitool_user_list_1.csv')
    IO.read(output)
  end
  let(:dell_ipmitool_user_list_2) do
    output = File.join(File.dirname(__FILE__), '..', '..', '..', 'fixtures', 'bmc', 'dell_ipmitool_user_list_2.txt')
    IO.read(output)
  end
  let(:dell_ipmitool_user_list_3) do
    output = File.join(File.dirname(__FILE__), '..', '..', '..', 'fixtures', 'bmc', 'dell_ipmitool_user_list_3.txt')
    IO.read(output)
  end
  let(:ibm_ipmitool_user_summery_1) do
    output = File.join(File.dirname(__FILE__), '..', '..', '..', 'fixtures', 'bmc', 'dell_ipmitool_user_summary_1.csv')
    IO.read(output)
  end

  context 'IBM ipmitool user summery' do
    subject { described_class.parse_user_summay_csv ibm_ipmitool_user_summery_1 }

    it do
      is_expected.not_to be_empty
    end
    it do
      is_expected.to include(
        max_count: "16",
        enabled_count: '1',
        fixed_count: '1',
      )
    end
  end

  context 'DELL ipmitool lan print' do
    subject { described_class.parse_lan dell_lan_print }

    it do
      is_expected
        .to include(
          'Auth Type Support' => 'MD5',
          'IP Address Source' => 'static',
          'IP Address' => '10.10.10.10',
          'Subnet Mask' => '255.255.255.0',
          'MAC Address' => '18:fb:7b:9b:57:27',
          'SNMP Community String' => 'public',
          'IP Header' => 'TTL=0x40 Flags=0x40 Precedence=0x00 TOS=0x10',
          'BMC ARP Control' => 'ARP Responses Enabled, Gratuitous ARP Disabled',
          'Gratituous ARP Intrvl' => '2.0 seconds',
          'Default Gateway IP' => '10.10.10.254',
          'Default Gateway MAC' => '00:00:00:00:00:00',
          'Backup Gateway IP' => '0.0.0.0',
          'Backup Gateway MAC' => '00:00:00:00:00:00',
          '802.1q VLAN ID' => 'Disabled',
          '802.1q VLAN Priority' => '0',
          'RMCP+ Cipher Suites' => '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14',
          'Cipher Suite Priv Max' => 'Xaaaaaaaaaaaaaa',
        )
    end
    it do
      is_expected.to include('Auth Type Enable')
    end
  end
  context 'DELL ipmitool lan print reboot' do
    subject { described_class.parse_lan dell_lan_print_reboot }

    it do
      is_expected
        .to include(
          'Get Device ID command failed' => '0xc0 Node busy',
          'Invalid channel' => '0',
        )
    end
  end
  context 'IBM ipmitool lan print' do
    subject { described_class.parse_lan ibm_lan_print }

    it do
      is_expected
        .to include(
          'Auth Type Support' => 'NONE MD2 MD5 PASSWORD',
          'IP Address Source' => 'bios',
          'IP Address' => '192.168.0.3',
          'Subnet Mask' => '255.255.255.0',
          'MAC Address' => '00:14:5e:1b:c6:c1',
          'SNMP Community String' => 'public',
          'IP Header' => 'TTL=0x40 Flags=0x40 Precedence=0x00 TOS=0x10',
          'BMC ARP Control' => 'ARP Responses Enabled, Gratuitous ARP Disabled',
          'Gratituous ARP Intrvl' => '2.0 seconds',
          'Default Gateway IP' => '192.168.0.1',
          'Default Gateway MAC' => '00:00:00:00:00:00',
          'Backup Gateway IP' => '0.0.0.0',
          'Backup Gateway MAC' => '00:00:00:00:00:00',
          '802.1q VLAN ID' => 'Disabled',
          '802.1q VLAN Priority' => '0',
          'RMCP+ Cipher Suites' => '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14',
          'Cipher Suite Priv Max' => 'aaaaaaaaaaaaaaa',
        )
    end
    it do
      is_expected.to include('Auth Type Enable')
    end
  end
  context 'HP ipmitool lan print' do
    subject { described_class.parse_lan hp_lan_print }

    it do
      is_expected
        .to include(
          'Auth Type Support' => '',
          'IP Address Source' => 'dhcp',
          'IP Address' => '123.123.123.123',
          'Subnet Mask' => '255.255.255.0',
          'MAC Address' => 'de:ad:be:ef:ca:fe',
          'BMC ARP Control' => 'ARP Responses Enabled, Gratuitous ARP Disabled',
          'Default Gateway IP' => '123.123.123.1',
          '802.1q VLAN ID' => 'Disabled',
          '802.1q VLAN Priority' => '0',
          'Cipher Suite Priv Max' => 'Not Available',
        )
    end
  end
  context '#parse_user_csv' do
    subject { described_class.parse_user_csv dell_ipmitool_user_list_1 }

    it do
      is_expected.not_to be_empty
    end
    it do
      is_expected.to include(user_params(id: '1', link_auth: :false, ipmi_msg: :false))
      is_expected.to include(user_params(id: '2', name: 'root', channel_priv_limit: 'ADMINISTRATOR'))
      is_expected.to include(user_params(id: '3', name: 'xx xxd', channel_priv_limit: 'USER'))
      is_expected.to include(user_params(id: '4', name: 'xx', channel_priv_limit: 'OPERATOR'))
      is_expected.to include(user_params(id: '5', name: 'true', channel_priv_limit: 'OEM'))
      is_expected.to include(user_params(id: '6', name: 'name', channel_priv_limit: 'CALLBACK'))
      is_expected.to include(user_params(id: '7'))
    end
  end
end
