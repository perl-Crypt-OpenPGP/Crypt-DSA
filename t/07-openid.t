#!/usr/bin/perl

use strict;
BEGIN {
	$|  = 1;
	$^W = 1;
}
use Test::More;
BEGIN {
	eval { require Convert::PEM };
	if ( $@ ) {
		Test::More->import( skip_all => 'no Convert::PEM' );
	}
	Test::More->import( tests => 11 );
}

use Crypt::DSA;
use Crypt::DSA::Key;
use Crypt::DSA::Signature;
use MIME::Base64 qw( decode_base64 );

my $dsa = Crypt::DSA->new;
ok($dsa, 'Created Crypt::DSA object');

my $key = Crypt::DSA::Key->new( Content => <<KEY, Type => 'PEM' );
-----BEGIN PUBLIC KEY-----
MIIBtjCCASsGByqGSM44BAEwggEeAoGBANuhjw/GIilXNuvnf9q3ygn1XSzzRtql
3BpsWSRVwXA05G/d9pEBIH35ADEQ6F035f88OfuZYRlUZt6Zx5q4ReA4KXWdAIaA
snDem9vNYJM+O2yK5sh6yYC6AnDn+zx0gUyr9npXun2nfQcrrXT4b2/Q1mAzawTX
q51pCAaDVICVAhUA611/IduNCUoRyE4a4DZ5jUUfGlUCgYBtFIHm3xwTszWVyWzr
YpE6I7PGkgO6bHTLyH4ngmFbhLt3zCj5Kzi9ifRb906CStAsCQAH6x5BKGybq6hD
8JqJk0kaQ8CpHaCjXcFLAjaNxH5pHftfYq3F8waUkeAwvtIQpEL4UKaLaMqbTm3N
FxWoTcEZ2khdlgGbyNXTmDxN3gOBhAACgYAT/V4S6EYk8Sz25Lq1THXo20b0HH8B
F8bvrfeWL26j6zL+Xzxw2T2s6Jo1vSbhflyZ6mou9tjSTN5xNBbKWCGm7jljLEE2
l9P4G6t5+IIgzf3TFrnApYPSb75HmSVChWiafDkfETB1Ubu2BBmGr9DWMicSvage
nsxOWTm7SqJt1Q==
-----END PUBLIC KEY-----
KEY
ok($key, 'Parsed key');
is($key->p, '154230195801502591027924305317288511172947704906732980042865725783273160667703109157997142143003577161221611277091751199342699401614518192723629436298411984396770358042848003616116218687384811676842914866452094185063282348433486774581474438998951431052798061340118427146346352987088223500940171802477059145877', 'key->p is correct');
is($key->q, '1343697875228530311433268893561874972460542007893', 'key->q is correct');
is($key->g, '76598656157914156355445502802171744250790923020496826978794359991033889852609480204530610320512647835268415654125612029198553017695138923633498269111081903879790210175626113174087754456086288166221445477869449670179905166479288765706711432697526089711402534333490590610585702443148717225877410516254148283870', 'key->g is correct');
is($key->pub_key, '14037256439480519253759632613632536532035918183115524804324868617973702093495192051592043879822732169784787073950081465739236860442657409768654772398273593073530490949064562392146096658305955159316750434379546653490951198708160960858856890405112535972154363576715166835110527233547140212180830244851727625685', 'key->pub_key is correct');

my $sig = Crypt::DSA::Signature->new( Content => decode_base64(<<SIG) );
MC0CFFhuYaDO5FWvAoq+1vfNXwo+vaegAhUAvOszrDsJmvNyacuyzEuch3Q9w2k=
SIG
ok($sig, 'Parsed raw ASN.1 signature');
$sig = Crypt::DSA::Signature->new( Content => <<SIG );
MC0CFFhuYaDO5FWvAoq+1vfNXwo+vaegAhUAvOszrDsJmvNyacuyzEuch3Q9w2k=
SIG
ok($sig, 'Parsed base64-encoded signature');
is($sig->r, '504852774416256883458134530817977383056083625888', 'sig->r is correct');
is($sig->s, '1078535441370160482370055129882190902543836365673', 'sig->s is correct');

my $msg = '2005-05-25T22:04:50Z::assert_identity::http://bradfitz.com/fake-identity/::http://www.danga.com/openid/demo/helper.bml';
ok($dsa->verify( Message => $msg, Key => $key, Signature => $sig ), 'Signature is verified');