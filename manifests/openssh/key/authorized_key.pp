# Install a public key into a server user's authorized_keys(5) file.
define keymaster::openssh::key::authorized_key (
  $user,
  $ensure  = 'present',
  $options = undef,
) {

  include keymaster::params

  # on the keymaster:
  $clean_name = regsubst($name, '@', '_at_')
  $key_src_dir  = "${::keymaster::params::keystore_openssh}/${clean_name}"
  $key_src_file = "${key_src_dir}/key.pub"
  $key_src_content = file($key_src_file, '/dev/null')

#  if ! defined(User[$user]) {
#    fail("The user '${user}' has not been defined in Puppet")
#  }

  # If absent, remove from authorized_keys
  if $ensure == 'absent' {
    ssh_authorized_key { $name:
      ensure  => absent,
      user    => $user,
      require => User[$user],
    }

  # If no key content, do nothing,  wait for keymaster to realise key resource
  } elsif ! $key_src_content {
    warning("Public key file ${key_src_file} for key ${name} not found on keymaster")

  # Make sure key content parses
  } elsif $key_src_content !~ /^(ssh-...) (\S*)/ {
    warning("Can't parse public key file ${key_src_file} for key ${name} on keymaster")

  # All's good.  install the pubkey.
  } else {
    $keytype = $1
    $modulus = $2

    ssh_authorized_key { $name:
      ensure  => 'present',
      user    => $user,
      type    => $keytype,
      key     => $modulus,
      options => $options,
      require => User[$user],
    }
  }
}
