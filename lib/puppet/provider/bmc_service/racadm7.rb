require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'racadm', 'racadm.rb'))

Puppet::Type.type(:bmc_service).provide(:racadm7) do
  confine osfamily: [:redhat, :debian]
  confine exists: '/opt/dell/srvadmin/bin/idracadm7'
  defaultfor manufactor_id: :'674'

  mk_resource_methods

  def restart
    Racadm::Racadm.racadm_call(resource, ['racreset', 'soft', '-f'])
  end
end
