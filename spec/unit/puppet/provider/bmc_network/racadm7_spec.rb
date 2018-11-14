require 'spec_helper'

provider_class = Puppet::Type.type(:bmc_network).provider(:racadm7)

describe provider_class do
  let(:resource) do
    Puppet::Type.type(:bmc_network).new(name: 'test')
  end

  let :provider do
    output = File.join(
      File.dirname(__FILE__), '..', '..', '..', '..', 'fixtures', 'bmc', 'racadm7_getIDRAC.NIC.txt'
    )
    provider_class
      .stubs(:racadm7)
      .returns(IO.read(output))
    provider.prefetch('test' => resource)
    provider
  end

  it { expect(provider_class.name).to eq :racadm7 }
end
