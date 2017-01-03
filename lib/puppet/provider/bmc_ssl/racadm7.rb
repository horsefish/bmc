require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'racadm', 'racadm.rb'))
require 'tempfile'

Puppet::Type.type(:bmc_ssl).provide(:racadm7) do

  desc "Manage SSL certificates via racadm7."

  has_feature :racadm

  confine :manufactor_id => :'674'
  confine :osfamily => [:redhat, :debian]
  confine :exists => '/opt/dell/srvadmin/bin/idracadm'

  commands :ipmitool => 'ipmitool'

  mk_resource_methods

  def create
    Racadm::Racadm.racadm_call(resource, ['sslkeyupload', '-t', resource[:type], '-f', resource[:certificate_key]])
    Racadm::Racadm.racadm_call(resource, ['sslkeyupload', '-t', resource[:type], '-f', resource[:certificate_file]])
    Racadm::Racadm.racadm_call(resource, ['racreset', 'soft'])
  end

  def destroy
    Racadm::Racadm.racadm_call(resource, ['sslcertdelete', '-t', resource[:type]])
    Racadm::Racadm.racadm_call(resource, ['racreset', 'soft'])
  end

  def exists?
    exists = false
    tmp_file = Tempfile.new('bmc_ssl')

    Racadm::Racadm.racadm_call(resource, ['sslcertdownload', '-t', resource[:type], '-f', tmp_file.path])
    if File.file?(tmp_file.path)
      exists = FileUtils.compare_file(tmp_file.path, resource[:certificate_file])
      tmp_file.unlink
    end
    exists
  end
end
