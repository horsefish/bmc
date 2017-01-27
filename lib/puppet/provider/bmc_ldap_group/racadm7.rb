require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'racadm', 'racadm.rb'))

Puppet::Type.type(:bmc_ldap_group).provide(:racadm7) do

  desc "Manage LDAP configuration via racadm7."

  confine :manufactor_id => :'674'
  confine :osfamily => [:redhat, :debian]
  confine :exists => '/opt/dell/srvadmin/bin/idracadm7'

  mk_resource_methods

  def self.prefetch(resources)
    resources.each do |key, type|
      racadm_out = Racadm::Racadm.racadm_call(
          {:bmc_username => type.value(:bmc_username),
           :bmc_password => type.value(:bmc_password),
           :bmc_server_host => type.value(:bmc_server_host)
          },
          ['get', "iDRAC.LDAPRoleGroup.#{key}"]
      )
      idrac_ldap_role_group = Racadm::Racadm.parse_racadm racadm_out
      type.provider = new(
          :group_nr => key,
          :role_group_dn => idrac_ldap_role_group['DN'],
          :role_group_privilege => idrac_ldap_role_group['Privilege'].to_i(16)
      )
    end
  end

  def role_group_privilege= value
    Racadm::Racadm.racadm_call(
        resource,
        ['set', "iDRAC.LDAPRoleGroup.#{resource[:name]}.Privilege", "0x#{value.to_s(16)}"]
    )
  end

  def role_group_dn= value
    Racadm::Racadm.racadm_call(
        resource,
        ['set', "iDRAC.LDAPRoleGroup.#{resource[:name]}.DN", value]
    )
  end
end