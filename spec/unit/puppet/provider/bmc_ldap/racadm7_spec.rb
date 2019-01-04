require 'spec_helper'

provider_class = Puppet::Type.type(:bmc_ldap).provider(:racadm7)

describe provider_class do
  let :params do
    {}
  end

  let :resource do
    Puppet::Type::Bmc_ldap.new(
      {
        title: 'a_ldap',
        server: 'ldap.server.com',
        base_dn: 'cn=com',
      }.merge(params),
    )
  end

  let :provider do
    provider_class.new(resource)
  end

  it { expect(provider_class.name).to eq :racadm7 }

  describe 'default instance' do
    it { expect(provider.name).to eq 'a_ldap' }
  end
end
