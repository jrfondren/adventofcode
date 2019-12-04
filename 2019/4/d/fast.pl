#! /usr/bin/env perl
use strict;
use warnings;

sub next_num {
    my ($num) = @_;
    my @digits = split //, $num + 1;

    for my $i (1 .. $#digits) {
        if ($digits[$i] < $digits[$i-1]) {
            $digits[$i]++;
            redo;
        }
    }

    join '', @digits
}

sub solve {
    my ($start, $end) = @_;
    my ($p1, $p2) = (0, 0);

    for (my $n = $start; $n <= $end; $n = next_num $n) {
        ++$p1 if $n =~ /(.)\1/;
        foreach my $d (0 .. 9) {
            if ($n =~ /$d$d/ && $n !~ /$d$d$d/) {
                ++$p2;
                last;
            }
        }
    }

    ($p1, $p2)
}

die "usage: $0 <start> <end>\n" unless @ARGV == 2;
my ($p1, $p2) = solve(@ARGV);
print "part 1: $p1\n";
print "part 2: $p2\n";
