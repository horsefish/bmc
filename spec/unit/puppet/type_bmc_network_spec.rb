#!/usr/bin/env rspec
#
require 'spec_helper'

type_class = Puppet::Type.type(:bmc_network)
provider_class = type_class.provider(:ipmitool)



describe type_class do
  let(:type) do
    Puppet::Type.type(:bmc_network).new(
        :name => 'test',
        :proto => 'static',
        :ipaddr => '10.10.10.10',
        :gateway => '10.10.10.254',
        :netmask => '255.255.255.0',
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


  #very basic test for learning purpose
  it 'should no raise error when created' do
    expect {
      Puppet::Type.type(:bmc_network).new(
          :name => 'test',
          :proto => 'static',
          :ipaddr => '10.10.10.10',
          :gateway => '10.10.10.254',
          :netmask => '255.255.255.0',
          :channel => 1
      ) }.not_to raise_error
  end


  it "set ipaddr" do
    subject.provider. stubs(:bmc_network).returns(
        IO.read("#{File.dirname(__FILE__)}/../../fixtures/bmc/ipmitool_lan_print.txt")
    )
    p = subject.properties.find { |prop| prop.name == :ipaddr }
    expect(p.retrieve).to eql('10.10.10.10')
    expect(p.insync?('10.10.10.10')).to eql(true)
  end


end




