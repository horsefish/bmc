require 'spec_helper'

describe Facter::Util::Fact do
  before do
    Facter.clear
  end

  describe 'manufactor_id with ipmitool and idrac' do
    context 'with value' do
      before :each do
        Facter.fact(:is_virtual).stubs(:value).returns false
        Facter::Util::Resolution.stubs(:which).with('ipmitool').returns(true)
        Facter::Util::Resolution.stubs(:exec).with('ipmitool mc info 2>&1').
            returns(IO.read("#{File.dirname(__FILE__)}/../../fixtures/bmc/ipmitool_mc_info.txt"))
      end
      it do
        expect(Facter.fact(:manufactor_id).value).to eq('674')
      end
    end
  end
end