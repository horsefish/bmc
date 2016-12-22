require 'open3'
require 'tempfile'
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'racadm', 'racadm.rb'))

Puppet::Type.type(:bmc_network).provide(:racadm7, :parent => :ipmitool) do

  desc "Manage BMC network via racadm7."

  has_feature :racadm

  confine :manufactor_id => :'674'
  confine :osfamily => [:redhat, :debian]
  confine :exists => '/opt/dell/srvadmin/bin/idracadm'

  defaultfor :osfamily => [:redhat, :debian]

  def get_instance
    racadm_out = racadm_call ['get', 'iDRAC.IPv4']
    idrac_ipv4 = Racadm::Racadm.parse_racadm racadm_out
    @property_hash[:dns1] = idrac_ipv4['DNS1']
    @property_hash[:dns2] = idrac_ipv4['DNS2']
  end

  def dns1
    get_instance unless @property_hash.key?(:dns1)
    @property_hash[:dns1]
  end

  def dns1=value
    racadm_call ['set', 'iDRAC.IPv4.DNS1', value]
  end

  def dns2
    get_instance unless @property_hash.key?(:dns2)
    @property_hash[:dns2]
  end

  def dns2=value
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
      lan_print = Ipmi::Ipmitool.parseLan(ipmitool_out)
      cmd.push('-r').push(lan_print['IP Address'])
    end

    cmd += cmd_args
    stdout, stderr, status = Open3.capture3(cmd.join(' '))
    nr = cmd.index('-p')
    cmd.fill('<secret>', nr+1, 1) #password is not logged.
    raise(Puppet::Error, "#{cmd.join(' ')} failed with #{stderr}") unless status.success?
    Puppet.debug("#{cmd.join(' ')} executed with stdout: '#{stdout}' stderr: '#{stderr}' status: '#{status}'")
    stdout
  end
end
