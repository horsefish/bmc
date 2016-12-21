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
    racadm_call ['set', 'iDRAC.LDAP.Enable', 'Enabled']
    self.server= resource[:server]
    self.group_attribute_is_dn= resource[:group_attribute_is_dn]
    self.server_port= resource[:server_port]
    self.bind_dn= resource[:bind_dn]
    racadm_call ['set', 'iDRAC.LDAP.BindPassword', resource[:bind_password]]
    self.base_dn= resource[:base_dn]
    self.user_attribute= resource[:user_attribute]
    self.group_attribue= resource[:group_attribue]
    self.certificate_validate = resource[:certificate_validate]
  end

  def destroy
    racadm_call ['set', 'iDRAC.LDAP.Enable', 'Disabled']
    self.server= "''"
    self.group_attribute_is_dn= :true
    self.server_port= 636
    self.bind_dn= "''"
    racadm_call ['set', 'iDRAC.LDAP.BindPassword', "''"]
    self.base_dn = "''"
    self.user_attribute= "''"
    self.group_attribue= "''"
    self.certificate_validate = :true
    @property_hash[:ensure] = :absent
  end

  def exists?
    unless @property_hash.key? :ensure
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
      @property_hash[:group_attribute_is_dn] = (iDRAC_LDAP['GroupAttributeIsDN'].eql? 'Enabled').to_s
      @property_hash[:ensure] = (iDRAC_LDAP['Enable'].eql? 'Enabled') ? :present : :absent
    end
    @property_hash[:ensure] == :present
  end

  def server= value
    racadm_call ['set', 'iDRAC.LDAP.Server', value]
  end

  def server_port= value
    racadm_call ['set', 'iDRAC.LDAP.Port', value]
  end

  def bind_dn= value
    racadm_call ['set', 'iDRAC.LDAP.BindDN', value]
  end

  def base_dn= value
    racadm_call ['set', 'iDRAC.LDAP.BaseDN', value]
  end

  def user_attribute= value
    racadm_call ['set', 'iDRAC.LDAP.UserAttribute', value]
  end

  def group_attribue= value
    racadm_call ['set', 'iDRAC.LDAP.GroupAttribute', value]
  end

  def search_filer= value
    racadm_call ['set', 'iDRAC.LDAP.SearchFilter', value]
  end

  def certificate_validate= value
    racadm_call ['set', 'iDRAC.LDAP.CertValidationEnable', value == :true ? "Enabled" : "Disabled"]
  end

  def group_attribute_is_dn= value
    racadm_call ['set', 'iDRAC.LDAP.GroupAttributeIsDN', value == :true ? "Enabled" : "Disabled"]
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