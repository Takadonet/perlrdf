use FindBin '$Bin';
use lib "$Bin/lib";


use RDF::Trine qw(iri literal statement);
use Test::RDF::Trine::Store qw(all_store_tests number_of_tests);

use strict;
use Test::More;


unless (
		exists $ENV{RDFTRINE_STORE_MYSQL_DATABASE} and
		exists $ENV{RDFTRINE_STORE_MYSQL_HOST} and
		exists $ENV{RDFTRINE_STORE_MYSQL_USER} and
		exists $ENV{RDFTRINE_STORE_MYSQL_PASSWORD} and
		exists $ENV{RDFTRINE_STORE_MYSQL_MODEL}) {
	plan skip_all => "Set the MySQL environment variables to run these tests (RDFTRINE_STORE_MYSQL_DATABASE, RDFTRINE_STORE_MYSQL_HOST, RDFTRINE_STORE_MYSQL_PORT, RDFTRINE_STORE_MYSQL_USER, RDFTRINE_STORE_MYSQL_PASSWORD, RDFTRINE_STORE_MYSQL_MODEL)";
}

my $db		= $ENV{RDFTRINE_STORE_MYSQL_DATABASE};
my $host	= $ENV{RDFTRINE_STORE_MYSQL_HOST};
my $port	= $ENV{RDFTRINE_STORE_MYSQL_PORT};
my $user	= $ENV{RDFTRINE_STORE_MYSQL_USER};
my $pass	= $ENV{RDFTRINE_STORE_MYSQL_PASSWORD};
my $model	= $ENV{RDFTRINE_STORE_MYSQL_MODEL};

plan tests => 4 + Test::RDF::Trine::Store::number_of_tests;

use strict;
use warnings;
no warnings 'redefine';

use RDF::Trine qw(iri variable store literal);
use RDF::Trine::Store;

my $dsn	= "DBI:mysql:database=$db;host=$host";
$dsn	.= ";port=$port" if (defined($port));

persist_test($dsn, $user, $pass, $model);

my $data = Test::RDF::Trine::Store::create_data;

my $dbh	= DBI->connect( $dsn, $user, $pass );
my $store	= RDF::Trine::Store::DBI::mysql->new( $model, $dbh );
isa_ok( $store, 'RDF::Trine::Store::DBI::mysql' );

Test::RDF::Trine::Store::all_store_tests($store, $data);


sub new_store {
	my $dsn		= shift;
	my $user	= shift;
	my $pass	= shift;
	my $model	= shift;
	my $dbh	= DBI->connect( $dsn, $user, $pass );
	my $store	= RDF::Trine::Store::DBI::mysql->new( $model, $dbh );
	return $store;
}

sub persist_test {
	note " persistence tests";
	my $dsn		= shift;
	my $user	= shift;
	my $pass	= shift;
	my $model	= shift;
	my $st		= statement(
					iri('http://example.org/'),
					iri('http://purl.org/dc/elements/1.1/title'),
					literal('test')
				);
	{
		my $store	= new_store( $dsn, $user, $pass, $model );
		$store->add_statement( $st );
		is( $store->count_statements, 1, 'insert statement' );
	}
	{
		my $store	= new_store( $dsn, $user, $pass, $model );
		is( $store->count_statements, 1, 'statement persists across dbh connections' );
		$store->remove_statement( $st );
		is( $store->count_statements, 0, 'cleaned up persistent statement' );
	}
}
