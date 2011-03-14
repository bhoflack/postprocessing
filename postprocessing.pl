#!/usr/bin/env perl

use strict;
use MIME::Base64;
use Net::Stomp;
use XML::Simple;
use Data::Dumper;

# Open a file and return the full contents.
sub read_file {
    my $filename = shift;

    open(TH01, $filename) or die "Could not open file $filename for reading.";
    return encode_base64(join("", <TH01>));
}

# Create a wafermaps hash for the given lot.
sub wafermaps {
    my $lot = shift;
    my $lotname = $lot->{lot}->{name};

    for my $wafer(@{$lot->{lot}->{wafer}}) {
        # Create a wafermap hash for the postprocessing map
        my $wafermap = { 'name' => 'postprocessing',
                         'formats' => {
                             'format' => [
                                 {
                                     'name' => 'th01',
                                     'content' => read_file("example.th01")
                                 }]
                         }
        };

        # Add the wafermap to the list of wafermaps
        push @{$wafer->{wafermap}}, $wafermap;
    }


    return $lot;
}

my $stomp = Net::Stomp->new({ hostname => "localhost",
                              port => "61613" });
$stomp->connect or die "could not connect";

# subscribe to the incoming command queue
$stomp->subscribe({ "destination" => "/queue/postprocessing",
                    "ack" => "client",
                    "activemq.prefetchSize" => 1 });

while (1) {
    my $frame = $stomp->receive_frame;

    # Read the xml in a hash ref
    # KeepRoot keeps the lot root as it is,
    # by specifying an empty KeyAttr we ensure that the structure
    # isn't changed.
    # ForceArray is set to true so that the format key stays available.
    my $lot = XMLin($frame->body, KeepRoot => 1, KeyAttr => undef, ForceArray => ["format"]);

    my $processed = wafermaps($lot);

    # convert back to xml,  RootName is set to undef so that
    # XML::Simple doesn't add the opt tags
    my $body = XMLout($processed, RootName => undef, GroupTags => undef);

    # Send the result back
    $stomp->send({ destination => "/queue/postprocessing_results",
                   body => $body });

    # Acknowledge the message
    $stomp->ack( { frame => $frame } );
}

$stomp->disconnect;
