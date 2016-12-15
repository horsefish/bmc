#!/usr/bin/env rspec
#
require 'spec_helper'

provider_class = Puppet::Type.type(:bmc_network).provider(:ipmitool)

describe provider_class do
  let :provider do
    resource = Puppet::Type::Bmc_network.new({:title => 'test'})
    provider_class.stubs(:ipmitool).returns(
        IO.read(
            File.join(
                File.dirname(__FILE__),
                '..', '..', '..', '..', 'fixtures', 'bmc', 'dell_ipmitool_lan_print.txt')))
    provider_class.new(resource)
  end

  {name: 'test', ipsrc: 'static', ipaddr: '10.10.10.10', netmask: '255.255.255.0', gateway: '10.10.10.254'}.each do |key, value|
    it "#{key} should be in sync" do
      expect(provider.send(key)).to eql(value)
    end
  end
end
