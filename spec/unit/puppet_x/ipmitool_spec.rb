#!/usr/bin/env rspec
#
require 'spec_helper'
require 'puppet_x/ipmi/ipmitool'

def user_params(id: "2", name: "root", callin: :true, link_auth: :true, ipmi_msg: :true, channel_priv_limit: "ADMINISTRATOR")
  {
      "id" => id,
      "name" => name,
      "callin" => callin,
      "link_auth" => link_auth,
      "ipmi_msg" => ipmi_msg,
      "channel_priv_limit" => channel_priv_limit
  }
end

describe Ipmi::Ipmitool do

  let(:dell_lan_print) { IO.read("#{File.dirname(__FILE__)}/../../fixtures/bmc/dell_ipmitool_lan_print.txt") }
  let(:ibm_lan_print) { IO.read("#{File.dirname(__FILE__)}/../../fixtures/bmc/ibm_ipmitool_lan_print.txt") }
  let(:hp_lan_print) { IO.read("#{File.dirname(__FILE__)}/../../fixtures/bmc/hp_ipmitool_lan_print.txt") }
  let(:dell_ipmitool_user_list_1) { IO.read("#{File.dirname(__FILE__)}/../../fixtures/bmc/dell_ipmitool_user_list_1.txt") }
  let(:dell_ipmitool_user_list_2) { IO.read("#{File.dirname(__FILE__)}/../../fixtures/bmc/dell_ipmitool_user_list_2.txt") }
  let(:dell_ipmitool_user_list_3) { IO.read("#{File.dirname(__FILE__)}/../../fixtures/bmc/dell_ipmitool_user_list_3.txt") }


  context "DELL ipmitool lan print" do
    subject { Ipmi::Ipmitool.parseLan dell_lan_print }
    it { should include('Auth Type Support' => 'MD5',
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
                        'Cipher Suite Priv Max' => 'Xaaaaaaaaaaaaaa') }
    it { should include('Auth Type Enable') }
  end
  context "IBM ipmitool lan print" do
    subject { Ipmi::Ipmitool.parseLan ibm_lan_print }
    it { should include('Auth Type Support' => 'NONE MD2 MD5 PASSWORD',
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
                        'Cipher Suite Priv Max' => 'aaaaaaaaaaaaaaa') }
    it { should include('Auth Type Enable') }
  end
  context "HP ipmitool lan print" do
    subject { Ipmi::Ipmitool.parseLan hp_lan_print }
    it { should include('Auth Type Support' => '',
                        'IP Address Source' => 'dhcp',
                        'IP Address' => '123.123.123.123',
                        'Subnet Mask' => '255.255.255.0',
                        'MAC Address' => 'de:ad:be:ef:ca:fe',
                        'BMC ARP Control' => 'ARP Responses Enabled, Gratuitous ARP Disabled',
                        'Default Gateway IP' => '123.123.123.1',
                        '802.1q VLAN ID' => 'Disabled',
                        '802.1q VLAN Priority' => '0',
                        'Cipher Suite Priv Max' => 'Not Available') }
  end
  context "Dell ipmitool user list channel 1" do
    subject { Ipmi::Ipmitool.parseUser dell_ipmitool_user_list_1 }
    it { should_not be_empty }
    it "users" do
      expect(subject).to include(
                             user_params()
                         )
      expect(subject).to include(
                             user_params(id: "3", name: "xx xxd", channel_priv_limit: "USER")
                         )
      expect(subject).to include(
                             user_params(id: "4", name: "xx", channel_priv_limit: "OPERATOR")
                         )
      expect(subject).to include(
                             user_params(id: "5", name: "emil", link_auth: :false, ipmi_msg: :false, channel_priv_limit: "NO ACCESS")
                        )
      expect(subject).to include(
                             user_params(id: "6", name: "name", channel_priv_limit: "CALLBACK")
                         )
      expect(subject).to include(
                             user_params(id: "63", name: "last", channel_priv_limit: "NO ACCESS")
                         )
    end
  end
  context "Dell ipmitool user list channel 3" do
    subject { Ipmi::Ipmitool.parseUser dell_ipmitool_user_list_3 }
    it { should be_empty }
  end
end