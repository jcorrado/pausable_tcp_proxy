package Proxy::QueueController;

use warnings;
use strict;

use base qw(Class::Accessor);
use IPC::SysV qw(S_IRUSR S_IWUSR IPC_CREAT);
use IPC::Semaphore;

__PACKAGE__->mk_ro_accessors(qw(sem));

sub new {
    my ($class, $sem_key) = @_;
    return bless { 
	sem => IPC::Semaphore->new($sem_key, 1, S_IRUSR | S_IWUSR | IPC_CREAT) 
    } => $class;
}

sub is_paused { return shift()->sem()->getval(0) ? 1 : 0 }

sub pause { return shift()->sem()->setall(qw(1)) }

sub unpause { return shift()->sem()->setall(qw(0)) }

1;
