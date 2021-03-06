use FindBin '$Bin';
use lib "$Bin/lib";

use Test::RDF::Trine::Store qw(all_store_tests number_of_tests);

use Test::More tests => 4 + Test::RDF::Trine::Store::number_of_tests;

use strict;
use warnings;
no warnings 'redefine';

use RDF::Trine qw(iri variable store literal);
use RDF::Trine::Store;



my $data = Test::RDF::Trine::Store::create_data;
my $ex = $data->{ex};

{
	my $store	= RDF::Trine::Store::Memory->new();
	isa_ok( $store, 'RDF::Trine::Store::Memory' );
	$store->add_statement( RDF::Trine::Statement::Quad->new($ex->a, $ex->b, $ex->c, $ex->d) );
	$store->add_statement( RDF::Trine::Statement::Quad->new($ex->r, $ex->t, $ex->u, $ex->v) );
	is( $store->_statement_id($ex->a, $ex->t, $ex->c, $ex->d), -1, '_statement_id' );
	is( $store->_statement_id($ex->w, $ex->x, $ex->z, $ex->z), -1, '_statement_id' );
}

{
  my $store	= RDF::Trine::Store::Memory->temporary_store();
  isa_ok( $store, 'RDF::Trine::Store::Memory' );
  Test::RDF::Trine::Store::all_store_tests($store, $data);
}
