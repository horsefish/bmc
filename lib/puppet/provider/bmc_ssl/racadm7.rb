require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'racadm', 'racadm.rb'))
require 'tempfile'

Puppet::Type.type(:bmc_ssl).provide(:racadm7) do

  desc "Manage SSL certificates via racadm7."

  has_feature :racadm

  confine :manufactor_id => :'674'
  confine :osfamily => [:redhat, :debian]
  confine :exists => '/opt/dell/srvadmin/bin/idracadm7'

  commands :ipmitool => 'ipmitool'

  mk_resource_methods

  def create
    unless resource[:certificate_key].nil?
      Racadm::Racadm.racadm_call(resource, ['sslkeyupload', '-t', resource[:type], '-f', resource[:certificate_key]])
    end
    Racadm::Racadm.racadm_call(resource, ['sslcertupload', '-t', resource[:type], '-f', resource[:certificate_file]])
    if resource[:type].to_s == '1'
      Racadm::Racadm.racadm_call(resource, ['racreset', 'soft'])
    end
  end

  def destroy
    if resource[:type].to_s == '1'
      Racadm::Racadm.racadm_call(resource, ['sslcertdelete', '-t', '3'])
      Racadm::Racadm.racadm_call(resource, ['racreset', 'soft'])
    end
  end

  def exists?
    exists = false
    tmp_file = Tempfile.new('bmc_ssl')

    Racadm::Racadm.racadm_call(resource, ['sslcertdownload', '-t', resource[:type], '-f', tmp_file.path], true)
    if File.file?(tmp_file.path)
      exists = FileUtils.compare_file(tmp_file.path, resource[:certificate_file])
      tmp_file.unlink
    end
    exists
  end
end
