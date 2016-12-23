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

  describe 'racadm7 get IDRAC.IPv4' do
    subject { Racadm::Racadm.parse_racadm getIDRAC_IPv4 }
    it { should include({
                            'Address' => '192.168.0.1',
                            'DHCPEnable' => 'Disabled',
                            'DNS1' => '0.0.0.0',
                            'DNS2' => '0.0.0.0',
                            'DNSFromDHCP' => 'Disabled',
                            'Enable' => 'Enabled',
                            'Gateway' => '192.168.0.254',
                            'Netmask' => '255.255.255.0'
                        }
                ) }
  end

  describe 'racadm7 get IDRAC.LDAP' do
    subject { Racadm::Racadm.parse_racadm getIDRAC_LDAP }
    it { should include({
                            'Port' => '636',
                            'Server' => 'ldap.example.com',
                            'BaseDN' => 'CN=users,CN=accounts,DC=example,DC=com',
                            'CertValidationEnable' => 'Enabled',
                            'Enable' => 'Enabled',
                            'GroupAttribute' => 'member',
                            'GroupAttributeIsDN' => 'Enabled',
                            'SearchFilter' => '',
                            'UserAttribute' => 'uid'
                        }
                ) }
    it { should_not have_key('BindPassword') }
  end
end