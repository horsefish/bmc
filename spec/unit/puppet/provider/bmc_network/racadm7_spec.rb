require 'spec_helper'

provider_class = Puppet::Type.type(:bmc_network).provider(:racadm7)

describe provider_class do
  let :params do
    {}
  end

  let(:resource) do
    Puppet::Type::Bmc_network.new(
      {
        title: 'test',
      }.merge(params),
    )
  end

  let :provider do
    provider_class.new(resource)
  end

  it { expect(provider_class.name).to eq :racadm7 }

  describe 'default instance' do
    it { expect(provider.name).to eq 'test' }
  end
end
