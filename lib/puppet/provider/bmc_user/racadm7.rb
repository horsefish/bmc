require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'racadm', 'racadm.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'bmc.rb'))
require 'digest'

Puppet::Type.type(:bmc_user).provide(:racadm7) do

  desc "Manage local users via racadm7."

  has_feature :racadm

  mk_resource_methods

  confine :osfamily => [:redhat, :debian]
  confine :exists => '/opt/dell/srvadmin/bin/idracadm7'
  defaultfor :manufactor_id => :'674'

  def self.prefetch(resources)
    resources.each_value do |type|
      call_info = {
          :bmc_username => type.value(:bmc_username),
          :bmc_password => type.value(:bmc_password),
          :bmc_server_host => type.value(:bmc_server_host),
      }
      # the getconfig method is deprecated but have not been able to figure out how the alternative "get Idrac.Users"
      # support serach by username
      racadm_out = Racadm::Racadm.racadm_call(
          call_info,
          ['getconfig', '-u', "'#{type.name}'"], true)
      getconfig_user = Racadm::Racadm.parse_racadm racadm_out
      if getconfig_user.empty?
        type.provider = new(
            :ensure => :absent,
            :name => type.name,
        )
      else
        racadm_out = Racadm::Racadm.racadm_call(
            call_info,
            ['get', "iDRAC.Users.#{getconfig_user['# cfgUserAdminIndex']}"])
        idrac_user = Racadm::Racadm.parse_racadm racadm_out
        type.provider = new(
            :id => getconfig_user['# cfgUserAdminIndex'],
            :ensure => :present,
            :enable => Racadm::Racadm.s_to_bool(idrac_user['Enable']),
            :privilege =>
                {
                    'Lan' => Bmc.s_to_role(idrac_user['IpmiLanPrivilege']),
                    'Serial' => Bmc.s_to_role(idrac_user['IpmiSerialPrivilege'])
                },
            :idrac => idrac_user['Privilege'].to_i(16),
            :md5v3key => idrac_user['MD5v3Key'],
            :password_sha256 => idrac_user['SHA256Password'],
            :password_salt => idrac_user['SHA256PasswordSalt'],
            :snmpv3_authentication_type => ['SNMPv3AuthenticationType'],
            :snmpv3_enable => Racadm::Racadm.s_to_bool(idrac_user['SNMPv3Enable']),
            :snmpv3_privacy_type => ['SNMPv3PrivacyType'],
            :sol_enable => Racadm::Racadm.s_to_bool(idrac_user['SolEnable']),
            :name => idrac_user['UserName'],
        )
      end
    end
  end

  def privilege
    if resource[:privilege].class == Hash
      @property_hash[:privilege]
    else
      if @property_hash[:privilege].values.select! { |value| value == resource[:privilege] }.nil?
        resource[:privilege]
      else
        @property_hash[:privilege]
      end
    end
  end

  def privilege= value
    if value.class == Hash
      lanPriv = Bmc.role_to_s(value['Lan']) if value.has_key?('Lan')
      serialPriv = Bmc.role_to_s(value['Serial']) if value.has_key?('Serial')
    else
      lanPriv = Bmc.role_to_s(value)
      serialPriv = Bmc.role_to_s(value)
    end
    Racadm::Racadm.racadm_call(
        resource,
        ['set', "iDRAC.Users.#{@property_hash[:id]}.IpmiLanPrivilege", lanPriv]) unless lanPriv.nil?
    Racadm::Racadm.racadm_call(
        resource,
        ['set', "iDRAC.Users.#{@property_hash[:id]}.IpmiSerialPrivilege", serialPriv]) unless serialPriv.nil?
  end

  def password
    newpass = Digest::SHA256.hexdigest(
        resource[:password] +
            @property_hash[:password_salt].gsub(/../) { |pair| pair.hex.chr }).upcase
    resource[:password] if newpass.eql? @property_hash[:password_sha256]
  end

  def password= value
    Racadm::Racadm.racadm_call(
        resource, ['set', "iDRAC.Users.#{@property_hash[:id]}.Password", value])
  end

  def idrac= value
    Racadm::Racadm.racadm_call(
        resource, ['set', "iDRAC.Users.#{@property_hash[:id]}.Privilege", "0x#{value.to_s(16)}"])
  end

  def enable= value
    Racadm::Racadm.racadm_call(
        resource, ['set', "iDRAC.Users.#{@property_hash[:id]}.enable", Racadm::Racadm.bool_to_s(value)])
  end

  def username= value
    Racadm::Racadm.racadm_call(
        resource, ['set', "iDRAC.Users.#{@property_hash[:id]}.UserName", value])
  end

  def sol_enable= value
    Racadm::Racadm.racadm_call(
        resource, ['set', "iDRAC.Users.#{@property_hash[:id]}.SolEnable", Racadm::Racadm.bool_to_s(value)])
  end

  def next_free_id
    racadm_out = Racadm::Racadm.racadm_call(
        resource,
        ['get', "iDRAC.Users"])
    idrac_users = Racadm::Racadm.parse_racadm racadm_out
    idrac_users.each_key { | key |
      racadm_out = Racadm::Racadm.racadm_call( resource, ['get', key])
      idrac_user = Racadm::Racadm.parse_racadm racadm_out

      if !idrac_user['IpmiLanPrivilege'].nil? &&
          !(Racadm::Racadm.s_to_bool idrac_user['Enable']) &&
          idrac_user['UserName'].empty?
        return key.split('.').last
      end
    }
    raise Puppet::Error, 'There are no free userids to assign to a new user'
  end

  def create
    @property_hash[:ensure] = :present
    @property_hash[:id] = next_free_id
    self.username=(resource[:name]) unless resource[:name].nil?
    self.password=(resource[:password]) unless resource[:password].nil?
    self.idrac=(resource[:idrac]) unless resource[:idrac].nil?
    self.privilege=(resource[:privilege]) unless resource[:privilege].nil?
    self.sol_enable=true
    self.enable=true
  end

  def destroy
    self.enable=false
    self.sol_enable=false
    self.idrac=0
    self.privilege='no_access'
    self.password="''"
    self.username="''"
  end

  def exists?
    @property_hash[:ensure] == :present
  end
end