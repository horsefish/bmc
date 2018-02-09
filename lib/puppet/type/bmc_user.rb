require 'resolv'

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

    def is_to_s(_value)
      '<secret>'
    end

    def change_to_s(_current, _desire)
      'changed password'
    end
  end

  newproperty(:callin, required_features: :ipmi) do
    desc 'Configure user access information on the callin channels. Default to true for all channels'
    defaultto true

    validate do |value|
      valid_channels = [true, false]
      if value.class == Hash
        unless (value.values - valid_channels).empty?
          raise Puppet::Error, '%s contains at least one invalid boolean' % value.inspect
        end
      else
        unless value.is_a?(TrueClass) || value.is_a?(FalseClass)
          raise Puppet::Error, '%s is not a valid boolean' % value
        end
      end
    end

    munge do |value|
      unless value.class == Hash
        Bmc.munge_boolean(value)
      end
    end

    def should_to_s(value)
      (value.class == Hash) ? value.inspect : "All => #{value}"
    end
  end

  newproperty(:link, required_features: :ipmi) do
    desc 'Configure user access information on the link channels. Default to true for all channels'
    defaultto true

    validate do |value|
      valid_channels = [true, false]
      if value.class == Hash
        unless (value.values - valid_channels).empty?
          raise Puppet::Error, '%s contains at least one invalid boolean' % value.inspect
        end
      else
        unless value.is_a?(TrueClass) || value.is_a?(FalseClass)
          raise Puppet::Error, '%s is not a valid boolean' % value
        end
      end
    end

    munge do |value|
      unless value.class == Hash
        Bmc.munge_boolean(value)
      end
    end

    def should_to_s(value)
      (value.class == Hash) ? value.inspect : "All => #{value}"
    end
  end

  newproperty(:ipmi, required_features: :ipmi) do
    desc 'Configure user access information on the ipmi channels. Default to true for all channels'
    defaultto true

    validate do |value|
      valid_channels = [true, false]
      if value.class == Hash
        unless (value.values - valid_channels).empty?
          raise Puppet::Error, '%s contains at least one invalid boolean' % value.inspect
        end
      else
        unless value.is_a?(TrueClass) || value.is_a?(FalseClass)
          raise Puppet::Error, '%s is not a valid boolean' % value
        end
      end
    end

    munge do |value|
      unless value.class == Hash
        Bmc.munge_boolean(value)
      end
    end

    def should_to_s(value)
      (value.class == Hash) ? value.inspect : "All => #{value}"
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

    def is_to_s(value)
      "0x#{value.to_s(16)}"
    end
  end

  # This is a feature for racadm only because ipmitool can set the value enable/disable BUT
  # for some reason you can not get ipmitool to tell you if a user is enabled or disabled.
  newproperty(:enable, required_features: :racadm) do
    desc 'Indicates whether the user login state is enabled or disabled'
    defaultto true
  end

  newproperty(:privilege) do
    desc 'Maximum privilege granted. Defaults to administrator for all'
    defaultto 'administrator'

    validate do |value|
      valid_roles = %w[callback user operator administrator oem_proprietary no_access]
      if value.class == Hash
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
      (value.class == Hash) ? value.inspect : "All => #{value}"
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
end
