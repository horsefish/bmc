require 'spec_helper'

provider_class = Puppet::Type.type(:bmc_ldap_group).provider(:racadm7)

describe provider_class do
  let :params do
    {}
  end

  let :resource do
    Puppet::Type::Bmc_ldap_group.new(
      {
        title: '1',
      }.merge(params),
    )
  end

  let :provider do
    provider_class.new(resource)
  end

  it { expect(provider_class.name).to eq :racadm7 }

  describe 'default instance' do
    it { expect(provider.name).to eq 1.to_s.to_sym }
  end
end
