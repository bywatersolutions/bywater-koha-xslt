package Koha::Service::AuthorisedValues;

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

use C4::Koha;

use base 'Koha::Service';

sub new {
    my ($class) = @_;

    # Authentication is handled manually below
    return $class->SUPER::new(
        {
            authnotrequired => 0,
            routes          => [
                [ qr'GET /(.+)', 'get_authorised_values' ],
            ],
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

sub get_authorised_values {
    my ( $self, $category ) = @_;

    $self->output( GetAuthorisedValues($category) );
}

1;
