require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'racadm', 'racadm.rb'))
require 'tempfile'

Puppet::Type.type(:bmc_syslog).provide(:racadm7) do
  desc 'Manage syslog configuration via racadm7.'

  confine osfamily: [:redhat, :debian]
  confine exists: '/opt/dell/srvadmin/bin/idracadm7'

  mk_resource_methods

  def self.prefetch(resources)
    resources.each do |_key, type|
      racadm_out = Racadm.racadm_call(
        {
          bmc_username: type.value(:bmc_username),
          bmc_password: type.value(:bmc_password),
          bmc_server_host: type.value(:bmc_server_host),
        },
        ['get', 'iDRAC.SysLog'],
      )
      syslog_config = Racadm.parse_racadm racadm_out
      syslog_servers = []
      syslog_servers[0] = syslog_config['Server1'] unless syslog_config['Server1'].empty?
      syslog_servers[1] = syslog_config['Server2'] unless syslog_config['Server2'].empty?
      syslog_servers[2] = syslog_config['Server3'] unless syslog_config['Server3'].empty?

      type.provider = new(
        syslog_enable: Racadm.s_to_bool(syslog_config['SysLogEnable']),
        syslog_servers: syslog_servers,
        port: syslog_config['Port'],
      )
    end
  end

  def syslog_enable=(value)
    Racadm.racadm_call(
      resource,
      ['set', 'iDRAC.SysLog.SysLogEnable', Racadm.bool_to_s(value)],
    )
  end

  def syslog_servers=(value)
    syslog_servers = Array.new(3, "''")
    syslog_servers[0] = value[0] if value.size >= 1
    syslog_servers[1] = value[1] if value.size >= 2
    syslog_servers[2] = value[2] if value.size >= 3

    Racadm.racadm_call(
      resource,
      ['set', 'iDRAC.SysLog.Server1', syslog_servers[0]],
    )
    Racadm.racadm_call(
      resource,
      ['set', 'iDRAC.SysLog.Server2', syslog_servers[1]],
    )
    Racadm.racadm_call(
      resource,
      ['set', 'iDRAC.SysLog.Server3', syslog_servers[2]],
    )
  end

  def port=(value)
    Racadm.racadm_call(
      resource,
      ['set', 'iDRAC.SysLog.Port', value],
    )
  end
end
