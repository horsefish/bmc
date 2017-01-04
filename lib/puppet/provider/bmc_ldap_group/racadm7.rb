require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'racadm', 'racadm.rb'))

Puppet::Type.type(:bmc_ldap_group).provide(:racadm7) do

  desc "Manage LDAP configuration via racadm7."

  confine :manufactor_id => :'674'
  confine :osfamily => [:redhat, :debian]
  confine :exists => '/opt/dell/srvadmin/bin/idracadm'

  commands :ipmitool => 'ipmitool'

  mk_resource_methods

  def self.prefetch(resources)
    resources.each do |key, type|
      racadm_out = Racadm::Racadm.racadm_call(
          {:username => type.value(:username),
           :password => type.value(:password),
           :bmc_server_host => type.value(:bmc_server_host)},
          ['get', "iDRAC.LDAPRoleGroup.#{key}"])
      iDRAC_LDAPRoleGroup = Racadm::Racadm.parse_racadm racadm_out
      type.provider = new(
          :group_nr => key,
          :role_group_dn => iDRAC_LDAPRoleGroup['DN'],
          :role_group_privilege => iDRAC_LDAPRoleGroup['Privilege'].to_i(16)
      )
    end
  end

  def role_group_privilege= value
    Racadm::Racadm.racadm_call(
        resource,
        ['set', "iDRAC.LDAPRoleGroup.#{resource[:name]}.Privilege", "0x#{value.to_s(16)}"])
  end

  def role_group_dn= value
    Racadm::Racadm.racadm_call(
        resource,
        ['set', "iDRAC.LDAPRoleGroup.#{resource[:name]}.DN", value])
  end
end