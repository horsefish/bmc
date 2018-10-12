require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'racadm', 'racadm.rb'))
require 'tempfile'

Puppet::Type.type(:bmc_ssl).provide(:racadm7) do
  desc 'Manage SSL certificates via racadm7.'

  has_feature :racadm

  confine osfamily: [:redhat, :debian]
  confine exists: '/opt/dell/srvadmin/bin/idracadm7'

  mk_resource_methods

  def create
    unless resource[:certificate_key].nil?
      Racadm.racadm_call(resource, ['sslkeyupload', '-t', resource[:type], '-f', resource[:certificate_key]])
    end
    Racadm.racadm_call(resource, ['sslcertupload', '-t', resource[:type], '-f', resource[:certificate_file]])
  end

  def destroy
    return unless resource[:type].to_s == '1'
    Racadm.racadm_call(resource, ['sslcertdelete', '-t', '3'], true)
    Racadm.racadm_call(resource, ['sslresetcfg'])
  end

  def exists?
    exists = false
    tmp_file = Tempfile.new('bmc_ssl')

    Racadm.racadm_call(resource, ['sslcertdownload', '-t', resource[:type], '-f', tmp_file.path], true)
    if File.file?(tmp_file.path)
      exists = FileUtils.compare_file(tmp_file.path, resource[:certificate_file])
      tmp_file.unlink
    end
    exists
  end
end
