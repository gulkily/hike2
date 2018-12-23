use strict;
use 5.026;

use Data::Dumper;

require './sqlite.pl';

my $dbh = DBI->connect(
	"dbi:SQLite:dbname=index.sqlite3",
	"",
	"",
	{ RaiseError => 1 },
) or die $DBI::errstr;


#SqliteConnect();

#SqliteMakeTables();

# my $query = "INSERT INTO item(item_name, file_hash) VALUES(?, ?)";

# my $sth = $dbh->prepare($query);
# $sth->execute('name', 5);
# $sth->finish();


#my $query = "SELECT file_hash, item_type FROM item ORDER BY file_hash";
my $query = "SELECT file_hash, item_type FROM item WHERE file_hash LIKE ? AND file_hash LIKE ?";

my $result = SqliteQuery($query, '%ab%', '%ba%');
#my $result = SqliteQuery($query);
#
#my $sth = $dbh->prepare($query);
##
#$sth->execute();
##
#my $aref = $sth->fetchall_arrayref();
#
#$sth->finish();

print Data::Dumper->Dump($result);

# foreach ()


# my @id=(1,2,3,4);
# my $question_mark_string = join(',', ('?') x scalar(@id) ); # ?,?,?,?
# my $sth = $dbh1->prepare("SELECT name FROM table where id in ( $questi
# +on_mark_string )") or die "Couldn't prepare statement: " . $dbh1->err
# +str;
# $sth->execute(@id)     



# my $sth = $dbh1->prepare('SELECT name FROM table WHERE id IN ( ?'.(',?' x $#id).' )') or ...






# $ cat 1031647.pl 
# use warnings;
# use strict;

# use Data::Dumper;

# use SQL::Abstract;
# my $sql = SQL::Abstract->new;

# my($stmt, @bind) = $sql->select(
#   'table',                          # table name
#   [ 'name' ],                       # fields
#   {
#     id => { -in => [ 1, 2, 3, 4 ] } # the ids
#   },
#   [ 'id' ]                          # order by
# );

# print Data::Dumper->Dump(
#   [ $stmt, \@bind ],   
#   [ qw( stmt bind ) ],
# );

# my $sth = $dbh->prepare( $stmt );
# $sth->execute( @bind );

# $ perl 1031647.pl
# $stmt = 'SELECT name FROM table WHERE ( id IN ( ?, ?, ?, ? ) ) ORDER BY id';
# $bind = [
#           1,
#           2,
#           3,
#           4
#         ];

# ...




# my $sth2 = $dbh->prepare($query);
# $sth2->execute();
# $sth->finish();

# my @row;
# while (@row = $sth2->fetchrow_array() ){
# 	# print "@row\n";
# 	my $key =  $row[0];

# 	while(@row) {
# 		pop @row;
# 		print $_;
# 	}
# }


sub DBGetVotesTable {
	my $fileHash = shift;

	my $query;

	$query = "SELECT file_hash, ballot_time, vote_value, signed_by, vote_weight FROM vote_weighed;";

	my $result = SqliteQuery($query);

	return $result;
}

# sub FormatSha1 {
# 	my $string = shift;

# 	if (!$string) {
# 		return 0;
# 	}

# 	if ($string =~ m/([a-fA-F0-9]{40})/) {
# 		return lc; #todo untested
# 	} else {
# 		return 0;
# 	}
# }

#my $votesTable = DBGetVotesTable();

#print Data::Dumper->Dump($votesTable);


