require 'resolv'

Puppet::Type.newtype(:bmc_user) do

  @doc = "BMC local user administration."

  ensurable do
    defaultvalues
    defaultto :present
  end

  feature :racadm, 'Dell racadmin specific.'

  newparam(:name, :namevar => true) do
    desc 'Username of the user'
  end

  newproperty(:password) do
    desc 'Password used to login'
    def change_to_s(current, desire)
      'changed password'
    end
  end

  newproperty(:callin) do
    desc 'Configure user access information on the callin channel. Default to true'
    newvalues(:false, :true)
    defaultto true
  end

  newproperty(:link) do
    desc 'Configure user access information on the link channel. Default to true '
    newvalues(:false, :true)
    defaultto true
  end

  newproperty(:ipmi) do
    desc 'Configure user access information on the ipmi channel. Default to true'
    newvalues(:false, :true)
    defaultto true
  end

  newproperty(:privilege) do
    desc 'Force session privilege level'
    newvalues(:callback, :user, :operator, :administrator, :oem_proprietary, :no_access)
    defaultto :administrator
    munge do |priv|
      priv.upcase
    end
  end

  newproperty(:idrac, :required_features => :racadm) do
    desc 'iDRAC User Privileges'
    defaultto 0x0
    validate do |value|
      unless value <= 0x1ff && value >= 0x0
        raise Puppet::Error, "%s is not a valid group privilege" % value
      end
    end
    def should_to_s(value)
      "0x#{value.to_s(16)}"
    end
    def is_to_s(value)
      "0x#{value.to_s(16)}"
    end
  end

  newparam(:bmc_username) do
    desc 'Username used to connect with bmc service. Default to root'
    defaultto 'root'
  end

  newparam(:bmc_password) do
    desc 'Password used to connect with bmc service.'
  end

  newparam(:bmc_server_host) do
    desc 'RAC host address. Defaults to ipmitool lan print > IP Address'
    validate do |value|
      unless value =~ Resolv::IPv4::Regex || value =~ Resolv::IPv6::Regex
        raise Puppet::Error, "%s is not a valid ip address" % value
      end
    end
  end
end