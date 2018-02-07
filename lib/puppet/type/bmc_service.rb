require 'resolv'
require 'pathname'

Puppet::Type.newtype(:bmc_service) do
  @doc = 'A resource type to restart the bmc instance.'

  newparam(:name, namevar: true) do
    desc 'Identification of the BMC service.'
  end

  newparam(:bmc_username) do
    desc 'Username used to connect with bmc service.'
  end

  newparam(:bmc_password) do
    desc 'Password used to connect with bmc service.'
  end

  newparam(:bmc_server_host) do
    desc 'RAC host address. Defaults to ipmitool lan print > IP Address'
    validate do |value|
      unless value =~ Resolv::IPv4::Regex || value =~ Resolv::IPv6::Regex
        raise Puppet::Error, '%s is not a valid ip address' % value
      end
    end
  end

  def refresh
    provider.restart
  end
end
