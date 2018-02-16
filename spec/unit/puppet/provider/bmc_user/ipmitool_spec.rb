require 'spec_helper'

type_class = Puppet::Type.type(:bmc_user)

#provider_class = Puppet::Type.type(:bmc_user).provider(:ipmitool)

describe type_class.provider(:ipmitool) do

  let :provider do
    resource = type_class.new(title: 'test')
    instance = described_class.new(title: 'test')
    resource.provider = instance
    instance
  end

  describe 'default instance' do
    it { expect(provider.name).to eq 'test' }
  end
end
