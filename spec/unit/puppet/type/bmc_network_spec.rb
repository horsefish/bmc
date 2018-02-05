require 'spec_helper'
require 'helpers/network_type_params'

RSpec.configure do |c|
  c.include Helpers
end

type_class = Puppet::Type.type(:bmc_network)

describe type_class do
  let(:type) do
    Puppet::Type.type(:bmc_network).new(network_type_params)
  end

  it 'exceptions handling' do
    expect {
      Puppet::Type.type(:bmc_network).new(
        network_type_params(ipv4_gateway: 'XXX'),
      )
    }.to raise_error(Puppet::ResourceError)
  end

  it 'do not raise error when created' do
    expect {
      Puppet::Type.type(:bmc_network).new(
        network_type_params(provider_name: ''),
      )
    }.not_to raise_error
  end

  [
    {
      attribute: :ipv4_ip_address,
      value: '1.10',
    },
    {
      attribute: :ipv4_gateway,
      value: '1.1.1',
    },
    {
      attribute: :ipv4_netmask,
      value: '10.10',
    },
  ].each do |options|
    it do
      expect {
        Puppet::Type.type(:bmc_network).new(
          name: '1',
          options[:attribute] => options[:value],
        )
      }.to raise_error(Puppet::ResourceError)
    end
  end
end
