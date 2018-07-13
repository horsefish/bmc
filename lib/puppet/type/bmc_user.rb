require 'resolv'
require 'puppet/parameter/boolean'

Puppet::Type.newtype(:bmc_user) do
  @doc = 'BMC local user administration.'

  ensurable do
    defaultvalues
    defaultto :present
  end

  feature :racadm, 'Dell racadmin specific.'
  feature :ipmi, 'IPMI specific.'

  newparam(:name, namevar: true) do
    desc 'Username of the user'
  end

  newproperty(:password) do
    desc 'Password used to login'

    def should_to_s(_value)
      '<secret>'
    end

    def to_s?(_value)
      '<secret>'
    end

    def change_to_s(_current, _desire)
      'changed password'
    end
  end

  newproperty(:enable) do
    desc 'Indicates whether the user login state is enabled or disabled'
    newvalues(:true, :false)
    defaultto :true
  end

  newproperty(:privilege) do
    desc 'Maximum privilege granted. Defaults to administrator for all'
    defaultto 'administrator'

    validate do |value|
      valid_roles = ['callback', 'user', 'operator', 'administrator', 'oem_proprietary', 'no_access']
      if value.is_a?(::Hash)
        unless (value.values - valid_roles).empty?
          raise Puppet::Error, '%s contains at least one invalid role' % value.inspect
        end
      else
        unless valid_roles.include? value.to_s
          raise Puppet::Error, '%s is not a valid role' % value
        end
      end
    end

    def should_to_s(value)
      value.is_a?(::Hash) ? value.inspect : "All => #{value}"
    end
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

  newproperty(:callin, required_features: :ipmi) do
    desc 'Configure user access information on the callin channels. Default to true for all channels'
    defaultto true

    validate do |value|
      valid_channels = [true, false]
      if value.is_a?(::Hash)
        raise Puppet::Error, '%s contains at least one invalid boolean' % value.inspect unless (value.values - valid_channels).empty?
      else
        raise Puppet::Error, '%s is not a valid boolean' % value unless value.is_a?(TrueClass) || value.is_a?(FalseClass)
      end
    end

    munge do |value|
      value.is_a?(::Hash) ? value : Bmc.boolean_to_symbol(value)
    end

    def should_to_s(value)
      value.is_a?(::Hash) ? value.inspect : "All => #{value}"
    end
  end

  newproperty(:link, required_features: :ipmi) do
    desc 'Configure user access information on the link channels. Default to true for all channels'
    defaultto true

    validate do |value|
      valid_channels = [true, false]
      if value.is_a?(::Hash)
        raise Puppet::Error, '%s contains at least one invalid boolean' % value.inspect unless (value.values - valid_channels).empty?
      else
        raise Puppet::Error, '%s is not a valid boolean' % value unless value.is_a?(TrueClass) || value.is_a?(FalseClass)
      end
    end

    munge do |value|
      value.is_a?(::Hash) ? value : Bmc.boolean_to_symbol(value)
    end

    def should_to_s(value)
      value.is_a?(::Hash) ? value.inspect : "All => #{value}"
    end
  end

  newproperty(:ipmi, required_features: :ipmi) do
    desc 'Configure user access information on the ipmi channels. Default to true for all channels'
    defaultto true

    validate do |value|
      valid_channels = [true, false]
      if value.is_a?(::Hash)
        raise Puppet::Error, '%s contains at least one invalid boolean' % value.inspect unless (value.values - valid_channels).empty?
      else
        raise Puppet::Error, '%s is not a valid boolean' % value unless value.is_a?(TrueClass) || value.is_a?(FalseClass)
      end
    end

    munge do |value|
      value.is_a?(::Hash) ? value : Bmc.boolean_to_symbol(value)
    end

    def should_to_s(value)
      value.is_a?(::Hash) ? value.inspect : "All => #{value}"
    end
  end

  newproperty(:idrac, required_features: :racadm) do
    desc 'iDRAC User Privileges'
    defaultto 0x0
    validate do |value|
      unless value <= 0x1ff && value >= 0x0
        raise Puppet::Error, '%s is not a valid group privilege' % value
      end
    end

    def should_to_s(value)
      "0x#{value.to_s(16)}"
    end

    def to_s?(value)
      "0x#{value.to_s(16)}"
    end
  end
end
