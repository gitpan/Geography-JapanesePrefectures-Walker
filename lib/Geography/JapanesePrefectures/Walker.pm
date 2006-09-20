package Geography::JapanesePrefectures::Walker;
use strict;
use warnings;
use Carp;
use Scalar::Util qw(blessed);
use UNIVERSAL;
use Encode;
use List::MoreUtils qw/uniq firstval/;
use Geography::JapanesePrefectures;

our $VERSION = '0.01';

sub new {
    my $class = shift;
    my $encoding = shift || 'utf8';
    my $param = {
        encoding => $encoding,
    };
    bless $param, $class;
}

*isa = \&UNIVERSAL::isa;

sub prefectures_infos {
    my $self = shift;
    $self->encode_to(Geography::JapanesePrefectures->prefectures_infos);
}

sub encode_to {
    my($self, $stuff) = @_;
    $self->apply(
        sub {
            my $val = shift;
            Encode::from_to($val,'utf-8',$self->{encoding});
            $val;
        }
    )->($stuff);
}

sub apply { ## no critic
    my $self = shift;
    my $code = shift;

    my $keyapp = sub { $code->(shift) };

    my $curry; # recursive so can't init
    $curry = sub {
        my @retval;
        for my $arg (@_){
            my $class = ref $arg;
            croak 'blessed reference forbidden'
                if  !$self->{apply_blessed} and blessed $arg;
                my $val =
                    !$class ?
                        $code->($arg) :
                    isa($arg, 'ARRAY') ?
                        [ $curry->(@$arg) ] :
                    isa($arg, 'HASH') ?
                        {
                        map { $keyapp->($_)
                                => $curry->($arg->{$_}) } keys %$arg
                        } :
                    isa($arg, 'SCALAR') ?
                        \do{ $curry->($$arg) } :
                    isa($arg, 'REF') && $self->{apply_ref} ?
                        \do{ $curry->($$arg) } :
                    isa($arg, 'GLOB')  ?
                        *{ $curry->(*$arg) } :
                    isa($arg, 'CODE') && $self->{apply_code} ?
                        $code->($arg) :
                    croak "I don't know how to apply to $class" ;
                bless $val, $class if blessed $arg;
                push @retval, $val;
        }
        return wantarray ? @retval : $retval[0];
    };
}

sub prefectures {
    my $self = shift;

    return [ map { {
                    id     => $_->{id} ,
                    name   => $_->{name},
                    region => $_->{region},
                   } } @{$self->prefectures_infos} ];
}

sub prefectures_name_for_id {
    my ($self, $id) = @_;

    my $pref = firstval { $_->{id} } grep { $_->{id} eq $id } @{$self->prefectures_infos};
    return $pref->{name};
}

sub prefectures_name {
    my $self = shift; 

    return map { $_->{name} } @{$self->prefectures_infos};
}

sub prefectures_regions {
    my $self = shift;

    return uniq map { $_->{region} } @{$self->prefectures_infos};
}

sub prefectures_name_for_region {
    my ($self, $region) = @_;

    return map { $_->{name} }
           grep { $_->{region} eq $region }
           @{$self->prefectures_infos};
}

sub prefectures_id_for_name {
    my ($self, $name) = @_;

    my $pref = firstval { $_->{id} } grep { $_->{name} eq $name } @{$self->prefectures_infos};
    return $pref->{id};
}

=head1 NAME

Geography::JapanesePrefectures::Walker - Geography::JapanesePrefectures's wrappers.

=head1 VERSION

This documentation refers to Geography::JapanesePrefectures::Walker version 0.01

=head1 SYNOPSIS

in your script:

    use Geography::JapanesePrefectures::Walker;
    my $g = Geography::JapanesePrefectures::Walker->new('euc-jp');
    my $prefs = $g->prefectures;

=head1 METHODS

=head2 new

create Geography::JapanesePrefectures::Walker's object.

=head2 encode_to

encode utf8 to your charset.

=head2 apply

walker method...
see Plagger::Walker.

=head2 prefectures_infos

This method get Geography::JapanesePrefectures's all data.
But may be you don't use this method.

=head2 prefectures

This method get Geography::JapanesePrefectures's all data.

=head2 prefectures_name_for_id

This method get Geography::JapanesePrefectures's name data for id.

=head2 prefectures_name

This method get Geography::JapanesePrefectures's name data.

=head2 prefectures_regions

This method get Geography::JapanesePrefectures's region data.

=head2 prefectures_name_for_region

This method get Geography::JapanesePrefectures's name data for region.

=head2 prefectures_id_for_name

This method get Geography::JapanesePrefectures's id data for name.

=head1 SEE ALSO

L<Geography::JapanesePrefectures>

L<Plagger::Walker>

=head1 THANKS TO

The authors of Plagger::Walker, from which a lot of code was used.

id:tokuhirom

=head1 AUTHOR

Atsushi Kobayashi, C<< <nekokak at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-geography-japaneseprefectures-walker at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Geography-JapanesePrefectures-Walker>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Geography::JapanesePrefectures::Walker

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Geography-JapanesePrefectures-Walker>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Geography-JapanesePrefectures-Walker>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Geography-JapanesePrefectures-Walker>

=item * Search CPAN

L<http://search.cpan.org/dist/Geography-JapanesePrefectures-Walker>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2006 Atsushi Kobayashi, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Geography::JapanesePrefectures::Walker
