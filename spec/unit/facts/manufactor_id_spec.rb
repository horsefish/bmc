require 'spec_helper'

describe 'bmc', type: :fact do
  before(:each) do
    Facter.clear
  end
  after(:each) do
    Facter.clear
  end

  context '#manufactor_id physical' do
    output = File.join( File.dirname(__FILE__), '..', '..', 'fixtures', 'bmc', 'dell_ipmitool_mc_info.txt' )

    let(:facts) { { :is_virtual => false, } }

    it do
      expect(Facter::Core::Execution).to receive(:which).and_return('/bin/ipmitool')
      expect(Facter::Core::Execution).to receive(:execute).with('/bin/ipmitool mc info 2>&1').and_return(IO.read(output))
      #allow(Facter::Core::Execution).to receive(:execute).with('uname', '-m').and_return('x86_64')

      expect(Facter.fact(:manufactor_id)).to eq '674'
    end
  end

#  describe '#manufactor_id virtual' do
    #Facter.fact(:is_virtual).stubs(:value).returns true
#    it do
#      allow(Facter.fact(:is_virtual)).to receive(:value).and_return(true)
#      expect(Facter.fact(:manufactor_id)).to be_nil
#    end
#  end
end
