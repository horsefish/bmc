#!/usr/bin/env rspec
#
require 'spec_helper'
require 'puppet_x/racadm/racadm'
describe Racadm::Racadm do

  let(:getIDRAC_IPv4) { IO.read(
      File.join(
          File.dirname(__FILE__),
          '..', '..', 'fixtures', 'bmc', 'racadm7_getIDRAC.IPv4.txt'))
  }

  let(:getIDRAC_LDAP) { IO.read(
      File.join(
          File.dirname(__FILE__),
          '..', '..', 'fixtures', 'bmc', 'racadm7_getIDRAC.LDAP.txt'))
  }

  let(:getConfigUserNotExist) { IO.read(
      File.join(
          File.dirname(__FILE__),
          '..', '..', 'fixtures', 'bmc', 'racadm7_getConfigUserNotExist.txt'))
  }

  let(:getIDRAC_Users) { IO.read(
      File.join(
          File.dirname(__FILE__),
          '..', '..', 'fixtures', 'bmc', 'racadm7_getIDRAC.Users.txt'))
  }

  describe 'racadm7 get IDRAC.IPv4' do
    subject { Racadm::Racadm.parse_racadm getIDRAC_IPv4 }
    it { should include(
                    {
                        'Address' => '192.168.0.1',
                        'DHCPEnable' => 'Disabled',
                        'DNS1' => '0.0.0.0',
                        'DNS2' => '0.0.0.0',
                        'DNSFromDHCP' => 'Disabled',
                        'Enable' => 'Enabled',
                        'Gateway' => '192.168.0.254',
                        'Netmask' => '255.255.255.0'
                    })
    }
  end

  describe 'racadm7 get IDRAC.LDAP' do
    subject { Racadm::Racadm.parse_racadm getIDRAC_LDAP }
    it { should include(
                    {
                        'Port' => '636',
                        'Server' => 'ldap.example.com',
                        'BaseDN' => 'CN=users,CN=accounts,DC=example,DC=com',
                        'CertValidationEnable' => 'Enabled',
                        'Enable' => 'Enabled',
                        'GroupAttribute' => 'member',
                        'GroupAttributeIsDN' => 'Enabled',
                        'SearchFilter' => '',
                        'UserAttribute' => 'uid'
                    })
    }
    it { should_not have_key('BindPassword') }
  end

  describe 'racadm7 get IDRAC.LDAP' do
    subject { Racadm::Racadm.parse_racadm getConfigUserNotExist }
    it { should be_empty }
  end

  describe 'racadm7 get IDRAC.Users' do
    subject { Racadm::Racadm.parse_racadm getIDRAC_Users }
    it { should include(
                    {
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
                        'iDRAC.Users.16' => '[Key=iDRAC.Embedded.1#Users.16]'
                    })
    }
  end
end