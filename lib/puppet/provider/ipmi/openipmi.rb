Puppet::Type.type(:ipmi).provide(:openipmi) do
  confine :operationsystem => [:redhat,:debian]

  desc ""
end
