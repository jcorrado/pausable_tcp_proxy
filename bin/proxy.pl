#!/usr/bin/perl

# toy tcp proxy server with pause feature

use warnings;
use strict;
use lib qw(./lib);

use Proxy::ArgProcessor;
use Proxy::QueueController;
use Proxy;

# our semaphore key, must be unique per user
my $SEM_KEY = 1234;

my $args = Proxy::ArgProcessor->new();
$args->verify() or exit();

my $queue = Proxy::QueueController->new($SEM_KEY);

# Are we in control or proxy mode?
if ($args->pause()) {
    $queue->pause();
} elsif ($args->unpause()) {
    $queue->unpause();
} else {
    Proxy->new($queue,
	       $args->lcl_port(),
	       $args->rmt_host(),
	       $args->rmt_port()
	)->run();
}
