#!/usr/bin/env rspec
#
require 'spec_helper'
require 'helpers/network_type_params'

RSpec.configure do |c|
  c.include Helpers
end

type_class = Puppet::Type.type(:bmc_network)


describe type_class do
  let(:type) do
    Puppet::Type.type(:bmc_network).new(
        network_type_params()
    )
  end

  it 'exceptions handling' do
    expect {
      Puppet::Type.type(:bmc_network).new(
          network_type_params(gateway: 'XXX')
      ) }.to raise_error(Puppet::ResourceError)
  end

  it 'should not raise error when created' do
    puts network_type_params(provider_name: '')
    expect {
      Puppet::Type.type(:bmc_network).new(
          network_type_params(provider_name: '')
      ) }.not_to raise_error
  end

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
            :name => '1',
            options[:attribute] => options[:value],
        ) }.to raise_error(Puppet::Error, /#{options[:error_msg]}/)
    end
  end
end
