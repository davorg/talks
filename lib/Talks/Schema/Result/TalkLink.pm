use utf8;
package Talks::Schema::Result::TalkLink;

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

__PACKAGE__->table("talk_link");

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "link",
  { data_type => "text", is_nullable => 0 },
  "type",
  { data_type => "char", is_nullable => 0, size => 15 },
  "title",
  { data_type => "text", is_nullable => 1 },
  "talk_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->belongs_to(
  "talk",
  "Talks::Schema::Result::Talk",
  { id => "talk_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

sub display_title {
  my $self = shift;
  return $self->title || ($self->link =~ s{^https://}{}r);
}

__PACKAGE__->meta->make_immutable;
1;
