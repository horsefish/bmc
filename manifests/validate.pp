class bmc::validate inherits bmc{

  validate_re($bmc::ensure, ['^present$', '^absent$', '^purged$', '^latest$'])

  validate_bool($bmc::manage_repo)
}
