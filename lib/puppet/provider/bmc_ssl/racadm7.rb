require 'open3'
require 'tempfile'
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'ipmi', 'ipmitool.rb'))

Puppet::Type.type(:bmc_ssl).provide(:racadm7) do

  has_feature :racadm

  confine :manufactor_id => :'674'
  confine :osfamily => [:redhat, :debian]
  confine :exists => '/opt/dell/srvadmin/bin/idracadm'

  #this is to identify racadm8
  #confine :exists => '/opt/dell/srvadmin/bin/idracadm7'

  commands :ipmitool => 'ipmitool'

  mk_resource_methods

  def create
    cmd_args = ['sslkeyupload']
    cmd_args.push('-t').push(resource[:type])
    cmd_args.push('-f').push(resource[:certificate_key])
    racadm_call cmd_args

    cmd_args = ['sslcertupload']
    cmd_args.push('-t').push(resource[:type])
    cmd_args.push('-f').push(resource[:certificate_file])
    racadm_call cmd_args

    cmd_args = ['racreset']
    cmd_args.push('soft')
    racadm_call cmd_args
  end

  def destroy
    cmd_args = ['sslcertdelete']
    cmd_args.push('-t').push(resource[:type])
    racadm_call cmd_args

    cmd_args = ['racreset']
    cmd_args.push('soft')
    racadm_call cmd_args
  end

  def exists?
    exists = false
    tmp_file = Tempfile.new('bmc_ssl')
    cmd_args = ['sslcertdownload']
    cmd_args.push('-t').push(resource[:type])
    cmd_args.push('-f').push(tmp_file.path)
    racadm_call cmd_args
    if (File.file?(tmp_file.path))
      exists = FileUtils.compare_file(tmp_file.path, resource[:certificate_file])
      tmp_file.unlink
    end
    exists
  end

  #candiate to be moved to a shared lib
  def racadm_call cmd_args
    cmd = ['/opt/dell/srvadmin/bin/idracadm']
    cmd.push('-u').push(resource[:username]) if resource[:username]
    cmd.push('-p').push(resource[:password]) if resource[:password]
    if resource[:bmc_server_host]
      cmd.push('-r').push(resource[:bmc_server_host])
    else
      ipmitool_out = ipmitool('lan', 'print')
      lanPrint = Ipmi::Ipmitool.parseLan(ipmitool_out)
      cmd.push('-r').push(lanPrint['IP Address'])
    end

    command = cmd + cmd_args
    stdout, stderr, status = Open3.capture3(command.join(" "))
    nr = command.index('-p')
    command.fill('<secret>', nr+1, 1) #password is not logged.
    if !status.success?
      raise(Puppet::Error, "#{command.join(" ")} failed with #{stderr}")
    end
    Puppet.debug("#{command.join(" ")} executed with stdout: '#{stdout}' stderr: '#{stderr}' status: '#{status}'")
    stdout
  end
end
