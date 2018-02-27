require 'spec_helper'

describe 'bmc', type: :fact do
  before(:each) do
    Facter.clear
  end
  after(:each) do
    Facter.clear
  end

  describe '#manufactor_id physical' do
    output = File.join(
      File.dirname(__FILE__), '..', '..', 'fixtures', 'bmc', 'dell_ipmitool_mc_info.txt'
    )
    Facter.fact(:is_virtual).stubs(:value).returns false
    Facter::Core::Execution.stubs(:which).returns '/bin/ipmitool'
    Facter::Core::Execution
      .expects(:execute)
      .with('/bin/ipmitool mc info 2>&1')
      .returns(IO.read(output))
    Facter::Core::Execution
      .expects(:execute)
      .with('uname -m', on_fail: nil)
      .returns 'x86_64'
    it do
      expect(Facter.fact(:manufactor_id).value).to eq '674'
    end
  end

  describe '#manufactor_id virtual' do
    Facter.fact(:is_virtual).stubs(:value).returns true
    it do
      expect(Facter.fact(:manufactor_id)).to be_nil
    end
  end
end
