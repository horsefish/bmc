require 'spec_helper'
require 'puppet_x/racadm/racadm'
describe Racadm do
  let(:getIDRAC_IPv4) do
    output = File.join(File.dirname(__FILE__), '..', '..', '..', 'fixtures', 'bmc', 'racadm7_getIDRAC.IPv4.txt')
    IO.read(output)
  end
  let(:getIDRAC_LDAP) do
    output = File.join(File.dirname(__FILE__), '..', '..', '..', 'fixtures', 'bmc', 'racadm7_getIDRAC.LDAP.txt')
    IO.read(output)
  end
  let(:getConfigUserNotExist) do
    output = File.join(File.dirname(__FILE__), '..', '..', '..', 'fixtures', 'bmc', 'racadm7_getConfigUserNotExist.txt')
    IO.read(output)
  end
  let(:idrac7_getConfigUserRoot) do
    output = File.join(File.dirname(__FILE__), '..', '..', '..', 'fixtures', 'bmc', 'racadm7_getConfigUserRoot.txt')
    IO.read(output)
  end
  let(:idrac9_getConfigUserRoot) do
    output = File.join(File.dirname(__FILE__), '..', '..', '..', 'fixtures', 'bmc', 'racadm9_getConfigUserRoot.txt')
    IO.read(output)
  end
  let(:getIDRAC_Users) do
    output = File.join(File.dirname(__FILE__), '..', '..', '..', 'fixtures', 'bmc', 'racadm7_getIDRAC.Users.txt')
    IO.read(output)
  end
  let(:getIDRAC_Users_2) do
    output = File.join(File.dirname(__FILE__), '..', '..', '..', 'fixtures', 'bmc', 'racadm7_getIDRAC.Users.2.txt')
    IO.read(output)
  end

  describe 'racadm7 get IDRAC.IPv4' do
    subject { described_class.parse_racadm getIDRAC_IPv4 }

    it do
      is_expected
        .to include(
          'Address' => '192.168.0.1',
          'DHCPEnable' => 'Disabled',
          'DNS1' => '0.0.0.0',
          'DNS2' => '0.0.0.0',
          'DNSFromDHCP' => 'Disabled',
          'Enable' => 'Enabled',
          'Gateway' => '192.168.0.254',
          'Netmask' => '255.255.255.0',
        )
    end
  end

  describe 'racadm7 get IDRAC.LDAP' do
    subject { described_class.parse_racadm getIDRAC_LDAP }

    it do
      is_expected
        .to include(
          'Port' => '636',
          'Server' => 'ldap.example.com',
          'BaseDN' => 'CN=users,CN=accounts,DC=example,DC=com',
          'CertValidationEnable' => 'Enabled',
          'Enable' => 'Enabled',
          'GroupAttribute' => 'member',
          'GroupAttributeIsDN' => 'Enabled',
          'SearchFilter' => '',
          'UserAttribute' => 'uid',
        )
    end
    it do
      is_expected.not_to have_key('BindPassword')
    end
  end

  describe 'racadm7 getconfig NoUser' do
    subject { described_class.parse_racadm getConfigUserNotExist }

    it do
      is_expected.to be_empty
    end
  end

  describe 'idrac7 getconfig Root' do
    subject { described_class.parse_racadm idrac7_getConfigUserRoot }

    it do
      is_expected
        .to include(
          '#cfgUserAdminIndex' => '2',
          'cfgUserAdminUserName' => 'root',
          '#cfgUserAdminPassword' => '******** (Write-Only)',
          'cfgUserAdminEnable' => '1',
          'cfgUserAdminPrivilege' => '0x000001ff',
          'cfgUserAdminIpmiLanPrivilege' => '4',
          'cfgUserAdminIpmiSerialPrivilege' => '4',
          'cfgUserAdminSolEnable' => '1',
        )
    end
  end

  describe 'racadm9 getconfig Root' do
    subject { described_class.parse_racadm idrac9_getConfigUserRoot }

    it do
      is_expected
        .to include(
          '#cfgUserAdminIndex' => '2',
          'cfgUserAdminUserName' => 'root',
          'cfgUserAdminEnable' => 'Enabled',
          'cfgUserAdminPrivilege' => '0x1ff',
          'cfgUserAdminIpmiLanPrivilege' => '4',
          'cfgUserAdminIpmiSerialPrivilege' => '4',
          'cfgUserAdminSolEnable' => 'Enabled',
        )
    end
  end

  describe 'racadm7 get IDRAC.Users' do
    subject { described_class.parse_racadm getIDRAC_Users }

    it do
      is_expected
        .to include(
          'iDRAC.Users.1' => '[Key=iDRAC.Embedded.1#Users.1]',
          'iDRAC.Users.2' => '[Key=iDRAC.Embedded.1#Users.2]',
          'iDRAC.Users.3' => '[Key=iDRAC.Embedded.1#Users.3]',
          'iDRAC.Users.4' => '[Key=iDRAC.Embedded.1#Users.4]',
          'iDRAC.Users.5' => '[Key=iDRAC.Embedded.1#Users.5]',
          'iDRAC.Users.6' => '[Key=iDRAC.Embedded.1#Users.6]',
          'iDRAC.Users.7' => '[Key=iDRAC.Embedded.1#Users.7]',
          'iDRAC.Users.8' => '[Key=iDRAC.Embedded.1#Users.8]',
          'iDRAC.Users.9' => '[Key=iDRAC.Embedded.1#Users.9]',
          'iDRAC.Users.10' => '[Key=iDRAC.Embedded.1#Users.10]',
          'iDRAC.Users.11' => '[Key=iDRAC.Embedded.1#Users.11]',
          'iDRAC.Users.12' => '[Key=iDRAC.Embedded.1#Users.12]',
          'iDRAC.Users.13' => '[Key=iDRAC.Embedded.1#Users.13]',
          'iDRAC.Users.14' => '[Key=iDRAC.Embedded.1#Users.14]',
          'iDRAC.Users.15' => '[Key=iDRAC.Embedded.1#Users.15]',
          'iDRAC.Users.16' => '[Key=iDRAC.Embedded.1#Users.16]',
        )
    end
  end

  describe 'racadm7 get IDRAC.Users.2' do
    subject { described_class.parse_racadm getIDRAC_Users_2 }

    it do
      is_expected
        .to include(
          'Enable' => 'Enabled',
          'IpmiLanPrivilege' => '4',
          'IpmiSerialPrivilege' => '4',
          'Privilege' => '0x1ff',
          'SNMPv3AuthenticationType' => 'SHA',
          'SNMPv3Enable' => 'Disabled',
          'SNMPv3PrivacyType' => 'AES',
          'SolEnable' => 'Enabled',
          'UserName' => 'root',
        )
    end
    it do
      is_expected.not_to have_key('Password')
    end
  end
end
