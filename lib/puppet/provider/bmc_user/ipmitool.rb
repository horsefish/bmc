require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'ipmi', 'ipmitool.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'bmc.rb'))
require 'open3'

Puppet::Type.type(:bmc_user).provide(:ipmitool) do
  confine :osfamily => [:redhat, :debian]

  desc "Manage local users via ipmitool."

  has_feature :ipmi

  mk_resource_methods

  def self.prefetch(resources)
    call_info = {} #only support local ipmitool
    ipmitool_out_lan = Ipmi::Ipmitool.ipmi_call call_info, ['user', 'list', 1]
    users_lan = Ipmi::Ipmitool.parseUser(ipmitool_out_lan)
    ipmitool_out_serial = Ipmi::Ipmitool.ipmi_call call_info, ['user', 'list', 2]
    users_serial = Ipmi::Ipmitool.parseUser(ipmitool_out_serial)
    resources.each_value do |type|
      user_lan = users_lan.find { |x| x['name'] == type.name }
      user_serial = users_serial.find { |x| x['name'] == type.name }
      if user_lan.nil?
        type.provider = new(
            :ensure => :absent,
            :name => type.name
        )
      else
        type.provider = new(
            :id => user_lan['id'],
            :ensure => :present,
            :name => user_lan['name'],
            :callin =>
                {
                    '1' => user_lan['callin'],
                    '2' => user_serial['callin'],
                },
            :link =>
                {
                    '1' => user_lan['link_auth'],
                    '2' => user_serial['link_auth'],
                },

            :ipmi =>
                {
                    '1' => user_lan['ipmi_msg'],
                    '2' => user_serial['ipmi_msg'],
                },
            :privilege =>
                {
                    '1' => user_lan['channel_priv_limit'].downcase,
                    '2' => user_serial['channel_priv_limit'].downcase,
                }
        )
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def destroy
    @property_hash[:ensure] = :absent
    self.enable=(false)
    self.username=("''")
    self.password=("''")
    self.privilege=('no_access')
    self.callin=(false)
    self.link=(false)
    self.ipmi=(false)
  end

  def create
    @property_hash[:ensure] = :present
    @property_hash[:id] = next_free_id
    self.username=(resource[:name])
    self.password=(resource[:password]) unless resource[:password].nil?
    self.privilege=(resource[:privilege]) unless resource[:privilege].nil?
    self.callin=(resource[:callin]) unless resource[:callin].nil?
    self.link=(resource[:link]) unless resource[:link].nil?
    self.ipmi=(resource[:ipmi]) unless resource[:ipmi].nil?
    self.enable=(true)
  end

  def next_free_id
    ipmitool_out = Ipmi::Ipmitool.ipmi_call resource, ['user', 'summary', 1]
    summary = Ipmi::Ipmitool.parseSummay(ipmitool_out)
    maxID = summary['Maximum IDs'].to_i
    reserved = summary['Fixed Name Count'].to_i
    ipmitool_out = Ipmi::Ipmitool.ipmi_call resource, ['user', 'list', 1]
    users = Ipmi::Ipmitool.parseUser(ipmitool_out)
    current_user_count = users.count
    puts "max #{maxID} reserved #{reserved} count #{current_user_count}"
    empty_user = users.find { |user| user['name'].empty? }
    if empty_user.nil?
      for user_id in 2..current_user_count+1
        unless users.any? { |user| user['id'].to_i == user_id }
          free_id = user_id
        else
          # current_user_count + 2 is (current_user_count + user with id 1 + next number)
          if (current_user_count + reserved) < maxID
            free_id = current_user_count + 2
          else
            raise Puppet::Error, 'There are no free userids to assign to a new user'
          end
        end
      end
    else
      free_id = empty_user['id']
    end
    free_id
  end

  def enable= value
    Ipmi::Ipmitool.ipmi_call resource, ['user', value ? 'enable' : 'disable', @property_hash[:id]]
  end

  def username= value
    Ipmi::Ipmitool.ipmi_call resource, ['user', 'set', 'name', @property_hash[:id], value]
  end

  def password
    if Ipmi::Ipmitool.ipmi_current_password resource, @property_hash[:id], resource[:password]
      resource[:password]
    end
  end

  def password= value
    Ipmi::Ipmitool.ipmi_call resource, ['user', 'set', 'password', @property_hash[:id], value]
  end

  def privilege
    if resource[:privilege].class == Hash
      @property_hash[:privilege]
    else
      if @property_hash[:privilege].values.select! { |value| value == resource[:privilege] }.nil?
        resource[:privilege]
      else
        @property_hash[:privilege]
      end
    end
  end

  def privilege= value
    if value.class == Hash
      channel_1_priv = Bmc.role_to_s(value['1']) if value.has_key?('1')
      channel_2_priv = Bmc.role_to_s(value['2']) if value.has_key?('2')
    else
      channel_1_priv = Bmc.role_to_s(value)
      channel_2_priv = Bmc.role_to_s(value)
    end
    unless channel_1_priv.nil?
      Ipmi::Ipmitool.ipmi_call resource, ['channel', 'setaccess', 1, @property_hash[:id], "privilege=#{channel_1_priv}"]
    end
    unless channel_2_priv.nil?
      Ipmi::Ipmitool.ipmi_call resource, ['channel', 'setaccess', 2, @property_hash[:id], "privilege=#{channel_2_priv}"]
    end
  end

  def callin
    if resource[:callin].class == Hash
      @property_hash[:callin]
    else
      if @property_hash[:callin].values.select! { |value| value == resource[:callin] }.nil?
        resource[:callin]
      else
        @property_hash[:callin]
      end
    end
  end

  def callin= value
    if value.class == Hash
      channel_1_callin = Ipmi::Ipmitool.symbol_to_s(value['1']) if value.has_key?('1')
      channel_2_callin = Ipmi::Ipmitool.symbol_to_s(value['2']) if value.has_key?('2')
    else
      channel_1_callin = Ipmi::Ipmitool.symbol_to_s(value)
      channel_2_callin = Ipmi::Ipmitool.symbol_to_s(value)
    end
    unless channel_1_callin.nil?
      Ipmi::Ipmitool.ipmi_call resource, ['channel', 'setaccess', 1, @property_hash[:id], "callin=#{channel_1_callin}"]
    end
    unless channel_2_callin.nil?
      Ipmi::Ipmitool.ipmi_call resource, ['channel', 'setaccess', 2, @property_hash[:id], "callin=#{channel_2_callin}"]
    end
  end

  def link
    if resource[:link].class == Hash
      @property_hash[:link]
    else
      if @property_hash[:link].values.select! { |value| value == resource[:link] }.nil?
        resource[:link]
      else
        @property_hash[:link]
      end
    end
  end

  def link= value
    if value.class == Hash
      channel_1_link = Ipmi::Ipmitool.symbol_to_s(value['1']) if value.has_key?('1')
      channel_2_link = Ipmi::Ipmitool.symbol_to_s(value['2']) if value.has_key?('2')
    else
      channel_1_link = Ipmi::Ipmitool.symbol_to_s(value)
      channel_2_link = Ipmi::Ipmitool.symbol_to_s(value)
    end
    unless channel_1_link.nil?
      Ipmi::Ipmitool.ipmi_call resource, ['channel', 'setaccess', 1, @property_hash[:id], "link=#{channel_1_link}"]
    end
    unless channel_2_link.nil?
      Ipmi::Ipmitool.ipmi_call resource, ['channel', 'setaccess', 2, @property_hash[:id], "link=#{channel_2_link}"]
    end
  end

  def ipmi
    if resource[:ipmi].class == Hash
      @property_hash[:ipmi]
    else
      if @property_hash[:ipmi].values.select! { |value| value == resource[:ipmi] }.nil?
        resource[:ipmi]
      else
        @property_hash[:ipmi]
      end
    end
  end

  def ipmi= value
    if value.class == Hash
      channel_1_ipmi = Ipmi::Ipmitool.symbol_to_s(value['1']) if value.has_key?('1')
      channel_2_ipmi = Ipmi::Ipmitool.symbol_to_s(value['2']) if value.has_key?('2')
    else
      channel_1_ipmi = Ipmi::Ipmitool.symbol_to_s(value)
      channel_2_ipmi = Ipmi::Ipmitool.symbol_to_s(value)
    end
    unless channel_1_ipmi.nil?
      Ipmi::Ipmitool.ipmi_call resource, ['channel', 'setaccess', 1, @property_hash[:id], "ipmi=#{channel_1_ipmi}"]
    end
    unless channel_2_ipmi.nil?
      Ipmi::Ipmitool.ipmi_call resource, ['channel', 'setaccess', 2, @property_hash[:id], "ipmi=#{channel_2_ipmi}"]
    end
  end
end