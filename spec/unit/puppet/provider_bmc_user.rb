#!/usr/bin/env rspec
#
require 'spec_helper'

provider_class = Puppet::Type.type(:bmc_user).provider(:ipmitool)

describe provider_class do
  let(:resource) do
    Puppet::Type.type(:bmc_user).new(
        :name => 'root',
        :password => 'calvin',
        :userid => 2,
        :enable => true,
        :privilege => 'ADMINISTRATOR',
        :channel => 1
  end

  let(:provider) do
    provider = provider_class.new
    provider.resource = resource
    provider
  end


end

