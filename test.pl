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

my $test;

# my $query = "INSERT INTO item(item_name, file_hash) VALUES(?, ?)";

# my $sth = $dbh->prepare($query);
# $sth->execute('name', 5);
# $sth->finish();


my $query = "SELECT file_hash, item_type FROM item ORDER BY file_hash";
#my $query = "SELECT file_hash, item_type FROM item WHERE file_hash LIKE ?";

my $sth = $dbh->prepare($query);

$sth->execute();

my $aref = $sth->fetchall_arrayref();

print Data::Dumper->Dump($aref);

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
