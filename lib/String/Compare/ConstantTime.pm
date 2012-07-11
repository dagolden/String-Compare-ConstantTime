package String::Compare::ConstantTime;

use strict;

our $VERSION = '0.20';

require XSLoader;
XSLoader::load('String::Compare::ConstantTime', $VERSION);

require Exporter;
use base 'Exporter';
our @EXPORT_OK = qw(equals);

## equals is defined in ConstantTime.xs

1;

__END__



=encoding utf-8

=head1 NAME
 
String::Compare::ConstantTime - Timing side-channel protected string compare
 

=head1 SYNOPSIS

    use Digest::HMAC_SHA1; ## or whatever

    my $hmac_ctx = Digest::HMAC_SHA1->new($key);
    $hmac_ctx->add($data);
    my $digest = $hmac->digest;

    use String::Compare::ConstantTime qw/equals/;

    if (equals($digest, $candidate_digest)) {
      ## The candidate digest is valid
    }



=head1 DESCRIPTION

This modules provides one function, C<equals> (not exported by default).

You should pass this function two strings of the same length. It will return true if they are string-wise equal (like C<eq>) and false otherwise. Unlike C<eq>, neither string's contents will affect the time it takes for this function to return.

B<NOTE>: If the lengths of the strings are different, C<equals> will return false right away.



=head1 TIMING SIDE-CHANNEL

Some programs take different amounts of time to run depending on the input values provided to them. When untrusted parties control input, they might be able to learn information you might otherwise not want them to know. This is called a "timing side-channel".

Most routines that compare strings (like perl's C<eq> and C<cmp> and C's C<strcmp> and C<memcmp>) start scanning from the start and terminate as soon as they determine the strings won't match. This is good for efficiency but bad because it opens a timing side-channel. If one of the strings being compared is a secret and the other is provided by some untrusted party, it is sometimes possible for this untrusted party to learn the secret using a timing side-channel.



=head1 HMAC

HMACs are "Message Authentication Codes" built on top of cryptographic hashes. The HMAC algorithm produces digests that are included along with a message in order to verify that whoever created the message knows a particular secret password, and that this message hasn't been tampered with since.

To verify a candidate digest included with a message, you re-compute the digest using the message and the secret password. If this computed digest is is the same as the candidate digest then the message is considered authenticated.

A very common side-channel attack against services that verify unlimited numbers of messages automatically is to create a forged message and then just send some random junk as the candidate digest. Continue sending this message and the junk digest, varying the first character in the digest. Repeat many times. If you find a particular digest that statistically takes a longer time to be rejected than the other digests, it is probably because this particular digest has the first character correct and the service's final string comparison is running a little longer.

At this point, you keep this first character fixed and start varying the second character. Repeat until all the characters are solved or until the amount of remaining possibilities are so small you can brute force it. At this point, your candidate digest is considered valid and you have forged a message.

Note that this particular attack doesn't allow the attacker to recover the secret input key, but the attacker can still use the service itself to produce a valid digest for any message.



=head1 LOCK-PICKING ANALOGY

Pin tumbler locks are susceptible to being picked in a similar way to an attacker forging HMAC digests using a timing side-channel.

The most common way to pick cheap pin tumbler locks is to apply torque to the lock cylinder so that the pins are pressed against the cylinder. However, because of slight manufacturing discrepancies one particular pin will be the widest by a slight margin and will actually be the only pin pressed against the cylinder (the cheaper the lock, the higher the manufacturing "tolerances"). The attacker lifts this pin until the cylinder gives a little bit, indicating that this pin has been solved and the next widest pin is now the one being pressed against the cylinder. This process is repeated until all the pins are solved and the lock opens.

Just like an attacker trying to solve HMAC digests can work on one character at a time, a lock pick can work on each pin in isolation. To protect against this, quality locks force all pins to be made fixed into place before the cylinder rotation can begin just as secure HMAC verifiers force attackers to guess the entire digest on each attempt.




=head1 SEE ALSO

L<The String-Compare-ConstantTime github repo|https://github.com/hoytech/String-Compare-ConstantTime>

L<Authen::Passphrase> has a good section on side-channel cryptanalysis such as it pertains to password storage.

L<The famous TENEX password bug|http://www.meadhbh.org/services/passwords>

L<Example of a timing bug|http://rdist.root.org/2009/05/28/timing-attack-in-google-keyczar-library/>

L<QSCAN|http://hcsw.org/nmap/QSCAN>

L<Practical limits of the timing side channel|http://www.cs.rice.edu/~dwallach/pub/crosby-timing2009.pdf>

L<NaCl: Crypto library designed to prevent side channel attacks|http://nacl.cr.yp.to/>



=head1 AUTHOR

Doug Hoyte, C<< <doug@hcsw.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2012 Doug Hoyte.

This module is licensed under the same terms as perl itself.

=cut





__END__

TODO:

* Finish stats.t
