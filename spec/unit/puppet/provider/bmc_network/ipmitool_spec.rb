require 'spec_helper'

provider_class = Puppet::Type.type(:bmc_network).provider(:ipmitool)

describe provider_class do
  let(:resource) do
    Puppet::Type.type(:bmc_network).new(name: 'test')
  end

  let :provider do
    output = File.join(
      File.dirname(__FILE__), '..', '..', '..', '..', 'fixtures', 'bmc', 'dell_ipmitool_lan_print.txt'
    )
    provider_class
      .stubs(:ipmitool)
      .returns(IO.read(output))
    provider.prefetch('test' => resource)
    provider
  end
end
