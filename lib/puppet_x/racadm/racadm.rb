require 'puppet/provider'
require 'open3'
require 'digest'

# Racadm specific Utilily class
class Racadm
  def self.racadm_call(racadm_args, cmd_args, suppress_error = false)
    cmd = ['/opt/dell/srvadmin/bin/idracadm7']
    unless racadm_args[:bmc_server_host].nil? ||
           racadm_args[:bmc_username].nil? ||
           racadm_args[:bmc_password].nil?

      cmd.push('-u').push(racadm_args[:bmc_username]) if racadm_args[:bmc_username]
      cmd.push('-p').push(racadm_args[:bmc_password]) if racadm_args[:bmc_password]
      cmd.push('-r').push(racadm_args[:bmc_server_host]) if racadm_args[:bmc_server_host]
    end

    cmd += cmd_args
    stdout, stderr, status = Open3.capture3(cmd.join(' '))
    nr = cmd.index('-p')
    cmd.fill('<secret>', nr + 1, 1) unless nr.nil? # password is not logged.
    Puppet.debug("#{cmd.join(' ')} executed with stdout: '#{stdout}' stderr: '#{stderr}' status: '#{status}'")
    if !status.success? && !suppress_error
      raise(Puppet::Error, "#{cmd.join(' ')} failed with #{stdout}")
    end
    stdout
  end

  def self.parse_racadm(reply)
    parsed = {}
    reply.each_line do |line|
      sub_line_array = line.split('=')
      if sub_line_array.length > 1
        if line.start_with? '[Key='
          parsed[:Key] = sub_line_array[1].strip[0..-2]
        elsif sub_line_array[0].end_with? '[Key'
          subkey = sub_line_array.slice!(0).strip.chomp(' [Key')
          subvalue = '[Key=' + sub_line_array.join('=').strip
          parsed[subkey] = subvalue
        elsif !sub_line_array[0].start_with? '!!'
          subkey = sub_line_array.slice!(0).strip.gsub(%r{\s+}, '')
          subvalue = sub_line_array.join('=').strip
          parsed[subkey] = subvalue
        end
      end
    end
    parsed
  end

  def self.password_changed?(new_password, sha256, salt)
    new_password_sha = Digest::SHA256.hexdigest(
      new_password + salt.gsub(%r{..}) { |pair| pair.hex.chr },
    ).upcase
    !new_password_sha.eql? sha256
  end

  def self.parse_jobqueue(reply)
    parsed = {}
    reply.each_line do |line|
      if line.start_with? 'Reboot JID'
        parsed['reboot_id'] = line.split(' ').last
      elsif line.start_with? 'Commit JID'
        parsed['commit_id'] = line.split(' ').last
      end
    end
    parsed
  end

  def self.bool_to_s(value)
    (value.to_s == 'true') ? 'Enabled' : 'Disabled'
  end

  def self.s_to_bool(value)
    'Enabled'.eql? value
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
