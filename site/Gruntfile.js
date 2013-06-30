'use strict';
var lrSnippet = require('grunt-contrib-livereload/lib/utils').livereloadSnippet;
var mountFolder = function (connect, dir) {
    return connect.static(require('path').resolve(dir));
};

module.exports = function (grunt) {
    // load all grunt tasks
    require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks);

    grunt.initConfig({
        watch: {
            livereload: {
                files: [
                    '{,*/}*.html', 'js/{,*/}*.js', 'photos/{,*/}*.{png,jpg,jpeg,JPG,gif,webp,svg}', 'img/{,*/}*.{png,jpg,jpeg,JPG,gif,webp,svg}', 'css/{,*/}*.css'
                ],
                tasks: ['livereload']
            }
        },
        connect: {
            options: {
                port: 8080,
                // Change this to '0.0.0.0' to access the server from outside.
                hostname: 'localhost'
            },
            livereload: {
                options: {
                    middleware: function (connect) {
                        return [
                            lrSnippet, mountFolder(connect, '.')
                        ];
                    }
                }
            },
        },
        open: {
            server: {
                url: 'http://localhost:<%= connect.options.port %>'
            }
        },
        clean: {
            dist: {
                files: [
                    {
                        dot: true,
                        src: [
                            '.', '.git*'
                        ]
                    }
                ]
            },
            server: '.'
        }
    });

    grunt.renameTask('regarde', 'watch');

    grunt.registerTask('server', [
        'livereload-start', 'connect:livereload', 'open', 'watch'
    ]);

    grunt.registerTask('default', ['server']);
};