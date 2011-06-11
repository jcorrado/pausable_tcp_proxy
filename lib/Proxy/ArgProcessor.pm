package Proxy::ArgProcessor;

use warnings;
use strict;

use base qw(Class::Accessor);
use Getopt::Std;

__PACKAGE__->mk_ro_accessors(qw(help lcl_port pause unpause rmt_host rmt_port));

sub new {
    my $class = shift;
    our ($opt_h, $opt_l, $opt_r, $opt_p, $opt_u);
    getopts('hl:r:pu');
    return bless {
	help => $opt_h,
	lcl_port => $opt_l,
	pause => $opt_p,
	unpause => $opt_u,
	rmt_host => defined $opt_r ? $opt_r =~ /([.\da-z]+):/i : undef,
	rmt_port => defined $opt_r ? $opt_r =~ /(\d+)/ : undef
    } => $class;
}

sub verify {
    my $self = shift;
    if ($self->help() or
	 not (($self->pause() or $self->unpause()) or 
	      ($self->lcl_port() && $self->rmt_host() && $self->rmt_port()))
	) {
	$self->_usage();
	return undef;
    } else {
	return 1;
    }
}

sub _usage {
    print <<HELP;
proxy TCP connection to a remote host, optionally pausing and
un-pausing the flow of traffic

-h print this help
-l local port to listen on
-r remote server:port to connnect to
-p pause traffic and begin queuing
-u un-pause traffic, de-queueing accrued data

HELP
}

1;
