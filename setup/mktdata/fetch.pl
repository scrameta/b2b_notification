#!/usr/bin perl -w
use strict;

# cat esg | cut -d'   ' -f 3 > esg.names

while (<>)
{
	chomp;
	my $name = $_;
	print "Fetching $name\n";
	`wget  "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol=${name}&apikey=***REMOVED***&datatype=csv&outputsize=compact" -O ${name}_20201203.csv`;
	sleep 10;
}
