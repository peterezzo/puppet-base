# this class does some horrible logic to write metadata facts
# facts = array of facts to lookup from hiera and write
# facterpath = directory (optionally array with last element true path) to store facts in
class base::metadata (
  $facts      = false,
  $facterpath = ['/etc/facter', '/etc/facter/facts.d']
) {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $facts {
    file { $facterpath:
      ensure  => 'directory',
    }

    metafact { $facts:
      require => File[$facterpath],
      path    => $facterpath[-1],
    }
  }
}
