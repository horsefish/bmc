require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'racadm', 'racadm.rb'))
require 'tempfile'

Puppet::Type.type(:bmc_time).provide(:racadm7) do
  desc 'Manage Timezone and NTP via racadm7.'

  confine osfamily: [:redhat, :debian]
  confine exists: '/opt/dell/srvadmin/bin/idracadm7'
  defaultfor manufactor_id: :'674'

  mk_resource_methods

  def self.prefetch(resources)
    resources.each do |_key, type|
      racadm_out = Racadm::Racadm.racadm_call(
        {
          bmc_username: type.value(:bmc_username),
          bmc_password: type.value(:bmc_password),
          bmc_server_host: type.value(:bmc_server_host),
        },
        ['get', 'iDRAC.NTPConfigGroup'],
      )
      ntp_config_group = Racadm::Racadm.parse_racadm racadm_out
      ntp_servers = []
      ntp_servers[0] = ntp_config_group['NTP1'] unless ntp_config_group['NTP1'].empty?
      ntp_servers[1] = ntp_config_group['NTP2'] unless ntp_config_group['NTP2'].empty?
      ntp_servers[2] = ntp_config_group['NTP3'] unless ntp_config_group['NTP3'].empty?

      racadm_out = Racadm::Racadm.racadm_call(
        {
          bmc_username: type.value(:bmc_username),
          bmc_password: type.value(:bmc_password),
          bmc_server_host: type.value(:bmc_server_host),
        },
        ['get', 'iDRAC.Time'],
      )
      time = Racadm::Racadm.parse_racadm racadm_out
      type.provider = new(
        ntp_enable: Racadm::Racadm.s_to_bool(ntp_config_group['NTPEnable']),
        ntp_servers: ntp_servers,
        timezone: time['Timezone'],
      )
    end
  end

  def ntp_enable(value)
    Racadm::Racadm.racadm_call(
      resource,
      ['set', 'iDRAC.NTPConfigGroup.NTPEnable', Racadm::Racadm.bool_to_s(value)],
    )
  end

  def ntp_servers(value)
    ntp_servers = Array.new(3, "''")
    ntp_servers[0] = value[0] if value.size >= 1
    ntp_servers[1] = value[1] if value.size >= 2
    ntp_servers[2] = value[2] if value.size >= 3

    Racadm::Racadm.racadm_call(
      resource,
      ['set', 'iDRAC.NTPConfigGroup.NTP1', ntp_servers[0]],
    )
    Racadm::Racadm.racadm_call(
      resource,
      ['set', 'iDRAC.NTPConfigGroup.NTP2', ntp_servers[1]],
    )
    Racadm::Racadm.racadm_call(
      resource,
      ['set', 'iDRAC.NTPConfigGroup.NTP3', ntp_servers[2]],
    )
  end

  def timezone(value)
    Racadm::Racadm.racadm_call(
      resource,
      ['set', 'iDRAC.Time.Timezone', value],
    )
  end
end
