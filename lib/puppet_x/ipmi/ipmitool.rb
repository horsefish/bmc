require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'puppet_x', 'bmc.rb'))
require 'open3'

module Ipmi
  class Ipmitool

    def self.symbol_to_s value
      value == :true ? 'on' : 'off'
    end

    def self.s_to_bool value
      value.eql?'on'
    end


    def self.ipmi_call ipmi_args, cmd_args, suppress_error = false
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
      cmd.fill('<secret>', p_arg_nr+1, 1) unless p_arg_nr.nil? # password is not logged.
      new_pass_arg_nr = cmd.index('password')
      cmd.fill('<secret>', new_pass_arg_nr+2, 1) unless new_pass_arg_nr.nil? # new password is not logged.
      Puppet.debug("#{cmd.join(' ')} executed with stdout: '#{stdout}' stderr: '#{stderr}' status: '#{status}'")
      if !status.success? && !suppress_error
        raise(Puppet::Error, "#{cmd.join(' ')} failed with #{stdout}")
      end
      stdout
    end

    def self.ipmi_current_password ipmi_args, user_id, password
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

    def self.parseSummay reply
      parsed = Hash.new
      reply.each_line() do |line|
        lineArray = line.split(':')
        key = lineArray.slice!(0).strip
        value = lineArray.join(":").strip
        parsed[key] = value
      end
      parsed
    end

    def self.parseLan reply
      parsed = Hash.new
      key = ''
      reply.each_line() do |line|
        lineArray = line.split(':')
        if lineArray[0].strip.empty?
          originalValue = parsed[key]
          if (lineArray.count() == 3 && !originalValue.is_a?(Hash))
            subLineArray = originalValue.split(':')
            subkey = subLineArray.slice!(0).strip
            subvalue = subLineArray.join(":").strip
            parsed.delete(key)
            parsed[key] = Hash[subkey, subvalue]
          elsif (lineArray.count() == 3)
            subkey = lineArray.slice!(1).strip
            subvalue = lineArray.join(":").strip
            parsed[key][subkey] = subvalue
          end
        else
          key = lineArray.slice!(0).strip
          value = lineArray.join(":").strip
          if key == "IP Address Source"
            case value
              when /static/i
                value = 'static'
              when /dhcp/i
                value = 'dhcp'
              when /none/i
                value = 'none'
              when /bios/i
                value = 'bios'
            end
          end
          parsed[key] = value
        end
      end
      parsed
    end

    #can not handle if user has name true or false
    def self.parseUser reply
      users = Array.new
      reply.each_line do |line|
        if (line.start_with?('ID'))
          next
        end
        line.match(
            /(?'id'\d*)\s*(?'name'.*?)\s*(?'callin'true|false)\s*(?'link_auth'true|false)\s*(?'ipmi_msg'true|false)\s*(?'channel_priv_limit'.*)/i) do |match|
          users.push(
              {
                  'id' => match['id'],
                  'name' => match['name'],
                  'callin' => Bmc.munge_boolean(match['callin']),
                  'link_auth' => Bmc.munge_boolean(match['link_auth']),
                  'ipmi_msg' => Bmc.munge_boolean(match['ipmi_msg']),
                  'channel_priv_limit' => match['channel_priv_limit']
              }
          )
        end
      end
      users
    end
  end
end
