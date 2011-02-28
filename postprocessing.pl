#!/usr/bin/env perl
use strict;
use CGI qw/:standard/;
use YAML;

sub read_file {
    my $filename = shift;

    open(TH01, $filename) or die "Could not open file $filename for reading.";
    return <TH01>;
}

sub wafermaps {
    my $lotname = shift;

    return {
        lotname => $lotname,
        converted_at => "20110228 14:01",
        wafermaps => {
          1 => read_file("example.th01"),
          2 => read_file("example.th01"),
        }};
}

if (defined (my $lotname = param('lotname'))) {
    print header('application/yaml'), Dump(wafermaps($lotname));
} else {
    print header('text/html'), "<h1>Parameter lotname is required</h1>";
}

