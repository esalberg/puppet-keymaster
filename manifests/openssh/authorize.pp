# Deploy a previousl defined key to a user's .ssh/authorized_key file
define keymaster::openssh::authorize (
  $user,
  $ensure  = undef,
  $options = undef,
) {

  if $ensure {
    validate_re($ensure,['^present$','^absent$'])
  }

#  if ! defined(User[$user]) {
#    fail("The user '${user}' has not been defined in Puppet")
#  }

  $clean_name = regsubst($name, '@', '_at_')
  # Override the defaults set in sshauth::key, as needed.

  # This is ugly, but we need to accomodate every permutation of the 
  # three params.  Otherwise override bahavior is unpredictible.
  #
  if ( $user and $ensure and $options ) {
    Keymaster::Openssh::Key::Authorized_key <<| tag == $clean_name |>> {
      user    => $user,
      ensure  => $ensure,
      options => $options,
      require => User[$user],
    }

  } elsif ( $user and $ensure ) {
    Keymaster::Openssh::Key::Authorized_key <<| tag == $clean_name |>> {
      ensure => $ensure,
      user   => $user,
      require => User[$user],
    }

  } elsif ( $user and $options ) {
    Keymaster::Openssh::Key::Authorized_key <<| tag == $clean_name |>> {
      user    => $user,
      options => $options,
      require => User[$user],
    }

  } elsif ( $options and $ensure ) {
    Keymaster::Openssh::Key::Authorized_key <<| tag == $clean_name |>> {
      ensure  => $ensure,
      options => $options,
    }

  } elsif $user {
    Keymaster::Openssh::Key::Authorized_key <<| tag == $clean_name |>> {
      user  => $user,
      require => User[$user],
    }

  } else {
    # Should never get here
    fail('The user parameter is required')
  }

}
