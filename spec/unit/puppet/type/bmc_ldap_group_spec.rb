#!/usr/bin/env rspec
#
require 'spec_helper'

type_class = Puppet::Type.type(:bmc_ldap_group)

describe type_class do
  it 'normal' do
    expect {
      type_class.new(
          :name => 'Default group',
          :group_nr => 1,
          :role_group_dn => 'cn=none,cn=groups,cn=accounts,dc=example,dc=com'
      )}.not_to raise_error
    expect {
      type_class.new(
          :name => 'Admin group',
          :group_nr => 1,
          :role_group_dn => 'cn=administrator,cn=groups,cn=accounts,dc=example,dc=com',
          :role_group_privilege => 0x1ff
      )}.not_to raise_error
    expect {
      type_class.new(
          :name => '1'
      )}.not_to raise_error
  end

  it 'exceptions handling' do
    expect {
      type_class.new(
          :name => 'Illegal groupname',
      )}.to raise_error(Puppet::ResourceError)
    expect {
      type_class.new(
          :name => '1',
          :group_nr => 10,
      )}.to raise_error(Puppet::ResourceError)
    expect {
    type_class.new(
        :name => '1',
        :role_group_privilege => 'Illegal'
    )}.to raise_error(Puppet::ResourceError)
  end
end