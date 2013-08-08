package Devel::NYTProf::Complexity;
use strict;
use warnings;
use Devel::NYTProf::Data;

sub run {
    my ($self, $opts) = @_;

    my $raw_hash = Devel::NYTProf::Data->new({
        filename => $opts->{filename},
        quiet => !$opts->{verbose}
    });
    my @fileinfo_objs = @{$raw_hash->{fid_fileinfo}};
    my $slowest = { inclusive_time => 0, call_count => 0 };
    for my $fileinfo_obj (@fileinfo_objs) { # for every file info object...
        if (defined $fileinfo_obj) {        # that exists
            my $call_lines = $fileinfo_obj->sub_call_lines;
            my @lines = keys %{$call_lines};
            for my $line (@lines) {         # for every line in that file...
                my @subs = keys %{$call_lines->{$line}};
                for my $sub (@subs) {       # for every sub on that line...
                    my $call_count = $call_lines->{$line}{$sub}[0];
                    my $inclusive_time = $call_lines->{$line}{$sub}[1];
                    my $current = {
                        fileinfo => $fileinfo_obj,
                        line => $line,
                        sub => $sub,
                        call_count => $call_count,
                        inclusive_time => $inclusive_time
                    };
                    $slowest = $self->_judge_line($slowest, $current);  # find the slowest sub yet
                }
            }
        }
    }
    #my $prepared_data = '';
    my $prepared_data = $slowest;
    return $prepared_data;
}

sub _judge_line {
    my ($self, $champion, $challenger) = @_;

    my $call_count = $challenger->{call_count};
    my $inclusive_time = $challenger->{inclusive_time};

    if ((defined $call_count) && (defined $inclusive_time)) {
        if (($champion->{inclusive_time} * $champion->{call_count}) < ($inclusive_time * $call_count)) {
            return $challenger;
        }
        else {
            return $champion;
        }
    }
    # default
    return $champion;
}

sub display {
    my ($self, $prepared_data) = @_;
    use Data::Dumper;
    $Data::Dumper::Maxdepth = 2;
    print "The slowest subroutine on any line: ";
    warn Dumper $prepared_data;
}

1;
