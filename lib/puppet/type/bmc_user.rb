Puppet::Type.newtype(:bmc_user) do

  @doc = "BMC user administration"

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name, :namevar => true) do
    desc 'Username of the user'
  end

  newproperty(:password) do
    def change_to_s(current, desire)
      'changed password'
    end
  end

  newproperty(:callin) do
    desc 'Configure user access information on the callin channel'
    newvalues(:false, :true)
    defaultto true
  end

  newproperty(:link) do
    desc 'Configure user access information on the link channel'
    newvalues(:false, :true)
    defaultto true
  end

  newproperty(:ipmi) do
    desc 'Configure user access information on the ipmi channel'
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
end