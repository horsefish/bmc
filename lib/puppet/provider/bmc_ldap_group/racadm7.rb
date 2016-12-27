require 'open3'
require 'tempfile'

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'ipmi', 'ipmitool.rb'))

Puppet::Type.type(:bmc_ldap_group).provide(:racadm7) do

  desc "Manage LDAP configuration via racadm7."

  confine :manufactor_id => :'674'
  confine :osfamily => [:redhat, :debian]
  confine :exists => '/opt/dell/srvadmin/bin/idracadm'

  commands :ipmitool => 'ipmitool'

  mk_resource_methods

  def initialize(value={})
    super(value)
    #This is to overcome that namevar doesn't support defaultto
    if value.name.to_s == value.title.to_s
      group_nr = 1
    else
      group_nr = value.name
    end
  end

  def role_group_dn=value

  end

  def role_group_privilege=value

  end
end