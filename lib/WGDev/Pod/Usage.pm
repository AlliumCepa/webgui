package WGDev::Pod::Usage;
# ABSTRACT: Produce usage documentation for WGDev commands
use strict;
use warnings;
use 5.008008;

use constant OPTION_INDENT      => 4;
use constant OPTION_TEXT_INDENT => 24;

use parent qw(Pod::PlainText Pod::Select);

use WGDev::X ();

sub new {
    my $proto = shift;

    my $self = $proto->SUPER::new( indent => 0 );
    $self->verbosity(1);
    return $self;
}

sub verbosity {
    my $self      = shift;
    my $verbosity = shift;
    if ($verbosity) {
        $self->select(qw(NAME SYNOPSIS OPTIONS/!.+));
    }
    else {
        $self->select(qw(NAME SYNOPSIS));
    }
    return;
}

sub command {
    my $self    = shift;
    my $command = shift;
    $self->{_last_command} = $command;
    return $self->SUPER::command( $command, @_ );
}

sub cmd_head1 {
    my $self = shift;
    my $head = shift;
    my $para = shift;
    $head =~ s/\s+$//msx;
    $self->{_last_head1} = $head;
    if ( $head eq 'NAME' ) {
        return;
    }
    elsif ( $head eq 'SYNOPSIS' ) {
        $head = 'USAGE';
    }
    $head = lc $head;
    $head =~ s/\b(.)/uc($1)/msxe;
    $head .= q{:};
    my $output = $self->interpolate( $head, $para );
    $self->output( $output . "\n" );
    return;
}

sub textblock {
    my $self = shift;
    my $text = shift;
    my $para = shift;
    if ( $self->{_last_head1} eq 'NAME' ) {
        $text =~ s/^[\w:]+\Q - //msx;
    }
    if ( $self->{_last_command} eq 'item' && !$self->{ITEM} ) {
        return;
    }
    return $self->SUPER::textblock( $text, $para );
}

sub verbatim {
    my $self = shift;
    if ( $self->{_last_command} eq 'item' && !$self->{ITEM} ) {
        return;
    }
    return $self->SUPER::verbatim(@_);
}

sub item {
    my $self   = shift;
    my $item   = shift;
    my $tag    = delete $self->{ITEM};
    my $margin = $self->{MARGIN};
    local $self->{MARGIN} = 0;    ## no critic (ProhibitLocalVars)

    $tag = $self->reformat($tag);
    $tag =~ s/\n*\z//msx;

    $item =~ s/[.].*//msx;
    {
        ## no critic (ProhibitLocalVars)
        local $self->{width} = $self->{width} - OPTION_TEXT_INDENT;
        $item = $self->reformat($item);
    }
    $item =~ s/\n*\z//msx;
    my $option_indent_string = q{ } x OPTION_TEXT_INDENT;
    $item =~ s/\n/\n$option_indent_string/msxg;

    my $indent_string = q{ } x OPTION_INDENT;
    if ( $item eq q{} ) {
        $self->output( $indent_string . $tag . "\n" );
    }
    else {
        my $option_name_length = OPTION_TEXT_INDENT - OPTION_INDENT - 1;
        $self->output( $indent_string . sprintf "%-*s %s\n",
            $option_name_length, $tag, $item );
    }
    return;
}

sub seq_c {
    return $_[1];
}

sub parse_from_string {
    my $self   = shift;
    my $pod    = shift;
    my $output = q{};
    open my $out_fh, '>', \$output
        or WGDev::X::IO->throw;
    open my $in_fh, '<', \$pod
        or WGDev::X::IO->throw;
    $self->parse_from_filehandle( $in_fh, $out_fh );
    close $in_fh
        or WGDev::X::IO->throw;
    close $out_fh
        or WGDev::X::IO->throw;
    return $output;
}

# this/these are methods that Pod::PlainText used to implement, but no long does

sub cmd_method { my $self = shift; $self->item(@_); }    # 'cmd_' . $pod_node_name is a computed method name; handle =method entires the same way as =item entries

# done

1;

=head1 SYNOPSIS

    use WGDev::Pod::Usage;
    my $parser = WGDev::Pod::Usage->new;
    my $usage = $parser->parse_from_string($pod);

=head1 DESCRIPTION

Formats POD documentation into a format suitable for showing as
usage text.  WGDev::Pod::Usage is a subclass of L<Pod::Select>.

=for Pod::Coverage
    cmd_head1
    new
    parse_from_string
    seq_c
    textblock
    verbosity

=cut

