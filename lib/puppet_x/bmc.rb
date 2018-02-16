# General Utilily class
class Bmc
  def self.munge_array_boolean(input_array, munchable_elements = [])
    input_array.each_with_index.map do |value,index|
      if munchable_elements.include?(index)
        munge_boolean(value)
      else
        value
      end
    end
  end

  def self.munge_boolean(value)
    return :true if [true, 'true', :true].include? value
    return :false if [false, 'false', :false].include? value
    raise Puppet::Error("Expected boolean parameter, got '#{value}'")
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
