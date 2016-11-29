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
        :channel => 1,
        :provider => 'ipmitool'
    )
  end
  let(:provider) do
    provider_class.new
  end
  subject do
    provider.resource = type
    type
  end

  it 'should not raise error when created' do
    expect {
      Puppet::Type.type(:bmc_network).new(
          :name => 'foo',
          :proto => 'static',
          :ipaddr => '10.10.10.10',
          :gateway => '10.10.10.254',
          :netmask => '255.255.255.0',
          :channel => 1
      ) }.not_to raise_error
  end

  # Leaving this as a command until someone figures out a way to mock ipmitool command in the provider with exit code 1+
  # it 'should xxxx' do
  #       subject.provider.stubs(:ipmitool).returns 1
  #   expect {
  #     Puppet::Type.type(:bmc_network).new(
  #         :name => 'foo',
  #         :proto => 'static',
  #         :ipaddr => '10.10.10.10',
  #         :gateway => '10.10.10.254',
  #         :netmask => '255.255.255.0',
  #         :channel => 1
  #     ) }.to raise_error
  # end

  {
      'should require valid ip' => {
          attribute: :ipaddr,
          value: '1.10',
          error_msg: 'is not a valid ip address'
      },
      'should require valid gateway' => {
          attribute: :gateway,
          value: '1.1.1',
          error_msg: 'is not a valid gateway'
      },
      'should reqiore valid netmask' => {
          attribute: :netmask,
          value: '10.10',
          error_msg: 'is not a valid subnet mask'
      }
  }.each do |check, options|
    it 'should require valid ip' do
      expect {
        Puppet::Type.type(:bmc_network).new(
            :name => 'foo',
            options[:attribute] => options[:value],
        ) }.to raise_error(Puppet::Error, /#{options[:error_msg]}/)
    end
  end

  [:static, :dynamic, :none, :bios].each do |proto|
    it 'should accept protocol #{proto}' do
      expect {
        Puppet::Type.type(:bmc_network).new(
            :name => 'foo',
            :proto => proto
        ) }.not_to raise_error
    end
  end

  {proto: 'static', ipaddr: '10.10.10.10', netmask: '255.255.255.0', gateway: '10.10.10.254'}.each do |key, value|
    it "#{key} should be in sync" do
      subject.provider.stubs(:ipmitool).returns(
          IO.read("#{File.dirname(__FILE__)}/../../fixtures/bmc/ipmitool_lan_print.txt")
      )
      p = subject.properties.find { |prop| prop.name == key }
      expect(p.retrieve).to eql(value)
      expect(p.insync?(value)).to eql(true)
    end
  end

end




