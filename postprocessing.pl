#!/usr/bin/env perl
use strict;
use MIME::Base64;
use CGI qw/:standard/;
use YAML;

# Open a file and return the full contents.
sub read_file {
    my $filename = shift;

    open(TH01, $filename) or die "Could not open file $filename for reading.";
    return encode_base64(join("", <TH01>));
}

# Create a wafermaps hash for the given lot.
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
    # Translate the hash to yaml format.
    print header('application/yaml'), Dump(wafermaps($lotname));
} else {
    print header('text/html'), "<h1>Parameter lotname is required</h1>";
}

