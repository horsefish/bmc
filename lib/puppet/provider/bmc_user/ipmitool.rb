require 'open3'

Puppet::Type.type(:bmc_user).provide(:ipmitool) do
  confine :osfamily => [:redhat, :debian]
  defaultfor :osfamily => [:redhat, :debian]

  desc "Manage local users via ipmitool."

  commands :ipmitool => 'ipmitool'

  mk_resource_methods

  def self.instances
    users = []
    (0..15).each do |channel|
      begin
        ipmitool_out = ipmitool('user', 'list', channel)
        Ipmi::Ipmitool.parseUser(ipmitool_out).each do |user|
          users << new(:id => user['id'],
                       :channel => channel,
                       :ensure => :present,
                       :name => user['name'],
                       :callin => user['callin'],
                       :link => user['link_auth'],
                       :ipmi => user['ipmi_msg'],
                       :privilege => user['channel_priv_limit']
          )
        end
      rescue Puppet::ExecutionFailure
        debug "No users in channel #{channel}"
      end
    end
    return users
  end

  def self.prefetch(resources)
    users = instances
    resources.keys.each do |name|
      if provider = users.find { |user| user.name == name }
        resources[name].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def destroy
    @property_hash[:ensure] = :absent
    ipmitool('user', 'set', 'name', @property_hash[:id], '')
    ipmitool('user', 'set', 'password', @property_hash[:id], '')
    ipmitool('user', 'disable', @property_hash[:id])
  end

  def create
    @property_hash[:ensure] = :present
    ipmitool_out = ipmitool('user', 'list', 1)
    users = Ipmi::Ipmitool.parseUser(ipmitool_out)
    current_user_count = users.count

    empty_user = users.find { |user| user['name'].empty? }
    if not empty_user.empty?
      ipmitool('user', 'set', 'name', empty_user['id'], resource[:name])
      @property_hash[:id] = empty_user['id']
    else
      for user_id in 2..current_user_count+1
        unless users.any? { |user| user['id'].to_i == user_id }
          @property_hash[:id] = user_id
          ipmitool('user', 'set', 'name', user_id, resource[:name])
        end
      end
    end
  end

  def password
    cmd = "ipmitool user test #{@property_hash[:id]} 20 "
    stdout, stderr, status = Open3.capture3(cmd + resource[:password])
    Puppet.debug("#{cmd} <secret> executed with stdout: '#{stdout}' stderr: '#{stderr}' status: '#{status}'")
    if status.success?
      resource[:password]
    elsif stdout.include?('wrong password size')
      cmd = "ipmitool user test #{@property_hash[:id]} 16 "
      stdout, stderr, status = Open3.capture3(cmd + resource[:password])
      Puppet.debug("#{cmd} <secret> executed with stdout: '#{stdout}' stderr: '#{stderr}' status: '#{status}'")
      if status.success?
        resource[:password]
      else
        'ThisWillMakeSurePuppetUpdateUser'
      end
    else
      'ThisWillMakeSurePuppetUpdateUser'
    end
  end

  def password=newpass
    cmd = "ipmitool user set password #{@property_hash[:id]} "
    stdout, stderr, status = Open3.capture3(cmd + newpass)
    Puppet.debug("#{cmd} <secret> executed with stdout: '#{stdout}' stderr: '#{stderr}' status: '#{status}'")
    if status.success?
      ipmitool('user', 'enable', @property_hash[:id])
    else
      raise Puppet::Error, "bmc_user '#{resource[:name]}' could not change password: #{stderr}"
    end
  end

  def privilege=value
    case value
      when :CALLBACK, 'CALLBACK'
        priv = 1
      when :USER, 'USER'
        priv = 2
      when :OPERATOR, 'OPERATOR'
        priv = 3
      when :ADMINISTRATOR, 'ADMINISTRATOR'
        priv = 4
      when :OEM_PROPRIETARY, 'OEM_PROPRIETARY'
        priv = 5
      when :NO_ACCESS, 'NO_ACCESS'
        priv = 15
      else
        raise Puppet::Error, "Unknown channel: #{value}"
    end
    channels = get_channels_by_user @property_hash[:id]
    channels.each do |channel|
      ipmitool('channel', 'setaccess', channel, @property_hash[:id], "privilege=#{priv}")
    end
  end

  def callin=value
    if value
      callin_value = 'on'
    else
      callin_value = 'off'
    end
    channels = get_channels_by_user @property_hash[:id]
    channels.each do |channel|
      ipmitool('channel', 'setaccess', channel, @property_hash[:id], "callin=#{callin_value}")
    end
  end

  def link=value
    if value
      link_value = 'on'
    else
      link_value = 'off'
    end
    channels = get_channels_by_user @property_hash[:id]
    channels.each do |channel|
      ipmitool('channel', 'setaccess', channel, @property_hash[:id], "link=#{link_value}")
    end
  end

  def ipmi=value
    if value
      ipmi_value = 'on'
    else
      ipmi_value = 'off'
    end
    channels = get_channels_by_user @property_hash[:id]
    channels.each do |channel|
      ipmitool('channel', 'setaccess', channel, @property_hash[:id], "ipmi=#{ipmi_value}")
    end
  end

  def get_channels_by_user id
    channels = []
    (0..15).each do |channel|
      begin
        ipmitool('channel', 'getaccess', channel, @property_hash[:id])
        channels << channel
      rescue Puppet::ExecutionFailure
        debug "User not in channel #{channel}"
      end
    end
    channels
  end
end