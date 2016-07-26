# this is a simple defined type to write metadata from hiera as local facts
define base::metafact (
  $path,
  $fact = $title
) {
  $value = hiera("metadata:${fact}")

  file { $title:
    name    => "${path}/${fact}.txt",
    content => "${fact}=${value}\n"
  }
}
