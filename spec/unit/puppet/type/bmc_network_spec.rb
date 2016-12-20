#!/usr/bin/env rspec
#
require 'spec_helper'

type_class = Puppet::Type.type(:bmc_network)

describe type_class do
  let(:type) do
    Puppet::Type.type(:bmc_network).new(
        :name => 'test',
        :ipsrc => 'static',
        :ipaddr => '10.10.10.10',
        :gateway => '10.10.10.254',
        :netmask => '255.255.255.0',
        :channel => 1,
        :provider => 'ipmitool'
    )
  end

  it 'exceptions handling' do
    expect {
      Puppet::Type.type(:bmc_network).new(
          :name => 'foo',
          :ipsrc => 'static',
          :ipaddr => '10.10.10.10',
          :gateway => 'XXX',
          :netmask => '255.255.255.0',
          :channel => 1
      ) }.to raise_error(Puppet::ResourceError)
  end

  it 'should not raise error when created' do
    expect {
      Puppet::Type.type(:bmc_network).new(
          :name => 'foo',
          :ipsrc => 'static',
          :ipaddr => '10.10.10.10',
          :gateway => '10.10.10.254',
          :netmask => '255.255.255.0',
          :channel => 1
      ) }.not_to raise_error
  end

  {
      'should require valid ip' => {
          attribute: :ipaddr,
          value: '1.10'
      },
      'should require valid gateway' => {
          attribute: :gateway,
          value: '1.1.1'
      },
      'should reqiore valid netmask' => {
          attribute: :netmask,
          value: '10.10'
      }
  }.each do |check, options|
    it 'should require valid ip' do
      expect {
        Puppet::Type.type(:bmc_network).new(
            :name => '1',
            options[:attribute] => options[:value],
        ) }.to raise_error(Puppet::ResourceError)
    end
  end
end




