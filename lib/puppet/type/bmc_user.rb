Puppet::Type.newtype(:bmc_user) do

  @doc = "BMC user administration typy"

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name, :namevar => true) do
    desc 'Username'
  end

  newparam(:password) do
    desc 'Password'
  end

  newparam(:userid) do
    desc 'UserId.'
  end

  newparam(:enable) do
    desc 'Set user to disabled or enabled, default is True'
    defaultto true
  end

  newparam(:privilege) do
    desc 'Set privilege for user'
  end

  newparam(:channel) do
    desc 'Channel number user is on, default to 1'
    defaultto 1
  end
end