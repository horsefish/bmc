class Bmc
  def self.munge_boolean(value)
    return :true if [true, "true", :true].include? value
    return :false if [false, "false", :false].include? value
    fail("Expected boolean parameter, got '#{value}'")
  end

  def self.s_to_role value
    case value
      when '1'
        return 'callback'
      when '2'
        return 'user'
      when '3'
        return 'operator'
      when '4'
        return 'administrator'
      when '5'
        return 'oem_proprietary'
      when '15'
        return 'no_access'
    end
  end

  def self.role_to_s value
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
