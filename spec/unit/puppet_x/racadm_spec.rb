#!/usr/bin/env rspec
#
require 'spec_helper'
require 'puppet_x/racadm/racadm'
describe Racadm::Racadm do

  let(:getIDRAC) { IO.read(
      File.join(
          File.dirname(__FILE__),
          '..', '..', 'fixtures', 'bmc', 'racadm7_getIDRAC.IPv4.txt'))
  }

  describe 'racadm7 get IDRAC.IPv4' do
    subject { Racadm::Racadm.parseiDRAC_IPv4 getIDRAC }
    it { should include({
                            'Address' => '10.235.70.163',
                            'DHCPEnable' => 'Disabled',
                            'DNS1' => '0.0.0.0',
                            'DNS2' => '0.0.0.0',
                            'DNSFromDHCP' => 'Disabled',
                            'Enable' => 'Enabled',
                            'Gateway' => '10.235.70.254',
                            'Netmask' => '255.255.255.0'}
                ) }
  end
end