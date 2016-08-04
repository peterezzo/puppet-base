# this is a simple defined type to write metadata from hiera as local facts
define base::metafact (
  $fact = $title,
  $value = undef,
  $path = '/etc/facter/facts.d'
) {
  # metafact is intended to load an array of fact titles from hiera
  # by default the value pair is only in hiera, get it
  # but still make it possible to call this if truly necessary
  if $value {
    $file_value = $value
  } else {
    $file_value = hiera("metadata:${fact}")
  }

  file { $title:
    name    => "${path}/${fact}.txt",
    content => "${fact}=${file_value}\n"
  }
}
