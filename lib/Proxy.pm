package Proxy;

use warnings;
use strict;
use lib qw(./lib);

use base qw(Class::Accessor);
use IO::Socket::INET;
use Proxy::UnidirectionalRelay;

__PACKAGE__->mk_ro_accessors(qw(queue lcl_port rmt_host rmt_port));

sub new {
    my ($class, $queue, $lcl_port, $rmt_host, $rmt_port) = @_;
    return bless {
	queue => $queue,
	lcl_port => $lcl_port,
	rmt_host => $rmt_host,
	rmt_port => $rmt_port
    } => $class;
}

sub run {
    my $self = shift;

    # setup local listener of our proxy
    my $listener = IO::Socket::INET->new(Listen    => 1,
					 Reuse     => 1,
					 LocalAddr => '0.0.0.0',
					 LocalPort => $self->lcl_port(),
					 Proto     => 'tcp')
	or die "can't bind 0.0.0.0:" . $self->lcl_port() . ": $!\n";

    while (my $client = $listener->accept()) {
	$client->autoflush(1);

	# connect to remote server
	my $server = IO::Socket::INET->new(PeerAddr  => $self->rmt_host(),
					   PeerPort  => $self->rmt_port(),
					   Proto     => 'tcp')
	    or die "can't connect to " . $self->rmt_host() . ':' . $self->rmt_port() . ": $!\n";
	$server->autoflush(1);

	# fork for each direction
	my $child_pid = fork();
	die "can't fork: $!" unless defined $child_pid;

	if ($child_pid) {
	    # use parent as client -> server
	    Proxy::UnidirectionalRelay->new($client,
					    $server,
					    $self->queue()
		)->run();
	    $server->shutdown(2);  # shutdown read and write
	    kill('TERM', $child_pid);
	} else {
	    # use child as server -> client
	    Proxy::UnidirectionalRelay->new($server,
					    $client,
					    $self->queue()
		)->run();
	    $client->shutdown(2);  # shutdown read and write
	}
    }
    return undef;
}

1;
