use utf8;
package Koha::Schema::Result::ItemMessage;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ItemMessage

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<item_messages>

=cut

__PACKAGE__->table("item_messages");

=head1 ACCESSORS

=head2 item_message_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 itemnumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 type

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 message

  data_type: 'text'
  is_nullable: 0

=head2 created_on

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "item_message_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "itemnumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "type",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "message",
  { data_type => "text", is_nullable => 0 },
  "created_on",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</item_message_id>

=back

=cut

__PACKAGE__->set_primary_key("item_message_id");

=head1 RELATIONS

=head2 itemnumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Item>

=cut

__PACKAGE__->belongs_to(
  "itemnumber",
  "Koha::Schema::Result::Item",
  { itemnumber => "itemnumber" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2015-02-09 07:59:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:6shNRfWMQ+v1d5GwgX01rw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
