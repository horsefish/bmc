require 'resolv'

Puppet::Type.newtype(:bmc_ldap_group) do
  @doc = 'A resource type to handle LDAP groups.'

  newparam(:group_nr, namevar: true) do
    newvalues(1, 2, 3, 4, 5)
    desc 'LDAP group number'
  end

  newproperty(:role_group_dn) do
    desc 'It is the Domain Name of the group in this index.'
  end

  newproperty(:role_group_privilege) do
    desc 'A bit-mask defining the privileges associated with this particular group.
          Example of rights:
           admin = 0x1ff
           operator = 0x1f3
           Read Only = 0x1
           None = 0x000
          The complete list of rights in order:
            Login to iDRAC
            Configure iDRAC
            Configure Users
            Clear Logs
            Execute Server Control Commands
            Access Virtual Console
            Access Virtual Media
            Test Alerts
            Execute Diagnostic Commands'
    defaultto 0x0
    validate do |value|
      unless value <= 0x1ff && value >= 0x0
        raise Puppet::Error, '%s is not a valid group privilege' % value
      end
    end

    def should_to_s(value)
      "0x#{value.to_s(16)}"
    end

    def to_s(value)
      "0x#{value.to_s(16)}"
    end
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
end
