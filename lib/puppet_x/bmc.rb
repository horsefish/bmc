# General Utilily class
class Bmc
  def self.values_to_boolean(input_array, munchable_elements = [])
    input_array.each_with_index.map do |value, index|
      if munchable_elements.include?(index)
        s_to_boolean(value)
      else
        value
      end
    end
  end

  def self.s_to_boolean(value)
    return true if 'true'.casecmp(value).zero?
    return false if 'false'.casecmp(value).zero?
    raise "Expected string 'boolean' parameter, got '#{value}'"
  end

  def self.boolean_to_symbol(value)
    return :true if [true, 'true', :true].include? value
    return :false if [false, 'false', :false].include? value
    raise "Expected symbol 'boolean' parameter, got '#{value}'"
  end

  def self.symbol_to_boolean(value)
    return true if :true.eql? value
    return false if :false.eql? value
    raise "Expected symbol parameter, got '#{value}'"
  end
end
