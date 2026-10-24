use utf8;
package Talks::Schema::Result::Presentation;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Talks::Schema::Result::Presentation

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

=head1 TABLE: C<presentation>

=cut

__PACKAGE__->table("presentation");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 datetime

  data_type: 'datetime'
  is_nullable: 1

=head2 video_url

  data_type: 'text'
  is_nullable: 1

=head2 slide_url

  data_type: 'text'
  is_nullable: 1

=head2 talk_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 event_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 youtube_code

  data_type: 'char'
  is_nullable: 1
  size: 20

=head2 google_docs_code

  data_type: 'text'
  is_nullable: 1

=head2 pdf_url

  data_type: 'text'
  is_nullable: 1

=head2 has_image

  data_type: 'boolean'
  is_nullable: 1

=head2 title

  data_type: 'text'
  is_nullable: 1

=head2 date_label

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "datetime",
  { data_type => "datetime", is_nullable => 1 },
  "video_url",
  { data_type => "text", is_nullable => 1 },
  "slide_url",
  { data_type => "text", is_nullable => 1 },
  "talk_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "event_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "youtube_code",
  { data_type => "char", is_nullable => 1, size => 20 },
  "google_docs_code",
  { data_type => "text", is_nullable => 1 },
  "pdf_url",
  { data_type => "text", is_nullable => 1 },
  "has_image",
  { data_type => "boolean", is_nullable => 1 },
  "title",
  { data_type => "text", is_nullable => 1 },
  "date_label",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 backfill_sources

Type: has_many

Related object: L<Talks::Schema::Result::BackfillSource>

=cut

__PACKAGE__->has_many(
  "backfill_sources",
  "Talks::Schema::Result::BackfillSource",
  { "foreign.presentation_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 event

Type: belongs_to

Related object: L<Talks::Schema::Result::Event>

=cut

__PACKAGE__->belongs_to(
  "event",
  "Talks::Schema::Result::Event",
  { id => "event_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 talk

Type: belongs_to

Related object: L<Talks::Schema::Result::Talk>

=cut

__PACKAGE__->belongs_to(
  "talk",
  "Talks::Schema::Result::Talk",
  { id => "talk_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2026-10-24 11:17:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JdKn7vTxpPQ3oVkCn9X98A


sub display_title {
  my $self = shift;
  my $title = $self->title;

  return $title if defined $title && $title =~ /\S/;
  return $self->talk->title;
}

sub display_datetime {
  my $self = shift;
  return $self->date_label if defined $self->date_label && length $self->date_label;
  return $self->datetime // '';
}

__PACKAGE__->meta->make_immutable;
1;
