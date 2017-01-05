require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'racadm', 'racadm.rb'))

Puppet::Type.type(:bmc_user).provide(:racadm7, :parent => :ipmitool) do

  desc "Manage local users via racadm7."

  has_feature :racadm

  confine :manufactor_id => :'674'
  confine :osfamily => [:redhat, :debian]
  confine :exists => '/opt/dell/srvadmin/bin/idracadm'

  defaultfor :osfamily => [:redhat, :debian]

  def create
    super
    self.idrac=(resource[:idrac]) unless resource[:link].nil?
  end

  def destroy
    self.idrac=(0)
    super
  end

  def idrac
    racadm_out = Racadm::Racadm.racadm_call(
        resource,
        ['get', "iDRAC.Users.#{@property_hash[:id]}"])
    idrac_user = Racadm::Racadm.parse_racadm racadm_out
    idrac_user['Privilege'].to_i(16)
  end

  def idrac= value
    Racadm::Racadm.racadm_call(
        resource,
        ['set', "iDRAC.Users.#{@property_hash[:id]}.Privilege", "0x#{value.to_s(16)}"])
  end
end