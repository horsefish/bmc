require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'ipmi', 'ipmitool.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'bmc.rb'))
require 'open3'

Puppet::Type.type(:bmc_user).provide(:ipmitool) do
  confine osfamily: [:redhat, :debian]
  desc 'Manage local users via ipmitool.'

  has_feature :ipmi

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
      ipmitool_out = Ipmitool.ipmi_call call_info, ['-c', 'user', 'list', channel], true
      if ipmitool_out.empty?
        channel_cache.delete(channel)
      else
        channel_cache[channel] = Ipmitool.parse_user_csv ipmitool_out
      end
    end
    resources.each_value do |type|
      user = channel_cache.values[0].find { |x| x[:name] == type.name }
      if user
        callin = {}
        link_auth = {}
        ipmi_msg = {}
        privilege = {}
        channel_cache.each do |channel, users|
          channel_user = users.select { |x| x[:name] == type.name }[0]
          callin[channel] = channel_user[:callin]
          link[channel] = channel_user[:link]
          ipmi[channel] = channel_user[:ipmi]
          privilege[channel] = channel_user[:privilege].downcase
        end
        type.provider = new(
          id: user[:id],
          ensure: :present,
          name: user[:name],
          callin: callin,
          link: link_auth,
          ipmi: ipmi_msg,
          privilege: privilege,
        )
      else
        type.provider = new(
          ensure: :absent,
          name: type.name,
        )
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def destroy
    @property_hash[:ensure] = :absent
    self.enable = false
    self.username = "''"
    self.password = "''"
    self.privilege = 'no_access'
    self.callin = false
    self.link = false
    self.ipmi = false
  end

  def create
    @property_hash[:ensure] = :present
    @property_hash[:id] = next_free_id
    self.username = resource[:name]
    self.password = resource[:password] unless resource[:password].nil?
    self.privilege = resource[:privilege] unless resource[:privilege].nil?
    self.callin = resource[:callin] unless resource[:callin].nil?
    self.link = resource[:link] unless resource[:link].nil?
    self.ipmi = resource[:ipmi] unless resource[:ipmi].nil?
    self.enable = true
  end

  def next_free_id
    user_summary = Ipmitool.ipmi_call resource, ['-c', 'user', 'summary', 1]
    summary = Ipmitool.parse_user_summay_csv(user_summary)
    enabled_i = summary[:enabled_count].to_i
    max_i = summary[:max_count].to_i
    reserved_i = summary[:fixed_count].to_i

    if max_i == (enabled_i + reserved_i)
      raise Puppet::Error, 'There are no free userids to assign to a new user'
    end

    ipmitool_out = Ipmitool.ipmi_call resource, ['-c', 'user', 'list', 1]
    users = Ipmitool.parse_user_csv(ipmitool_out)

    empty_users = users.select { |user| user[:name].nil? }
    empty_users[1][:id]
  end

  def enable=(value)
    Ipmitool.ipmi_call resource, ['user', value ? 'enable' : 'disable', @property_hash[:id]]
  end

  def username=(value)
    Ipmitool.ipmi_call resource, ['user', 'set', 'name', @property_hash[:id], value]
  end

  def password=(value)
    Ipmitool.ipmi_call resource, ['user', 'set', 'password', @property_hash[:id], value]
  end

  def password
    return unless Ipmitool.ipmi_current_password resource, @property_hash[:id], resource[:password]
    resource[:password]
  end

  def privilege
    if resource[:privilege].class == Hash ||
       !@property_hash[:privilege].values.select! { |value| value == resource[:privilege] }.nil?
      @property_hash[:privilege]
    else
      resource[:privilege]
    end
  end

  def privilege=(value)
    a_hash = (value.class == Hash) ? value : @property_hash[:privilege]
    a_hash.map do |channel, role|
      Ipmitool.ipmi_call(
        resource,
        ['channel', 'setaccess', channel, @property_hash[:id], "privilege=#{Bmc.role_to_s(role)}"],
      )
    end
  end

  def callin
    if resource[:callin].class == Hash ||
       !@property_hash[:callin].values.select! { |value| value == resource[:callin] }.nil?
      @property_hash[:callin]
    else
      resource[:callin]
    end
  end

  def callin=(value)
    a_hash = (value.class == Hash) ? value : @property_hash[:callin]
    a_hash.map do |channel, role|
      Ipmitool.ipmi_call(
        resource,
        ['channel', 'setaccess', channel, @property_hash[:id], "callin=#{Bmc.role_to_s(role)}"],
      )
    end
  end

  def link
    if resource[:link].class == Hash ||
       !@property_hash[:link].values.select! { |value| value == resource[:link] }.nil?
      @property_hash[:link]
    else
      resource[:link]
    end
  end

  def link=(value)
    a_hash = (value.class == Hash) ? value : @property_hash[:link]
    a_hash.map do |channel, role|
      Ipmitool.ipmi_call(
        resource,
        ['channel', 'setaccess', channel, @property_hash[:id], "link=#{Bmc.role_to_s(role)}"],
      )
    end
  end

  def ipmi
    if resource[:ipmi].class == Hash ||
       !@property_hash[:ipmi].values.select! { |value| value == resource[:ipmi] }.nil?
      @property_hash[:ipmi]
    else
      resource[:ipmi]
    end
  end

  def ipmi=(value)
    a_hash = (value.class == Hash) ? value : @property_hash[:ipmi]
    a_hash.map do |channel, role|
      Ipmitool.ipmi_call(
        resource,
        ['channel', 'setaccess', channel, @property_hash[:id], "ipmi=#{Bmc.role_to_s(role)}"],
      )
    end
  end
end
