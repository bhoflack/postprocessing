#!/usr/bin/env perl
#use strict;
use MIME::Base64;
use Net::Stomp;
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

my $stomp = Net::Stomp->new({ hostname => "localhost",
                              port => "61613" });
$stomp->connect or die "could not connect";

# subscribe to the incoming command queue
$stomp->subscribe({ "destination" => "/queue/postprocessing",
                    "ack" => "client",
                    "activemq.prefetchSize" => 1 });

while (1) {
    my $frame = $stomp->receive_frame;

    my %contents = Load($frame->body());
    my $lotname = $contents{"lotname"};

    # Send the result back
    $stomp->send({ destination => "/queue/postprocessing_results",
                   body => Dump(wafermaps($lotname)) });

    # Acknowledge the message
    $stomp->ack( { frame => $frame } );
}

$stomp->disconnect;
