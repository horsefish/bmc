#!/usr/bin/env rspec
#
require 'spec_helper'

type_class = Puppet::Type.type(:bmc_ldap)

describe type_class do
  let(:type) do
    Puppet::Type.type(:bmc_ldap).new(
        :name => 'test',
        :server => 'ldap.server.dk'
    )
  end

  it 'exceptions handling' do
    expect {
      Puppet::Type.type(:bmc_ldap).new(
          :name => 'test'
      ) }.to raise_error(Puppet::ResourceError)
    expect {
      Puppet::Type.type(:bmc_ldap).new(
          :name => 'test',
          :server => 'ldap.server.dk',
          :certificate_validate => 'NoWay'
      ) }.to raise_error(Puppet::ResourceError)
  end
end
