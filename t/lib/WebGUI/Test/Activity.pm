package WebGUI::Test::Activity;

use WebGUI::Workflow;

=head Name

package WebGUI::Test::Activity;

=head Description

 This package encapsulates the code required to run
 an activity.

=head Usage

use WebGUI::Test::Activity;

my $instance = WebGUI::Test::Activity->create( $session, 'WebGUI::Workflow::Activity::RemoveOldCarts', {
		cartTimeout => 3600,
} );

is( $instance->run, 'complete', 'activity complete' );
is( $instance->run, 'done', 'activity done' );
$instance->rerun;
is( $instance->run, 'complete', 'activity complete' );
is( $instance->run, 'done', 'activity done' );
$instance->delete;

=head create

=params

session -- the session variable

class -- the class for the activity to run

params -- params to set in the workflow

=cut

sub create {
    my $myClass = shift;
    my $session = shift;
    my $workflowClass = shift;
    my $activityParams;
    if( exists $_[0] and ref $_[0] eq 'HASH' ) {
        $activityParams = shift ;
    } else {
        $activityParams = { @_ };
    }
	my $workflow  = WebGUI::Workflow->create($session,
	    {
		enabled    => 1,
		objectType => 'None',
		mode       => 'realtime',
	    },
	);
	my $activity = $workflow->addActivity($workflowClass);
    if( scalar( keys %$activityParams ) > 0 ) {
	$activity->set(%$activityParams);
}

	my $instance = WebGUI::Workflow::Instance->create($session,
	    {
		workflowId              => $workflow->getId,
		skipSpectreNotification => 1,
	    }
	);

	my $tag = WebGUI::VersionTag->getWorking($session);
	$tag->commit;
	WebGUI::Test->tagsToRollback($tag);

    return bless { instance => $instance,
		   session => $session,
                   workflow => $workflow }, __PACKAGE__;
}

sub run {
    return $_[0]{instance}->run;
}

sub rerun {
    my $self = shift;
my $session = $self->{session};
    $self->{instance}->delete;
    $self->{instance} = WebGUI::Workflow::Instance->create($session,
	{
	    workflowId              => $self->{workflow}->getId,
	    skipSpectreNotification => 1,
	}
    );
	my $tag = WebGUI::VersionTag->getWorking($session, 1);
        if( $tag ) {
	    $tag->commit;
	    WebGUI::Test->tagsToRollback($tag);
        }

}

sub delete {
    my $self = shift;
    $self->{instance}->delete;
    $self->{workflow}->delete;
}

1;

