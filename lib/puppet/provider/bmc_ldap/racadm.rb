Puppet::Type.type(:bmc_ldap).provide(:racadm) do
  confine :operationsystem => [:redhat, :debian]
  defaultfor :osfamily => [:redhat, :debian]

  desc "Adminstrates ldap configuration on BMC interface"


  "Use the objects in the cfgLdap and cfgLdapRoleGroup groups with the config command."

end
