'use strict';

albumApp.controller('AlbumController',
    function AlbumController($scope, $http) {
        $http.get("photos/album.json").success(function(data){
            $scope.albums = data;
            $scope.albums.sort(function(album1, album2) {
                if (album1.date < album2.date) {
                    return -1;
                }
                if (album1.date > album2.date) {
                    return 1;
                }
                return 0;
            });

            $scope.viewer = new PhotoViewer();

            angular.forEach($scope.albums, function(album) {
                album.viewer = new PhotoViewer();
                album.maxDate = album.date;
                angular.forEach(album.photos, function(photo) {
                    if (album.maxDate < photo.date) {
                        album.maxDate = photo.date;
                    }
                    $scope.viewer.add('/photos/' + photo.moy);
                    album.viewer.add('/photos/' + photo.moy);
                });

            });
        });

        $scope.viewShow = function() {
            $scope.viewer.show(0);
        };

        $scope.viewShowAlbum = function(album) {
            album.viewer.show(0);
        };
    }
);
