require 'resolv'

Puppet::Type.newtype(:bmc_ldap) do
  @doc = 'A resource type to handle BMC LDAP comfiguration.'

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name, namevar: true) do
    desc 'Identification of the BMC LDAP setup.'
  end

  newproperty(:server) do
    desc 'LDAP Server Address.( FQDN or IP, must match the server certificate if certificate validation is enabled )'
  end

  newproperty(:server_port) do
    desc 'LDAP Server Port. Default to 636'
    defaultto 636
  end

  newproperty(:bind_dn) do
    desc 'Bind DN. ( required if anonymous bind is not allowed )'
  end

  newproperty(:base_dn) do
    desc 'Base DN to Search.( e.g. dc=example,dc=com, required )'
  end

  newproperty(:user_attribute) do
    desc 'Attribute of User Login. Default to uid'
    defaultto 'uid'
  end

  newproperty(:group_attribue) do
    desc 'Attribute of Group Membership. ( e.g. member or uniquemember ) Default to member'
    defaultto 'member'
  end

  newproperty(:search_filer) do
    desc 'Search Filter. ( e.g. objectclass=*, optional )'
  end

  newproperty(:certificate_validate, boolean: true) do
    desc 'Certificate Validation Enabled. Default to true'
    newvalues(false, true)
    defaultto true
  end

  newproperty(:group_attribute_is_dn, boolean: true) do
    desc 'Use Distinguished Name to Search Group Membership. ( if unchecked, username will be used ). Default to true'
    newvalues(false, true)
    defaultto true
  end

  newparam(:bind_password) do
    desc 'Bind password.( required if anonymous bind is not allowed ).'
  end

  newparam(:bmc_username) do
    desc 'username used to connect with bmc service.'
  end

  newparam(:bmc_password) do
    desc 'password used to connect with bmc service.'
  end

  newparam(:bmc_server_host) do
    desc 'RAC host address. Defaults to ipmitool lan print > IP Address'
    validate do |value|
      unless value =~ Resolv::IPv4::Regex || value =~ Resolv::IPv6::Regex
        raise Puppet::Error, '%s is not a valid IP address' % value
      end
    end
  end

  validate do
    raise(Puppet::Error, 'server must be set') if self[:server].nil?
    raise(Puppet::Error, 'base_dn must be set') if self[:base_dn].nil?
    if !self[:bmc_server_host].nil? && (self[:bmc_username].nil? || self[:bmc_password].nil?)
      raise(Puppet::Error,
            'if bmc_server_host param set you also must set both username and password')
    end
  end
end
