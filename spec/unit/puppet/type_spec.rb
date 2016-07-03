#!/usr/bin/env rspec
require 'spec_helper'

type_class = Puppet::Type.type(:bmc_user)
provider_class = type_class.provider(:ipmitool)

describe type_class do

  let(:type) do
    Puppet::Type.type(:bmc_user).new(
        :name => 'root',
        :password => 'calvin',
        :userid => 2,
        :enable => true,
        :privilege => 'ADMINISTRATOR',
        :channel => 1,
    )
  end
  let(:provider) do
    provider_class.new
  end
  subject do
    provider.resource = type
    type
  end

  it "is root set as user" do
    #subject.provider.stubs(:bmc_user).returns(
    #    IO.read("#{File.dirname(__FILE__)}/../../fixtures/bmc/ipmitool_user_list_1.txt")
    #)
    #p = subject.properties.find { |prop| prop.name == :name }
    #expect(p.retrieve).to eql('root')
    #expect(p.insync?('root')).to eql('root')

  end
end

