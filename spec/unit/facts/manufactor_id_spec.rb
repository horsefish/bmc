require 'spec_helper'

describe Facter::Util::Fact do
  before do
    Facter.clear
  end

  describe 'ipmitool mc info' do
    context 'dell manufactor_id' do
      before :each do
        Facter.fact(:is_virtual).stubs(:value).returns false
        Facter::Util::Resolution.stubs(:which).with('ipmitool').returns(true)
        Facter::Util::Resolution.stubs(:exec).with('ipmitool mc info 2>&1').
            returns(IO.read("#{File.dirname(__FILE__)}/../../fixtures/bmc/dell_ipmitool_mc_info.txt"))
      end
      it do
        expect(Facter.fact(:manufactor_id).value).to eq('674')
      end
    end
    context 'IBM manufactor_id' do
      before :each do
        Facter.fact(:is_virtual).stubs(:value).returns false
        Facter::Util::Resolution.stubs(:which).with('ipmitool').returns(true)
        Facter::Util::Resolution.stubs(:exec).with('ipmitool mc info 2>&1').
            returns(IO.read("#{File.dirname(__FILE__)}/../../fixtures/bmc/ibm_ipmitool_mc_info.txt"))
      end
      it do
        expect(Facter.fact(:manufactor_id).value).to eq('2')
      end
    end

  end
end