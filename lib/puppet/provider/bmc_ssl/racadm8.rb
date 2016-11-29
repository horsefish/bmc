Puppet::Type.type(:bmc_ssl).provide(:racadm8) do

  has_feature :racadm

  confine :manufactor_id => :'674'
  confine :osfamily => [:redhat, :debian]
  confine :exists => '/opt/dell/srvadmin/bin/idracadm7'

  defaultfor :osfamily => [:redhat, :debian]

  mk_resource_methods

  def create

  end

  def destroy

  end

  def exists?
  end

end
