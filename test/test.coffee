coffee      = require 'coffee-script/register'
moment      = require 'moment'
mocha       = require 'mocha'
should      = require('chai').should()
exists      = require('fs').existsSync
join        = require('path').join
each        = require('lodash').each
_           = require('lodash')

Metalsmith  = require 'metalsmith'
archive     = require '..'

describe 'metalsmith-archive', () ->

   beforeEach () ->
   
   describe 'using default options', ()->
      
      it 'should generate yearly archive page', (done)->
         
         Metalsmith(__dirname)
            .source('fixtures/src')
            .use archive()
            .build (err, files) ->
               should.not.exist(err)
               should.exist(files)
               should.exist files['2015/index.html']
               should.not.exist files['2014/index.html']
               should.not.exist files['2016/index.html']
               done()
   
      it 'should generate monthly archive pages', (done)->
         
         Metalsmith(__dirname)
            .source('fixtures/src')
            .use archive()
            .build (err, files) ->
               should.not.exist(err)
               should.exist(files)
               should.exist files['2015/01/index.html' ]
               should.exist files['2015/02/index.html' ]
               should.not.exist files['2015/03/index.html' ]
               done()
   
      it 'should generate daily archive pages', (done)->
         
         Metalsmith(__dirname)
            .source('fixtures/src')
            .use archive()
            .build (err, files) ->
               should.not.exist(err)
               should.exist(files)
               should.exist files['2015/01/01/index.html' ]
               should.exist files['2015/02/16/index.html' ]
               should.not.exist files['2015/01/02/index.html' ]
               done()
   
      it 'should add archivedPosts to each archive page', (done)->
         
         Metalsmith(__dirname)
            .source('fixtures/src')
            .use archive()
            .build (err, files) ->
               should.not.exist(err)
               should.exist(files)
               should.exist files['2015/index.html' ].archivedPosts
               should.exist files['2015/01/index.html' ].archivedPosts
               should.exist files['2015/02/index.html' ].archivedPosts
               should.exist files['2015/01/01/index.html' ].archivedPosts
               should.exist files['2015/02/16/index.html' ].archivedPosts
               done()
   
      it 'should have correct number of archivedPosts', (done)->
         
         Metalsmith(__dirname)
            .source('fixtures/src')
            .use archive()
            .build (err, files) ->
               should.not.exist(err)
               should.exist(files)
               files['2015/index.html' ].archivedPosts.length.should.equal(3)
               files['2015/01/index.html' ].archivedPosts.length.should.equal(1)
               files['2015/02/index.html' ].archivedPosts.length.should.equal(2)
               files['2015/01/01/index.html' ].archivedPosts.length.should.equal(1)
               files['2015/02/16/index.html' ].archivedPosts.length.should.equal(1)
               done()

      it 'should have sorted archivedPosts in ascending order', (done)->
         
         Metalsmith(__dirname)
            .source('fixtures/src')
            .use archive()
            .build (err, files) ->
               should.not.exist(err)
               should.exist(files)
               first = files['2015/02/index.html' ].archivedPosts[0]
               last = files['2015/02/index.html' ].archivedPosts[1]
               moment(first.date).isBefore(last.date).should.be.true
               done()

      it 'should use default templates for archive pages', (done)->
         
         Metalsmith(__dirname)
            .source('fixtures/src')
            .use archive()
            .build (err, files) ->
               should.not.exist(err)
               should.exist(files)
               files['2015/index.html' ].template.should.equal 'archive.jade'
               files['2015/01/index.html' ].template.should.equal 'archive.jade'
               files['2015/01/01/index.html' ].template.should.equal 'archive.jade'
               done()
   
      it 'should copy metadata into archivedPosts', (done)->
         
         Metalsmith(__dirname)
            .source('fixtures/src')
            .use archive()
            .build (err, files) ->
               should.not.exist(err)
               should.exist(files)
               post = files['2015/01/index.html'].archivedPosts[0]
               should.exist(post)
               post.title.should.equal 'test title'
               post.author.should.equal 'test-author'
               post.image.should.equal 'test.jpg'
               post.wordCount.should.equal 42
               post.readingTime.should.equal 2
               post.tags.should.equal 'a,b,c'
               should.not.exist(post.slug)
               done()
   
