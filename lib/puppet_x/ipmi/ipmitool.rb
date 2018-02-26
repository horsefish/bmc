require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'puppet_x', 'bmc.rb'))
require 'open3'
require 'csv'

# Ipmitool specific Utilily class
class Ipmitool
  def self.symbol_to_s(value)
    (value == :true) ? 'on' : 'off'
  end

  def self.boolean_to_s(value)
    value ? 'on' : 'off'
  end

  def self.s_to_bool(value)
    value.eql? 'on'
  end

  def self.ipmi_call(ipmi_args, cmd_args, suppress_error = false)
    cmd = ['/usr/bin/ipmitool']
    unless ipmi_args[:bmc_server_host].nil? ||
           ipmi_args[:bmc_username].nil? ||
           ipmi_args[:bmc_password].nil?
      cmd.push('-U').push(ipmi_args[:bmc_username])
      cmd.push('-P').push(ipmi_args[:bmc_password])
      cmd.push('-H').push(ipmi_args[:bmc_server_host])
      cmd.push('-I').push('lanplus')
    end
    cmd += cmd_args
    stdout, stderr, status = Open3.capture3(cmd.join(' '))
    p_arg_nr = cmd.index('-P')
    cmd.fill('<secret>', p_arg_nr + 1, 1) unless p_arg_nr.nil? # password is not logged.
    new_pass_arg_nr = cmd.index('password')
    cmd.fill('<secret>', new_pass_arg_nr + 2, 1) unless new_pass_arg_nr.nil? # new password is not logged.
    Puppet.debug("#{cmd.join(' ')} executed with stdout: '#{stdout}' stderr: '#{stderr}' status: '#{status}'")
    if !status.success? && !suppress_error
      raise(Puppet::Error, "#{cmd.join(' ')} failed with #{stdout}")
    end
    stdout
  end

  def self.ipmi_current_password(ipmi_args, user_id, password)
    basic_cmd = ['/usr/bin/ipmitool']
    unless ipmi_args[:bmc_server_host].nil? ||
           ipmi_args[:bmc_username].nil? ||
           ipmi_args[:bmc_password].nil?
      basic_cmd.push('-U').push(ipmi_args[:bmc_username])
      basic_cmd.push('-P').push(ipmi_args[:bmc_password])
      basic_cmd.push('-H').push(ipmi_args[:bmc_server_host])
      basic_cmd.push('-I').push('lanplus')
    end
    cmd = basic_cmd + ['user test', user_id, '20', password]
    stdout, stderr, status = Open3.capture3(cmd.join(' '))
    Puppet.debug("#{cmd[0, -1]} <secret> executed with stdout: '#{stdout}' stderr: '#{stderr}' status: '#{status}'")
    if status.success?
      true
    elsif stdout.include?('wrong password size')
      cmd = basic_cmd + ['user test', user_id, '16', password]
      stdout, stderr, status = Open3.capture3(cmd.join(' '))
      Puppet.debug("#{cmd[0, -1]} <secret> executed with stdout: '#{stdout}' stderr: '#{stderr}' status: '#{status}'")
      if status.success?
        true
      else
        false
      end
    else
      false
    end
  end

  def self.parse_user_summay_csv(reply)
    keys = [:max_count, :enabled_count, :fixed_count]
    CSV.parse(reply).map { |a| Hash[keys.zip(a)] }[0]
  end

  def self.parse_lan(reply)
    parsed = {}
    key = ''
    reply.each_line do |line|
      line_array = line.split(':')
      if line_array[0].strip.empty?
        original_value = parsed[key]
        if line_array.count == 3 && !original_value.is_a?(Hash)
          subline_array = original_value.split(':')
          subkey = subline_array.slice!(0).strip
          subvalue = subline_array.join(':').strip
          parsed.delete(key)
          parsed[key] = Hash[subkey, subvalue]
        elsif line_array.count == 3
          subkey = line_array.slice!(1).strip
          subvalue = line_array.join(':').strip
          parsed[key][subkey] = subvalue
        end
      else
        key = line_array.slice!(0).strip
        value = line_array.join(':').strip
        if key == 'IP Address Source'
          case value
          when %r{static}i
            value = 'static'
          when %r{dhcp}i
            value = 'dhcp'
          when %r{none}i
            value = 'none'
          when %r{bios}i
            value = 'bios'
          end
        end
        parsed[key] = value
      end
    end
    parsed
  end

  def self.parse_user_csv(reply)
    keys = [:id, :name, :callin, :link, :ipmi, :privilege]
    result = []
    CSV.parse(reply) do |row|
      n_row = Bmc.values_to_boolean(row, [2, 3, 4])
      result.push(n_row)
    end
    result.map { |a| Hash[keys.zip(a)] }
  end

  @channel_getaccess_keys = {
    'Maximum User IDs' => :max_id_count,
    'Enabled User IDs' => :enabled_id_count,
    'User ID' => :user_id,
    'User Name' => :user_name,
    'Fixed Name' => :fixed_name,
    'Access Available' => :access_avaliable,
    'Link Authentication' => :link,
    'IPMI Messaging' => :ipmi,
    'Privilege Level' => :privilege,
    'Enable Status' => :enable,
  }

  def self.parse_channel_getaccess(reply)
    parsed = {}
    reply.each_line do |line|
      line_array = line.split(':').map(&:strip)
      parsed[@channel_getaccess_keys[line_array[0]] || line_array[0]] = line_array[1] unless line_array[0].empty?
    end
    parsed
  end

  def self.s_to_role(value)
    case value
    when '1'
      'callback'
    when '2'
      'user'
    when '3'
      'operator'
    when '4'
      'administrator'
    when '5'
      'oem_proprietary'
    when '15'
      'no_access'
    end
  end

  def self.role_to_s(value)
    case value
    when 'none'
      '0'
    when 'callback'
      '1'
    when 'user'
      '2'
    when 'operator'
      '3'
    when 'administrator'
      '4'
    when 'oem_proprietary'
      '5'
    when 'no_access'
      '15'
    end
  end
end
