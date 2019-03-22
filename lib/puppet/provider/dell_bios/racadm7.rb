require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'racadm', 'racadm.rb'))

Puppet::Type.type(:dell_bios).provide(:racadm7) do
  desc 'Manage DELL bios via racadm7.'

  mk_resource_methods

  confine osfamily: [:redhat, :debian]
  confine exists: '/opt/dell/srvadmin/bin/idracadm7'

  def self.prefetch(resources)
    # This is needed because DELL api is a bit inconsistent in it's password annotation.
    #
    # ie
    # /opt/dell/srvadmin/bin/idracadm7 get BIOS.SysSecurity
    #  SetupPassword=******** (Write-Only)
    #  SysPassword=******** (Write-Only)
    #
    # /opt/dell/srvadmin/bin/idracadm7 get iDRAC.Users.2
    #  !!Password=******** (Write-Only)
    #
    real_password_fields = { 'SysSecurity' => ['SetupPassword', 'SysPassword'] }

    resources.each do |name, type|
      # warning original_parameters is part of the private API
      groups = type.original_parameters[:values]
      current_values = {}
      groups.each do |groupname, group_details|
        racadm_out = Racadm.racadm_call(
          {
            bmc_username: type.value(:bmc_username),
            bmc_password: type.value(:bmc_password),
            bmc_server_host: type.value(:bmc_server_host),
          },
          ['get', "BIOS.#{groupname}"],
        )
        settings = Racadm.parse_racadm racadm_out
        relevant_settings = settings.select { |k, _v| group_details.key? k }
        real_password_fields_group = real_password_fields[groupname]
        unless real_password_fields_group.nil?
          relevant_settings.each do |k, v|
            if real_password_fields_group.include? k
              if Racadm.password_changed?(
                group_details[k],
                settings["SHA256#{k}"],
                settings["SHA256#{k}Salt"],
              )
                # to ensure that puppet notice the password is changed
                relevant_settings[k] = group_details[k] + '_'
              else
                relevant_settings[k] = group_details[k]
              end
            else
              relevant_settings[k] = v
            end
          end
        end
        current_values[groupname] = relevant_settings
      end
      provider = new(name: name, values: current_values)
      resources[name].provider = provider
    end
  end

  def values=(value)
    # Because each change is a isolated call that can be very expensive we only call if value has changed.
    value.each do |groupname, group_details|
      group_details.each do |detail, detail_value|
        next unless detail_value.eql? @property_hash[:values][groupname][detail]
        Racadm.racadm_call(
          @resource,
          ['set', "BIOS.#{groupname}.#{detail}", detail_value],
        )
        # TODO: consider a try/cacth and handle reply
      end
    end
    create_job_and_restart
  end

  def create_job_and_restart
    wait_seconds = 60

    racadm_out = Racadm.racadm_call(
      @resource,
      ['getractime', '-d'],
    )

    rac_execute_at = Time.new(
      racadm_out[0, 4], # year
      racadm_out[4, 2], # month
      racadm_out[6, 2], # day
      racadm_out[8, 2], # hour
      racadm_out[10, 2], # minute
      racadm_out[12, 2], # second
    ) + wait_seconds

    Racadm.racadm_call(
      @resource,
      [
        'jobqueue',
        'create',
        'BIOS.Setup.1-1',
        '-s', rac_execute_at.strftime('%Y%m%d%H%M%S'),
        '-e', (rac_execute_at + 600).strftime('%Y%m%d%H%M%S'),
        '-r', 'forced'
      ],
    )
    # TODO: parse output
    notice("Will reboot machine and configure BIOS in #{wait_seconds} sec")
  end
end
