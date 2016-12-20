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
                            'Address' => '10.235.70.163',
                            'DHCPEnable' => 'Disabled',
                            'DNS1' => '0.0.0.0',
                            'DNS2' => '0.0.0.0',
                            'DNSFromDHCP' => 'Disabled',
                            'Enable' => 'Enabled',
                            'Gateway' => '10.235.70.254',
                            'Netmask' => '255.255.255.0'
                        }
                ) }
  end

  describe 'racadm7 get IDRAC.LDAP' do
    subject { Racadm::Racadm.parse_racadm getIDRAC_LDAP }
    it { should include({
                            'Port' => '636',
                            'Server' => 'idm01.dap.cfcs.dk',
                            'BaseDN' => 'CN=users,CN=accounts,DC=dap,DC=cfcs,DC=dk',
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