use utf8;
package Talks::Schema::Result::Talk;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Talks::Schema::Result::Talk

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 TABLE: C<talk>

=cut

__PACKAGE__->table("talk");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 title

  data_type: 'text'
  is_nullable: 0

=head2 video_url

  data_type: 'text'
  is_nullable: 1

=head2 slide_url

  data_type: 'text'
  is_nullable: 1

=head2 talk_type_id

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

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 summary

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "title",
  { data_type => "text", is_nullable => 0 },
  "video_url",
  { data_type => "text", is_nullable => 1 },
  "slide_url",
  { data_type => "text", is_nullable => 1 },
  "talk_type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "youtube_code",
  { data_type => "char", is_nullable => 1, size => 20 },
  "google_docs_code",
  { data_type => "text", is_nullable => 1 },
  "description",
  { data_type => "text", is_nullable => 1 },
  "summary",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 presentations

Type: has_many

Related object: L<Talks::Schema::Result::Presentation>

=cut

__PACKAGE__->has_many(
  "presentations",
  "Talks::Schema::Result::Presentation",
  { "foreign.talk_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 talk_type

Type: belongs_to

Related object: L<Talks::Schema::Result::TalkType>

=cut

__PACKAGE__->belongs_to(
  "talk_type",
  "Talks::Schema::Result::TalkType",
  { id => "talk_type_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-04-13 11:29:44
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:aJQccBm3jmyraBXLGgwbmA

sub slug {
  my $self = shift;
  my $slug = lc $self->title;
  $slug =~ s/[-\s]+/-/g;
  $slug =~ s/[^a-z0-9-]//g;
  return $slug;
}

sub get_youtube_code {
  my $self = shift;

  for ($self->presentations) {
    $_->youtube_code and return $_->youtube_code;
  }

  return;
}

sub get_google_docs_code {
  my $self = shift;

  for ($self->presentations) {
    $_->google_docs_code and return $_->google_docs_code;
  }

  return;
}

sub get_pdf_url {
  my $self = shift;

  for ($self->presentations) {
    $_->pdf_url and return $_->pdf_url;
  }

  return;
}

sub extras {
  my $self = shift;

  return ($self->get_youtube_code
       or $self->get_google_docs_code
       or $self->get_pdf_url);
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
