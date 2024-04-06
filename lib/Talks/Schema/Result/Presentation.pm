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
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

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


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-04-04 17:38:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:4T245daFNx1QqN2H5S3JDA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
