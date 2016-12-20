require 'puppet/parameter/boolean'

Puppet::Type.newtype(:bmc_ldap) do

  @doc = "BMC ldap comfiguration"

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name, :namevar => true) do
    desc 'Identification of the BMC LDAP setup.'
  end

  newproperty(:server) do
    desc 'LDAP Server Address.'
  end

  newproperty(:server_port) do
    desc 'LDAP Server Port.'
    defaultto 389
  end

  newproperty(:bind_dn) do
    desc 'Bind DN.'
  end

  newparam(:bind_password) do
    desc 'Bind password.'
  end

  newproperty(:base_dn) do
    desc 'Base DN to Search.'
  end

  newproperty(:user_attribute) do
    desc 'Attribute of User Login.'
    defaultto 'uid'
  end

  newproperty(:group_attribue) do
    desc 'Attribute of Group Membership.'
    defaultto 'member'
  end

  newproperty(:search_filer) do
    desc 'Search Filter.'
  end

  newproperty(:certificate_validate, :boolean => true) do
    desc 'Certificate Validation Enabled.'
    newvalues(:false, :true)
    defaultto true
  end

  newparam(:username) do
    desc 'username used to connect with bmc service.'
    defaultto 'root'
  end

  newparam(:password) do
    desc 'password used to connect with bmc service.'
  end

  newparam(:bmc_server_host) do
    desc 'RAC host address. Defaults to ipmitool lan print > IP Address'
    validate do |value|
      unless value =~ Resolv::IPv4::Regex || value =~ Resolv::IPv6::Regex
        raise Puppet::ResourceError, "%s is not a valid ip address" % value
      end
    end
  end

  validate do
    raise(Puppet::ResourceError, "server must be set") if self[:server].nil?
  end
end