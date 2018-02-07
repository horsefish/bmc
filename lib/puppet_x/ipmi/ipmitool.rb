require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'puppet_x', 'bmc.rb'))
require 'open3'

class Ipmitool
  def self.symbol_to_s(value)
    (value == :true) ? 'on' : 'off'
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

  def self.parse_summay(reply)
    parsed = {}
    reply.each_line do |line|
      line_array = line.split(':')
      key = line_array.slice!(0).strip
      value = line_array.join(':').strip
      parsed[key] = value
    end
    parsed
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

  # can not handle if user has name true or false
  def self.parse_user(reply)
    users = []
    reply.each_line do |line|
      if line.start_with?('ID')
        next
      end
      line.match(
        %r{(?'id'\d*)\s*(?'na'.*?)\s*(?'ca'true|false)\s*(?'li'true|false)\s*(?'ip'true|false)\s*(?'ch'.*)}i
      ) do |match|
        users.push(
          'id' => match['id'],
          'name' => match['na'],
          'callin' => Bmc.munge_boolean(match['ca']),
          'link_auth' => Bmc.munge_boolean(match['li']),
          'ipmi_msg' => Bmc.munge_boolean(match['ip']),
          'channel_priv_limit' => match['ch'],
        )
      end
    end
    users
  end
end
