require 'open3'
require 'tempfile'

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'ipmi', 'ipmitool.rb'))

Puppet::Type.type(:bmc_ldap).provide(:racadm7) do

  confine :manufactor_id => :'674'
  confine :osfamily => [:redhat, :debian]
  confine :exists => '/opt/dell/srvadmin/bin/idracadm'

  desc "Adminstrates ldap configuration on BMC interface"

  mk_resource_methods

  def create
    @property_hash[:ensure] = :present
  end

  def destroy
  end

  def exists?
    false
  end
end
