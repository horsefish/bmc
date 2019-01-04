require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'ipmi', 'ipmitool.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'bmc.rb'))
require 'open3'

Puppet::Type.type(:bmc_user).provide(:ipmitool) do
  confine osfamily: [:redhat, :debian, :freebsd]
  desc 'Manage local users via ipmitool.'

  has_feature :ipmi

  commands ipmitool: 'ipmitool'

  mk_resource_methods

  def self.prefetch(resources)
    channel_possibilities = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 14, 15]
    channel_cache = Hash[channel_possibilities.map { |channel| [channel, nil] }]
    call_info = {
      bmc_username: resources.values[0].value(:bmc_username),
      bmc_password: resources.values[0].value(:bmc_password),
      bmc_server_host: resources.values[0].value(:bmc_server_host),
    }
    channel_possibilities.each do |channel|
      user_list = Ipmitool.ipmi_call call_info, ['-c', 'user', 'list', channel], true
      if user_list.empty?
        channel_cache.delete(channel)
      else
        channel_cache[channel] = Ipmitool.parse_user_csv user_list
      end
    end
    resources.each_value do |type|
      user = channel_cache.values[0].select { |x| x[:name] == type.name }[0]
      callin = {}
      link = {}
      ipmi = {}
      privilege = {}
      if user
        # the only way to find out if a user is enabled or disabled
        channel_getaccess = Ipmitool.ipmi_call call_info, ['channel', 'getaccess', channel_cache.keys[0], user[:id]]
        getaccess = Ipmitool.parse_channel_getaccess channel_getaccess
        channel_cache.each do |channel, users|
          channel_user = users.select { |x| x[:name] == type.name }[0]
          callin[channel] = channel_user[:callin]
          link[channel] = channel_user[:link]
          ipmi[channel] = channel_user[:ipmi]
          privilege[channel] = channel_user[:privilege].downcase
        end
        type.provider = new(
          id: user[:id],
          enable: 'enabled'.eql?(getaccess[:enable]) ? :true : :false,
          ensure: :present,
          name: user[:name],
          callin: callin,
          link: link,
          ipmi: ipmi,
          privilege: privilege,
        )
      else
        callin =
          if type.value(:callin).is_a?(::Hash)
            type.value(:callin)
          else
            Hash[channel_cache.map { |k, _v| [k, type.value(:callin)] }]
          end
        link =
          if type.value(:link).is_a?(::Hash)
            type.value(:link)
          else
            Hash[channel_cache.map { |k, _v| [k, type.value(:link)] }]
          end
        ipmi =
          if type.value(:ipmi).is_a?(::Hash)
            type.value(:ipmi)
          else
            Hash[channel_cache.map { |k, _v| [k, type.value(:ipmi)] }]
          end

        privilege =
          if type.value(:privilege).is_a?(::Hash)
            type.value(:privilege)
          else
            Hash[channel_cache.map { |k, _v| [k, type.value(:privilege)] }]
          end
        type.provider = new(
          ensure: :absent,
          name: type.name,
          callin: callin,
          link: link,
          ipmi: ipmi,
          privilege: privilege,
        )
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def destroy
    @property_hash[:ensure] = :absent
    self.enable = :false
    self.username = "''"
    self.password = "''"
    self.privilege = 'no_access'
    self.callin = :false
    self.link = :false
    self.ipmi = :false
  end

  def create
    @property_hash[:ensure] = :present
    @property_hash[:id] = next_free_id
    self.username = @resource[:name]
    self.password = @resource[:password] unless @resource[:password].nil?
    self.privilege = @resource[:privilege] unless @resource[:privilege].nil?
    self.callin = @resource[:callin] unless @resource[:callin].nil?
    self.link = @resource[:link] unless @resource[:link].nil?
    self.ipmi = @resource[:ipmi] unless @resource[:ipmi].nil?
    self.enable = :true
  end

  def next_free_id
    channel_possibilities = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 14, 15]
    working_channel = nil
    users = nil
    channel_possibilities.each do |channel|
      user_list = Ipmitool.ipmi_call @resource, ['-c', 'user', 'list', channel], true
      next if user_list.empty?
      working_channel = channel
      users = Ipmitool.parse_user_csv user_list
      break
    end
    user_summary = Ipmitool.ipmi_call @resource, ['-c', 'user', 'summary', working_channel]
    summary = Ipmitool.parse_user_summay_csv user_summary
    enabled_i = summary[:enabled_count].to_i
    max_i = summary[:max_count].to_i
    reserved_i = summary[:fixed_count].to_i

    if max_i == (enabled_i + reserved_i)
      raise Puppet::Error, 'There are no free userids to assign to a new user'
    end

    free_users = users.select do |user|
      channel_getaccess = Ipmitool.ipmi_call @resource, ['channel', 'getaccess', working_channel, user[:id]]
      getaccess = Ipmitool.parse_channel_getaccess channel_getaccess
      user[:name].nil? && 'no'.casecmp(getaccess[:fixed_name]).zero?
    end
    raise Puppet::Error, 'There are no free users that are not fixed and have a empty username' if free_users.empty?
    free_users[0][:id]
  end

  def enable=(value)
    Ipmitool.ipmi_call @resource, ['user', (value == :true) ? 'enable' : 'disable', @property_hash[:id]]
  end

  def username=(value)
    Ipmitool.ipmi_call @resource, ['user', 'set', 'name', @property_hash[:id], value]
  end

  def password=(value)
    Ipmitool.ipmi_call @resource, ['user', 'set', 'password', @property_hash[:id], value]
  end

  def password
    return unless Ipmitool.ipmi_current_password(@resource, @property_hash[:id], resource[:password])
    @resource[:password]
  end

  def privilege
    resource_privilege =
      if @resource[:privilege].is_a?(::Hash)
        Hash[@resource[:privilege].map { |key, v| [key.to_i, v] }].to_a
      else
        Hash[@property_hash[:privilege].map { |key, _v| [key, @resource[:privilege]] }].to_a
      end
    if (resource_privilege - @property_hash[:privilege].to_a).empty?
      @resource[:privilege]
    else
      @property_hash[:privilege]
    end
  end

  def privilege=(value)
    need_change =
      if value.is_a?(::Hash)
        value
      else
        Hash[@property_hash[:privilege].map { |key, _v| [key, value] }].to_h
      end
    need_change.map do |channel, role|
      Ipmitool.ipmi_call(
        @resource,
        ['channel', 'setaccess', channel, @property_hash[:id], "privilege=#{Ipmitool.role_to_s(role)}"],
      )
    end
  end

  def callin
    resource_callin =
      if @resource[:callin].is_a?(::Hash)
        Hash[@resource[:callin].map { |key, v| [key.to_i, v] }].to_a
      else
        Hash[@property_hash[:callin].map { |key, _v| [key, Bmc.symbol_to_boolean(@resource[:callin])] }].to_a
      end
    if (resource_callin - @property_hash[:callin].to_a).empty?
      @resource[:callin]
    else
      @property_hash[:callin]
    end
  end

  def callin=(value)
    need_change =
      if value.is_a?(::Hash)
        value
      else
        Hash[@property_hash[:callin].map { |key, _v| [key, Bmc.symbol_to_boolean(value)] }].to_h
      end
    need_change.map do |channel, callin|
      Ipmitool.ipmi_call(
        @resource,
        ['channel', 'setaccess', channel, @property_hash[:id], "callin=#{Ipmitool.boolean_to_s(callin)}"],
      )
    end
  end

  def link
    resource_link =
      if @resource[:link].is_a?(::Hash)
        Hash[@resource[:link].map { |key, v| [key.to_i, v] }].to_a
      else
        Hash[@property_hash[:link].map { |key, _v| [key, Bmc.symbol_to_boolean(@resource[:link])] }].to_a
      end
    if (resource_link - @property_hash[:link].to_a).empty?
      @resource[:link]
    else
      @property_hash[:link]
    end
  end

  def link=(value)
    need_change =
      if value.is_a?(::Hash)
        value
      else
        Hash[@property_hash[:link].map { |key, _v| [key, Bmc.symbol_to_boolean(value)] }].to_h
      end
    need_change.map do |channel, link|
      Ipmitool.ipmi_call(
        @resource,
        ['channel', 'setaccess', channel, @property_hash[:id], "link=#{Ipmitool.boolean_to_s(link)}"],
      )
    end
  end

  def ipmi
    resource_ipmi =
      if @resource[:ipmi].is_a?(::Hash)
        Hash[@resource[:ipmi].map { |key, v| [key.to_i, v] }].to_a
      else
        Hash[@property_hash[:ipmi].map { |key, _| [key, Bmc.symbol_to_boolean(@resource[:ipmi])] }].to_a
      end
    if (resource_ipmi - @property_hash[:ipmi].to_a).empty?
      @resource[:ipmi]
    else
      @property_hash[:ipmi]
    end
  end

  def ipmi=(value)
    need_change =
      if value.is_a?(::Hash)
        value
      else
        Hash[@property_hash[:ipmi].map { |key, _v| [key, Bmc.symbol_to_boolean(value)] }].to_h
      end
    need_change.map do |channel, ipmi|
      Ipmitool.ipmi_call(
        @resource,
        ['channel', 'setaccess', channel, @property_hash[:id], "ipmi=#{Ipmitool.boolean_to_s(ipmi)}"],
      )
    end
  end
end
