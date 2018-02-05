require 'spec_helper'

type_class = Puppet::Type.type(:bmc_ldap)

describe type_class do
  it 'normal' do
    expect {
      Puppet::Type.type(:bmc_ldap).new(
        name: 'test',
        server: 'ldap.server.dk',
        base_dn: 'dc=example,dc=com',
      )
    }.not_to raise_error
    expect {
      Puppet::Type.type(:bmc_ldap).new(
        name: 'test',
        server: 'ldap.server.dk',
        base_dn: 'dc=example,dc=com',
        bmc_server_host: '192.168.0.1',
        bmc_username: 'root',
        bmc_password: 'secret',
      )
    }.not_to raise_error
  end

  it 'exceptions handling' do
    expect {
      Puppet::Type.type(:bmc_ldap).new(
        name: 'test',
      )
    }.to raise_error(Puppet::ResourceError)
    expect {
      Puppet::Type.type(:bmc_ldap).new(
        name: 'test',
        server: 'ldap.server.dk',
      )
    }.to raise_error(Puppet::ResourceError)
    expect {
      Puppet::Type.type(:bmc_ldap).new(
        name: 'test',
        server: 'ldap.server.dk',
        base_dn: 'dc=example,dc=com',
        certificate_validate: 'NoWay',
      )
    }.to raise_error(Puppet::ResourceError)
    expect {
      Puppet::Type.type(:bmc_ldap).new(
        name: 'test',
        server: 'ldap.server.dk',
        base_dn: 'dc=example,dc=com',
        bmc_server_host: 'bmc.host.dk',
      )
    }.to raise_error(Puppet::ResourceError)
    expect {
      Puppet::Type.type(:bmc_ldap).new(
        name: 'test',
        server: 'ldap.server.dk',
        base_dn: 'dc=example,dc=com',
        bmc_server_host: 'Not A DNS NAME',
        bmc_assword: 'secret',
      )
    }.to raise_error(Puppet::ResourceError)
  end
end
