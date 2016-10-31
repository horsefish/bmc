Puppet::Type.newtype(:bmc_user) do

  @doc = "BMC user administration type, not that it is not possible to destroy a user, it can only be overwritten."

  newparam(:name, :namevar => true) do
    desc 'Username of the user'
  end

  newproperty(:password) do
    desc 'Password'
  end

  newparam(:userid) do
    desc 'UserId.'
  end

  newproperty(:enable, :boolean => true) do
    desc 'Set user to disabled or enabled, default is True'
    defaultto true
  end

  newparam(:overwrite, :boolean => true) do
    desc 'Should it overwrite existing user? This is to ensure that we do not overwrite a current user by accident.'
    defaultto false
  end

  newproperty(:privilege) do
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