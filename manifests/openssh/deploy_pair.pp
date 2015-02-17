# This resource deploys an instances of a key pair
define keymaster::openssh::deploy_pair (
  $user,
  $ensure   = undef,
  $filename = undef
) {

  if $ensure {
    validate_re($ensure,['^present$','^absent$'])
  }

#  if ! defined(User[$user]) {
#    fail("The user '${user}' has not been defined in Puppet")
#  }

  $clean_name = regsubst($name, '@', '_at_')

  # This is ugly, but we need to accomodate every permutation of the 
  # three params.  Otherwise override behavior is unpredictible.
  if ( $user and $ensure and $filename ) {
    Keymaster::Openssh::Key::Deploy <<| tag == $clean_name |>> {
      user      => $user,
      ensure    => $ensure,
      filename  => $filename,
      require   => User[$user],
    }

  } elsif ( $user and $ensure ) {
    Keymaster::Openssh::Key::Deploy <<| tag == $clean_name |>> {
      user   => $user,
      ensure => $ensure,
      require   => User[$user],
    }

  } elsif ( $ensure and $filename ) {
    Keymaster::Openssh::Key::Deploy <<| tag == $clean_name |>> {
      ensure   => $ensure,
      filename => $filename,
    }

  } elsif ( $user and $filename ) {
    Keymaster::Openssh::Key::Deploy <<| tag == $clean_name |>> {
      user     => $user,
      filename => $filename,
      require   => User[$user],
    }

  } elsif ( $user ) {
    Keymaster::Openssh::Key::Deploy <<| tag == $clean_name |>> {
      user => $user,
      require   => User[$user],
    }

  } else {
    # Should never get here
    fail('The user parameter is required')
  }

}
