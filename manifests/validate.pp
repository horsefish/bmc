class bmc::validate inherits bmc{

  validate_re($ensure, ['^present$', '^absent$', '^purged$', '^latest$'])

  validate_bool($manage_repo)
}
