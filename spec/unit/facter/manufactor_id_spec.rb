require 'spec_helper'

describe Facter::Util::Fact do

  before(:each) do
    Facter.clear
  end
  after(:each) do
    Facter.clear
  end

  let(:dell_ipmitool_mc_info) do
    output = File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'bmc', 'dell_ipmitool_mc_info.txt')
    IO.read(output)
  end
  describe '#manufactor_id' do
    context '#manufactor_id physical' do
      let(:facter) {{:is_virtual => false, }}

      it do
        allow(Facter::Core::Execution).to receive(:which).and_return('/bin/ipmitool')
        allow(Facter::Core::Execution).to receive(:execute).and_call_original
        allow(Facter::Core::Execution).to receive(:execute).with('/bin/ipmitool mc info 2>&1').and_return(dell_ipmitool_mc_info)

        expect(Facter.fact(:manufactor_id).value).to eq '674'
      end
    end

    context '#manufactor_id virtual' do
      Facter.fact(:is_virtual).stubs(:value).returns true
      it do
        allow(Facter.fact(:is_virtual)).to receive(:value).and_return(true)
        expect(Facter.fact(:manufactor_id)).to be_nil
      end
    end
  end
end
