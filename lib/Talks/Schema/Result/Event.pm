use utf8;
package Talks::Schema::Result::Event;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Talks::Schema::Result::Event

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 TABLE: C<event>

=cut

__PACKAGE__->table("event");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 description

  data_type: 'varchar'
  is_nullable: 1
  size: 300

=head2 start_date

  data_type: 'datetime'
  is_nullable: 0

=head2 end_date

  data_type: 'datetime'
  is_nullable: 1

=head2 venue_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 event_series_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 year_id

  data_type: 'integer'
  default_value: 2000
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "description",
  { data_type => "varchar", is_nullable => 1, size => 300 },
  "start_date",
  { data_type => "datetime", is_nullable => 0 },
  "end_date",
  { data_type => "datetime", is_nullable => 1 },
  "venue_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "event_series_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "year_id",
  {
    data_type      => "integer",
    default_value  => 2000,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 event_series

Type: belongs_to

Related object: L<Talks::Schema::Result::EventSeries>

=cut

__PACKAGE__->belongs_to(
  "event_series",
  "Talks::Schema::Result::EventSeries",
  { id => "event_series_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 presentations

Type: has_many

Related object: L<Talks::Schema::Result::Presentation>

=cut

__PACKAGE__->has_many(
  "presentations",
  "Talks::Schema::Result::Presentation",
  { "foreign.event_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 venue

Type: belongs_to

Related object: L<Talks::Schema::Result::Venue>

=cut

__PACKAGE__->belongs_to(
  "venue",
  "Talks::Schema::Result::Venue",
  { id => "venue_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 year

Type: belongs_to

Related object: L<Talks::Schema::Result::Year>

=cut

__PACKAGE__->belongs_to(
  "year",
  "Talks::Schema::Result::Year",
  { id => "year_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-04-06 14:12:35
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:4C0oUJ5c8epLKXxU72LNKg

sub slug {
  my $self = shift;
  my $slug = lc $self->description;
  $slug =~ s/[-\s]+/-/g;
  $slug =~ s/[^a-z0-9-]//g;
  return $slug;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
