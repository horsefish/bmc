require 'spec_helper'

type_class = Puppet::Type.type(:bmc_user)

describe type_class.provider(:racadm7) do
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
