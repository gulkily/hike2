#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use DBD::SQLite;
use DBI;
use Data::Dumper;
use 5.010;

my $SqliteDbName = "index.sqlite3";

my $dbh;

my $i = 0;
while (-e "test$i.db") {
	$i++;
}
my $SqliteDbName2 = "test$i.db";

sub SqliteConnect {
	$dbh = DBI->connect(
		"dbi:SQLite:dbname=index.sqlite3",
		#"dbi:SQLite:dbname=test$i.db",
		"",
		"",
		{ RaiseError => 1 },
	) or print($DBI::errstr);
}

#schema
sub SqliteMakeTables() {
	SqliteQuery("CREATE TABLE added_time(file_hash, add_timestamp);");
	SqliteQuery("CREATE TABLE author(id INTEGER PRIMARY KEY AUTOINCREMENT, key UNIQUE)");
	SqliteQuery("CREATE TABLE author_alias(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		key UNIQUE,
		alias,
		is_admin,
		fingerprint
	)");
	SqliteQuery("CREATE TABLE vote_weight(key, vote_weight)");
	SqliteQuery("CREATE TABLE item(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		file_path UNIQUE,
		item_name,
		author_key,
		file_hash UNIQUE,
		item_type
	)");
	SqliteQuery("CREATE TABLE item_parent(item_hash, parent_hash)");
	SqliteQuery("CREATE TABLE tag(id INTEGER PRIMARY KEY AUTOINCREMENT, vote_value)");
	SqliteQuery("CREATE TABLE vote(id INTEGER PRIMARY KEY AUTOINCREMENT, file_hash, ballot_time, vote_value, signed_by)");
+#	SqliteQuery("CREATE TABLE author(key UNIQUE)");
#	SqliteQuery("CREATE TABLE author_alias(key UNIQUE, alias, is_admin)");
#	SqliteQuery("CREATE TABLE item(file_path UNIQUE, item_name, author_key, file_hash UNIQUE)");
#	SqliteQuery("CREATE TABLE vote(file_hash, vote_hash, vote_value)");

	SqliteQuery("CREATE UNIQUE INDEX vote_unique ON vote (file_hash, ballot_time, vote_value, signed_by);");
	SqliteQuery("CREATE UNIQUE INDEX added_time_unique ON added_time(file_hash);");
	SqliteQuery("CREATE UNIQUE INDEX tag_unique ON tag(vote_value);");
	SqliteQuery("CREATE UNIQUE INDEX item_parent_unique ON item_parent(item_hash, parent_hash)");


	SqliteQuery("
		CREATE VIEW child_count AS
		SELECT
			parent_hash AS parent_hash,
			COUNT(*) AS child_count
		FROM
			item_parent
		GROUP BY
			parent_hash
	");

	SqliteQuery("
		CREATE VIEW parent_count AS
		SELECT
			item_hash AS item_hash,
			COUNT(*) AS parent_count
		FROM
			item_parent
		GROUP BY
			item_hash
	");

	SqliteQuery("CREATE VIEW item_last_bump AS SELECT file_hash, MAX(add_timestamp) add_timestamp FROM added_time GROUP BY file_hash;");
	SqliteQuery("
		CREATE VIEW vote_weighed AS
			SELECT
				vote.file_hash,
				vote.ballot_time,
				vote.vote_value,
				vote.signed_by,
				sum(ifnull(vote_weight.vote_weight, 1)) vote_weight
			FROM
				vote
				LEFT JOIN vote_weight ON (vote.signed_by = vote_weight.key)
			GROUP BY
				vote.file_hash,
				vote.ballot_time,
				vote.vote_value,
				vote.signed_by
	");

	SqliteQuery("
		CREATE VIEW item_flat AS
			SELECT
				item.file_path AS file_path,
				item.item_name AS item_name,
				item.file_hash AS file_hash,
				item.author_key AS author_key,
				item.item_type AS item_type,
				IFNULL(child_count.child_count, 0) AS child_count,
				IFNULL(parent_count.parent_count, 0) AS parent_count,
				added_time.add_timestamp AS add_timestamp
			FROM
				item
				LEFT JOIN child_count ON ( item.file_hash = child_count.parent_hash)
				LEFT JOIN parent_count ON ( item.file_hash = parent_count.item_hash)
				LEFT JOIN added_time ON ( item.file_hash = added_time.file_hash);
	");
	SqliteQuery("
		CREATE VIEW item_vote_count AS
			SELECT
				file_hash,
				vote_value AS vote_value,
				COUNT(file_hash) AS vote_count
			FROM vote
			GROUP BY file_hash, vote_value
			ORDER BY vote_count DESC
	");

	SqliteQuery("
		CREATE VIEW 
			author_flat 
		AS 
		SELECT 
			author.key AS author_key, 
			SUM(vote_weight.vote_weight) AS vote_weight, 
			author_alias.alias AS author_alias
		FROM 
			author 
			LEFT JOIN vote_weight ON (author.key = vote_weight.key) 
			LEFT JOIN author_alias ON (author.key = author_alias.key)
			GROUP BY author.key, author_alias.alias
	");
}

sub SqliteQuery {
	my $query = shift;
	chomp $query;

	if ($query) {
		my $sth = $dbh->prepare($query);
		$sth->execute(@_);

		my $aref = $sth->fetchall_arrayref();

		$sth->finish();

		return $aref;
	}
}

SqliteConnect();

#SqliteMakeTables();

1;
