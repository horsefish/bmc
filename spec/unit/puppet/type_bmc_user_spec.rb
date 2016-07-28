#!/usr/bin/env rspec
#
require 'spec_helper'

type_class = Puppet::Type.type(:bmc_user)
provider_class = type_class.provider(:ipmitoo)

describe type_class do

  let(:type) do
    Puppet::Type.type(:bmc_user).new(
        :name => 'root',
        :password => 'calvin',
        :userid => 2,
        :enable => true,
        :privilege => 'ADMINISTRATOR',
        :channel => 1
    )
  end

  let(:provider) do
    provider_class.new
  end
  subject do
    provider.resource = type
    type
  end


  #it "can be in sync desptite inability to detect lro on centos5_1" do
  #  subject.provider.stubs(:ethtool).returns(
  #      IO.read("#{File.dirname(__FILE__)}/../../fixtures/bmc/ipmitool_user_list.txt")
  #  )
  #  p = subject.properties.find { |prop| prop.name == :lro }
  #  expect(p.retrieve).to eql('unknown')
  #  expect(p.insync?('unknown')).to eql(true)
  #end
end

