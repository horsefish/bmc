Puppet::Type.newtype(:bmc_user) do

  @doc = "BMC user administration typy"

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name, :namevar => TRUE) do
    desc 'Username of the user'
  end

  newparam(:password) do
    desc 'Password'
  end

  newparam(:userid) do
    desc 'UserId.'
  end

  newparam(:enable) do
    desc 'Set user to disabled or enabled, default is True'
    defaultto TRUE
  end

  newparam(:privilege) do
    desc 'Set privilege for user'
    newvalues(:callback, :user, :operator, :administrator)
    munge do |priv|
      case priv
        when :callback
          1
        when :user
          2
        when :operator
          3
        when :administrator
          4
      end
    end
  end

  newparam(:channel) do
    desc 'Channel number user is on, default to 1'
    defaultto 1
  end
end