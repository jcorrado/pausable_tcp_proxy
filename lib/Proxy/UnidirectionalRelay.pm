package Proxy::UnidirectionalRelay;

use warnings;
use strict;

use base qw(Class::Accessor);
use IO::Select;

# read size in bytes
my $READ_SZ = 1024;

__PACKAGE__->mk_ro_accessors(qw(selector sender receiver read_sz queue));

sub new {
    my ($class, $sender, $receiver, $queue) = @_;
    return bless {
	selector => IO::Select->new($sender),
	sender => $sender,
	receiver => $receiver,
	read_sz => $READ_SZ,
	queue => $queue
    } => $class;
}

sub run {
    my $self = shift;
    my ($buf, $b);
    my $bytes_read = 1;
    while ($bytes_read) {
	if ($self->selector()->can_read(0)) {
	    $bytes_read = $self->sender()->sysread($b, $self->read_sz());
	    $buf .= $b;
	}
	if ($buf and not $self->queue()->is_paused()) {
	    print { $self->receiver() } $buf;
	    undef $buf;
	}
    }
    return undef;
}

1;
