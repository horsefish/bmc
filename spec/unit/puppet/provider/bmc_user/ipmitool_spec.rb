require 'spec_helper'

provider_class = Puppet::Type.type(:bmc_user).provider(:ipmitool)

describe provider_class do
  let :params do
    {}
  end

  let :resource do
    Puppet::Type::Bmc_user.new(
      {
        title: 'a_user',
        password: 'a_secret',
        callin: false,
        ipmi: true,
        link: false,
      }.merge(params),
    )
  end

  let :provider do
    provider_class.new(resource)
  end

  it { expect(provider_class.name).to eq :ipmitool }

  describe 'default instance' do
    it { expect(provider.name).to eq 'a_user' }
  end
end
