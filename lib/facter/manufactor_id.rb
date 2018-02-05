ipmitool_path = Facter::Core::Execution.which('ipmitool')
if ipmitool_path
  ipmitool_mc_info = Facter::Core::Execution.execute("#{ipmitool_path} mc info 2>&1")
  if ipmitool_mc_info.include? 'Manufacturer ID'
    Facter.add(:manufactor_id) do
      has_weight 100
      confine :is_virtual => false
      setcode do
        %r{Manufacturer ID\s*: ([\w\.]+)}.match(ipmitool_mc_info)[1]
      end
    end
  end
end