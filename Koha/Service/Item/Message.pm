package Koha::Service::Item::Message;

# This file is part of Koha.
#
# Copyright (C) 2015 ByWater Solutions
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use JSON;

use Koha::Database;
use C4::Koha;

use base 'Koha::Service';

sub new {
    my ($class) = @_;

    # Authentication is handled manually below
    return $class->SUPER::new(
        {
            authnotrequired => 0,
            needed_flags    => { editcatalogue => 'edit_catalogue' },
            routes          => [
                [ qr'GET /(\d+)',    'get_messages' ],
                [ qr'POST /(\d+)',   'add_message' ],
                [ qr'PUT /(\d+)',    'update_message' ],
                [ qr'DELETE /(\d+)', 'delete_message' ],
            ]
        }
    );
}

sub run {
    my ($self) = @_;

    $self->authenticate;

    unless ( $self->auth_status eq "ok" ) {
        $self->output(
            XMLout( { auth_status => $self->auth_status }, NoAttr => 1, RootName => 'response', XMLDecl => 1 ),
            { type => 'xml', status => '403 Forbidden' } );
        exit;
    }

    $self->dispatch;
}

sub get_messages {
    my ( $self, $itemnumber ) = @_;

    my $rs = Koha::Database->new->schema()->resultset('ItemMessage')
      ->search( { itemnumber => $itemnumber }, { result_class => 'DBIx::Class::ResultClass::HashRefInflator' } );

    my @messages = map { $_ } $rs->all();
    map { $_->{authorised_value} = GetAuthorisedValueByCode( 'ITEM_MESSAGE', $_->{type} ) } @messages;

    $self->output( \@messages );
}

sub add_message {
    my ( $self, $itemnumber ) = @_;

    my $query = $self->query;

    my $json = $query->param('POSTDATA');
    my $data = from_json( $json, { utf8 => 1 } );

    my $type    = $data->{type};
    my $message = $data->{message};

    my $msg = Koha::Database->new->schema()->resultset('ItemMessage')->create(
        {
            itemnumber => $itemnumber,
            type       => $type,
            message    => $message,
        }
    );
    $msg->discard_changes();

    $self->output(
        {
            item_message_id  => $msg->id(),
            itemnumber       => $itemnumber,
            type             => $type,
            message          => $message,
            created_on       => $msg->created_on(),
            authorised_value => GetAuthorisedValueByCode( 'ITEM_MESSAGE', $type ),
        }
    );
}

sub update_message {
    my ( $self, $id ) = @_;

    my $query = $self->query;

    my $json = $query->param('PUTDATA');
    my $data = from_json( $json, { utf8 => 1 } );

    my $type    = $data->{type};
    my $message = $data->{message};

    my $msg = Koha::Database->new->schema()->resultset('ItemMessage')->find($id);

    croak("no item message") unless $msg;

    $msg->update(
        {
            type    => $type,
            message => $message,
        }
    );

    $self->output(
        {
            item_message_id  => $msg->id(),
            itemnumber       => $msg->get_column('itemnumber'),
            type             => $type,
            message          => $message,
            created_on       => $msg->created_on(),
            authorised_value => GetAuthorisedValueByCode( 'ITEM_MESSAGE', $type ),
        }
    );
}

sub delete_message {
    my ( $self, $id ) = @_;

    my $msg = Koha::Database->new->schema()->resultset('ItemMessage')->find($id);

    craok("no item message") unless $msg;

    $msg->delete();

    $self->output(
        {
            item_message_id => $msg->id(),
            itemnumber      => $msg->get_column('itemnumber'),
            type            => $msg->type(),
            message         => $msg->message(),
            created_on      => $msg->created_on(),
        }
    );
}

1;
