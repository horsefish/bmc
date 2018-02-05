require 'spec_helper'

provider_class = Puppet::Type.type(:bmc_user).provider(:ipmitool)

describe provider_class do
  let :provider do
    resource = Puppet::Type::Bmc_user.new(title: 'test')
    provider_class.new(resource)
  end

  it do
    expect(provider.name).to eq 'test'
  end
end
