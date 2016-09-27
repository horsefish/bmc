Puppet::Type.newtype(:bmc_user) do

  @doc = "BMC user network type"

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:proto) do
    desc 'IP Address Source'
    newvalues(:static, :dynamic)
  end

  newparam(:ipaddr, :namevar => true) do
    desc 'Ip Address'
    validate do |value|
      unless value =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/
        raise ArgumentError, "%s is not a valid ip address" % value
      end
    end
  end

  newparam(:gateway) do
    desc 'Gateway'
    validate do |value|
      unless value =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/
        raise ArgumentError, "%s is not a valid gateway" % value
      end
    end
  end

  newparam(:subnet) do
    desc 'Subnet Mask'
    validate do |value|
      unless value =~ /^\d{3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/
        raise ArgumentError, "%s is not a valid subnet mask" % value
      end
    end
  end

  newparam(:channel) do
    desc 'Channel number user is on, default to 1'
    defaultto 1
  end
end