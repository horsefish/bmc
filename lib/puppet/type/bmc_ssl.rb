Puppet::Type.newtype(:bmc_ssl) do
  ensurable

  feature :racadm, 'Dell racadmin specific.'

  newparam(:name, :namevar => true) do
    desc 'Identification of the BMC SSL setup.'
  end

  newparam(:certificate_file) do
    validate do |value|
      unless File.file?(value)
        fail("#{value} must be a absolute path to a file")
      end
    end
    desc 'The certificate file.'
  end

  newparam(:certificate_key) do
    validate do |value|
      unless File.file?(value)
        fail("#{value} must be a absolute path to a file")
      end
    end
    desc 'The certificate file.'
  end

  newparam(:username) do
    desc 'username used to connect with bmc service.'
    defaultto 'root'
  end

  newparam(:password) do
    desc 'password used to connect with bmc service.'
  end

  newparam(:certificate_pass_phrase) do
    desc 'pass phrase for the Public Key Cryptography Standards file.'
  end

  newparam(:remote_rac_host) do
    desc 'RAC host address. Defaults to ipmitool lan print > IP Address'
    validate do |value|
      raise ArgumentError, "%s is not a valid ip address" % value unless (value =~ Resolv::IPv4::Regex || value =~ Resolv::IPv6::Regex)
    end
  end

  newparam(:type, :required_features => :racadm) do
    desc 'Type of certificate
      [1=server,2=CA certificate for Directory Service,3=Public Key Cryptography Standards file]'
    defaultto 1
  end

  validate do
    raise(Puppet::Error, "If username is set password must also be set") if (self[:password].nil? && !self[:username].nil?)
    raise(Puppet::Error, "If password is set username must also be set") if (self[:username].nil? and !self[:password].nil?)
    raise(Puppet::Error, "certificate_file must be set") if (self[:certificate_file].nil?)
    raise(Puppet::Error, "certificate_key must be set") if (self[:certificate_key].nil?)
  end

  autorequire(:file) do
    self[:certificate_file] if self[:certificate_file]
    self[:certificate_key] if self[:certificate_key]
  end
end