require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'racadm', 'racadm.rb'))

Puppet::Type.type(:bmc_network).provide(:racadm7, :parent => :ipmitool) do

  desc "Manage BMC network via racadm7."

  has_feature :racadm

  confine :manufactor_id => :'674'
  confine :osfamily => [:redhat, :debian]
  confine :exists => '/opt/dell/srvadmin/bin/idracadm'

  defaultfor :osfamily => [:redhat, :debian]

  def self.prefetch(resources)
    super
    resources.each_value do | type |
      racadm_out = Racadm::Racadm.racadm_call(
          {
              :bmc_username => type.value(:bmc_username),
              :bmc_password => type.value(:bmc_password),
              :bmc_server_host => type.value(:bmc_server_host)
          },
          ['get', 'iDRAC.IPv4'])
      idrac_ipv4 = Racadm::Racadm.parse_racadm racadm_out
      type.provider.instance_variable_get(:@property_hash)[:dns1] = idrac_ipv4['DNS1']
      type.provider.instance_variable_get(:@property_hash)[:dns2] = idrac_ipv4['DNS2']
    end
  end

  def dns1= value
    Racadm::Racadm.racadm_call(resource, ['set', 'iDRAC.IPv4.DNS1', value])
  end

  def dns2= value
    Racadm::Racadm.racadm_call(resource, ['set', 'iDRAC.IPv4.DNS2', value])
  end
end
