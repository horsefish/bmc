require 'resolv'

Puppet::Type.newtype(:dell_bios) do
  @doc = 'A resource type to configure DELL bios.'

  newparam(:bmc_server_host, namevar: true) do
    desc 'localhost or RAC IP address'
    validate do |value|
      unless value == 'localhost' || value =~ Resolv::IPv4::Regex || value =~ Resolv::IPv6::Regex
        raise Puppet::Error, '%s is not localhost or a valid ip address' % value
      end
    end
  end

  newparam(:bmc_username) do
    desc 'Username used to connect with bmc service.'
  end

  newparam(:bmc_password) do
    desc 'Password used to connect with bmc service.'
  end

  newproperty(:values) do
    validate do |value|
      unless value.is_a?(::Hash)
        raise Puppet::Error, '%s must be a hash' % value
      end
    end

    def should_to_s(value)
      real_password_fields = { 'SysSecurity' => ['SetupPassword', 'SysPassword'] }
      value.each do |groupname, group_details|
        real_password_fields_group = real_password_fields[groupname]
        next if real_password_fields_group.nil?
        group_details.each do |k, _v|
          if real_password_fields_group.include? k
            group_details[k] = '<secret>'
          end
        end
      end
    end

    def is_to_s(value)
      real_password_fields = { 'SysSecurity' => ['SetupPassword', 'SysPassword'] }
      value.each do |groupname, group_details|
        real_password_fields_group = real_password_fields[groupname]
        next if real_password_fields_group.nil?
        group_details.each do |k, _v|
          if real_password_fields_group.include? k
            group_details[k] = '<secret>'
          end
        end
      end
    end
  end

  validate do
    unless self[:bmc_server_host] == 'localhost'
      if self[:bmc_password].nil? || self[:bmc_username].nil?
        raise Puppet::Error, "login and password must be set when bmc_server_host is not 'localhost'"
      end
    end
  end
end
