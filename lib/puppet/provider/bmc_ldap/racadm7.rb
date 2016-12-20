require 'open3'
require 'tempfile'

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'ipmi', 'ipmitool.rb'))

Puppet::Type.type(:bmc_ldap).provide(:racadm7) do

  confine :manufactor_id => :'674'
  confine :osfamily => [:redhat, :debian]
  confine :exists => '/opt/dell/srvadmin/bin/idracadm'

  commands :ipmitool => "ipmitool"

  desc "Adminstrates ldap configuration on BMC interface"

  mk_resource_methods

  def create
    @property_hash[:ensure] = :present
  end

  def destroy
  end

  def exists?
    racadm_out = racadm_call ['get', 'iDRAC.LDAP']
    iDRAC_LDAP = Racadm::Racadm.parse_racadm racadm_out
    @property_hash[:server] = iDRAC_LDAP['Server']
    @property_hash[:server_port] = iDRAC_LDAP['Port']
    @property_hash[:bind_dn] = iDRAC_LDAP['BindDN']
    @property_hash[:base_dn] = iDRAC_LDAP['BaseDN']
    @property_hash[:user_attribute] = iDRAC_LDAP['UserAttribute']
    @property_hash[:group_attribue] = iDRAC_LDAP['GroupAttribute']
    @property_hash[:search_filer] = iDRAC_LDAP['SearchFilter']
    @property_hash[:certificate_validate] = (iDRAC_LDAP['CertValidationEnable'].eql? 'Enabled').to_s
    if iDRAC_LDAP['Enable'].eql? 'Enabled'
      @property_hash[:ensure] = :present
      true
    else
      @property_hash[:ensure] = :absent
      false
    end
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