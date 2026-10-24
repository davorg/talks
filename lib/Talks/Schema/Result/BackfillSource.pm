use utf8;
package Talks::Schema::Result::BackfillSource;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Talks::Schema::Result::BackfillSource

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

=head1 TABLE: C<backfill_source>

=cut

__PACKAGE__->table("backfill_source");

=head1 ACCESSORS

=head2 batch

  data_type: 'text'
  is_nullable: 0

=head2 source_id

  data_type: 'text'
  is_nullable: 0

=head2 presentation_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 record_json

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "batch",
  { data_type => "text", is_nullable => 0 },
  "source_id",
  { data_type => "text", is_nullable => 0 },
  "presentation_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "record_json",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</batch>

=item * L</source_id>

=back

=cut

__PACKAGE__->set_primary_key("batch", "source_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<batch_presentation_id_unique>

=over 4

=item * L</batch>

=item * L</presentation_id>

=back

=cut

__PACKAGE__->add_unique_constraint("batch_presentation_id_unique", ["batch", "presentation_id"]);

=head1 RELATIONS

=head2 presentation

Type: belongs_to

Related object: L<Talks::Schema::Result::Presentation>

=cut

__PACKAGE__->belongs_to(
  "presentation",
  "Talks::Schema::Result::Presentation",
  { id => "presentation_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2026-10-24 11:17:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:y39znkZ1HF9pD85FYBOzuA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
