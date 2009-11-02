package WebGUI::Workflow::Activity::ProcessEMSApprovals;


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2008 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use base 'WebGUI::Workflow::Activity';
use WebGUI::Asset;
use WebGUI::International;

=head1 NAME

Package WebGUI::Workflow::Activity::ProcessEMSApprovals

=head1 DESCRIPTION

Uses the settings in the help desk to determine whether the resolved tickets should be closed or not.

=head1 SYNOPSIS

See WebGUI::Workflow::Activity for details on how to use any activity.

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 definition ( session, definition )

See WebGUI::Workflow::Activity::defintion() for details.

=cut 

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
        my $i18n       = WebGUI::International->new( $session, "Asset_EMSSubmissionForm" );
	push(@{$definition}, {
		name       => $i18n->get("activity title approve submissions"),
		properties => {}
	});
	return $class->SUPER::definition($session,$definition);
}


#-------------------------------------------------------------------

=head2 execute (  )

See WebGUI::Workflow::Activity::execute() for details.

=cut

use lib '/root/pb/lib'; use dav;

sub execute {
	my $self    = shift;
    my $session = $self->session;
    my $root    = WebGUI::Asset->getRoot($session);
dav::log __PACKAGE__ . " executing\n";
    # keep track of how much time it's taking
    my $start   = time;
    my $limit   = 2_500;
    my $timeLimit = 120;

    my $list = $root->getLineage( ['descendants'], { returnObjects => 1,
                 includeOnlyClasses => ['WebGUI::Asset::EMSSubmissionForm'],
             } );
    
    for my $emsf ( @$list ) {
       my $whereClause = q{ submissionStatus='approved' };
       my $res = $emsf->getLineage(['children'],{  returnObjects => 1,
	     joinClass => 'WebGUI::Asset::EMSSubmission',
	     includeOnlyClasses => ['WebGUI::Asset::EMSSubmission'],
	     whereClause => $whereClause,
	 } );
        for my $submission ( @$res ) {
            my %properties = $submission->get;
            delete $properties{submissionId};
            delete $properties{submissionStatus};
            delete $properties{sendEmailOnChange};
            delete $properties{ticketId};
            my $newAsset = $emsf->ems->addChild(
                className => 'WebGUI::Asset::Sku::EMSTicket',
                %properties,
            );
            if( defined $newAsset ) {
		$submission->update({ ticketId => $newAsset->getId, submissionStatus => 'created' });
	    } else {
		$submission->update({ submissionStatus => 'failed' });
	    }
	    $limit--;
	    return $self->WAITING(1) if ! $limit or time > $start + $timeLimit;
	}
    }
    return $self->COMPLETE;
}

1;


