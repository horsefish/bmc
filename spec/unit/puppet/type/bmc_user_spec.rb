require 'spec_helper'
require 'helpers/network_type_params'

RSpec.configure do |c|
  c.include Helpers
end

type_class = Puppet::Type.type(:bmc_user)

describe type_class do
  let(:type) do
    Puppet::Type.type(:bmc_user).new(
      name: 'root',
      bmc_password: 'calvin',
      enable: true,
      privilege: 'ADMINISTRATOR',
      channel: 1,
      provider: 'ipmitool',
    )
  end

  it 'exceptions handling' do
    expect {
      Puppet::Type.type(:bmc_user).new(
        name: 'foo',
        bmc_password: 'theSecret',
        privilege: 'XXXXX',
      )
    }.to raise_error(Puppet::ResourceError)
  end
end
