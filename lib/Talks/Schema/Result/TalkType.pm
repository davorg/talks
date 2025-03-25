use utf8;
package Talks::Schema::Result::TalkType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Talks::Schema::Result::TalkType

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<talk_type>

=cut

__PACKAGE__->table("talk_type");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 type

  data_type: 'char'
  is_nullable: 0
  size: 15

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "type",
  { data_type => "char", is_nullable => 0, size => 15 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<type_unique>

=over 4

=item * L</type>

=back

=cut

__PACKAGE__->add_unique_constraint("type_unique", ["type"]);

=head1 RELATIONS

=head2 talks

Type: has_many

Related object: L<Talks::Schema::Result::Talk>

=cut

__PACKAGE__->has_many(
  "talks",
  "Talks::Schema::Result::Talk",
  { "foreign.talk_type_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-11-11 16:01:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7iEKgYaLjj9ndiFS9De5bg

sub slug {
  my $self = shift;
  my $slug = lc $self->type;
  $slug =~ s/[-\s]+/-/g;
  $slug =~ s/[^a-z0-9-]//g;
  return $slug;
}

sub title {
  my $self = shift;
  return $self->type;
}

sub description {
  my $self = shift;
  return $self->type;
}

sub url_path {
  my $self = shift;
  return '/type/' . $self->slug . '/';
}

sub outfile {
  my $self = shift;
  return $self->url_path . 'index.html' =~ s|^/||r;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
