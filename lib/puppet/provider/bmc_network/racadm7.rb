require 'open3'
require 'tempfile'
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'racadm', 'racadm.rb'))

Puppet::Type.type(:bmc_network).provide(:racadm7, :parent => :ipmitool) do

  has_feature :racadm

  confine :manufactor_id => :'674'
  confine :osfamily => [:redhat, :debian]
  confine :exists => '/opt/dell/srvadmin/bin/idracadm'

  defaultfor :osfamily => [:redhat, :debian]

  def dns1
    racadm_out = racadm_call ['get', 'iDRAC.IPv4']
    (Racadm::Racadm.parse_racadm racadm_out)['DNS1']
  end

  def dns1=(value)
    racadm_call ['set', 'iDRAC.IPv4.DNS1', value]
  end

  def dns2
    racadm_out = racadm_call ['get', 'iDRAC.IPv4']
    (Racadm::Racadm.parse_racadm racadm_out)['DNS2']
  end

  def dns2=(value)
    racadm_call ['set', 'iDRAC.IPv4.DNS2', value]
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
