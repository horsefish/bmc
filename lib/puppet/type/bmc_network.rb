Puppet::Type.newtype(:bmc_network) do
  @doc = "BMC user network type"

  newproperty(:proto) do
    desc 'IP Address Source'
    newvalues(:static, :dynamic, :none, :bios)
    defaultto :static
  end

  newparam(:name, :namevar => true) do
    desc 'An arbitrary name used as the identity of the resource.'
  end

  newproperty(:ipaddr) do
    desc 'Ip Address'
    validate do |value|
      unless value =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/
        raise ArgumentError, "%s is not a valid ip address" % value
      end
    end
  end

  newproperty(:gateway) do
    desc 'Gateway'
    validate do |value|
      unless value =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/
        raise ArgumentError, "%s is not a valid gateway" % value
      end
    end
  end

  newproperty (:netmask) do
    desc 'Subnet Mask'
    validate do |value|
      unless value =~ /^\d{3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/
        raise ArgumentError, "%s is not a valid subnet mask" % value
      end
    end
  end

  newparam(:channel) do
    desc 'Channel number network is on, default to 1'
    defaultto 1
  end
end