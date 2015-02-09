var koha = angular.module('Koha', []);

koha.factory('AuthorisedValueService', [ '$http', function( $http ) {
    var authorised_values = {};

    return {
        list: function( params ) {
            var category = params.category;
            var callback = params.callback;

            if ( authorised_values[category] ) {
                if ( callback ) {
                    return callback(authorised_values[category]);
                } else {
                    return authorised_values[category];
                }
            } else {
                $http.get('/cgi-bin/koha/svc/authorised_values/' + category).then(function(response) {
                    authorised_values[category] = response.data;

                    if ( callback ) {
                        return callback(response.data);
                    } else {
                        return response.data;
                    }
                }, function(errResponse) {
                    console.error('Error while fetching authorised values');
                });
            }
        },
    };
}]);

koha.directive('itemMessages', [ '$http', 'AuthorisedValueService', function( $http, AuthorisedValueService ) {
    return {
        scope: {
            itemnumber: '@'
        },
        templateUrl: '/intranet-tmpl/prog/en/includes/partials/widgets/item-messages.html',
        link: function($scope, $element, $attrs) {
            $scope.showAddNewMessage = false;
            $scope.messages = [];

            AuthorisedValueService.list( {
                category: 'ITEM_MESSAGE',
                callback: function( types ) {
                  $scope.types = types;
                },
            } );

            $http.get('/cgi-bin/koha/svc/item/message/' + $scope.itemnumber).then(function(response) {
                $scope.messages = response.data;
            }, function(errResponse) {
                console.error('Error while fetching notes');
            });

            $scope.create = function() {
                $scope.showAddNewMessage = false;

                $http.post('/cgi-bin/koha/svc/item/message/' + $scope.itemnumber, $scope.itemMessage).then(function(response) {
                    $scope.hideNewMessageEditor();
                    $scope.messages.push( response.data );
                }, function(errResponse) {
                    console.error('Error while posting note');
                });
            }

            $scope.remove = function(im) {
                $http.delete('/cgi-bin/koha/svc/item/message/' + im.item_message_id).then(function(response) {
                    var index = $scope.messages.indexOf(im);
                    $scope.messages.splice( index, 1 );
                }, function(errResponse) {
                    console.error('Error while deleting note');
                });
            }

            $scope.showNewMessageEditor = function() {
                $scope.showAddNewMessage = true;
            };

            $scope.hideNewMessageEditor = function() {
                $scope.showAddNewMessage = false;
                $scope.itemMessage.type = "";
                $scope.itemMessage.message = "";
            };
        }
    };
}]);
