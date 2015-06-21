_        = require 'lodash'
moment   = require 'moment'

module.exports = (options) ->
   options ?= {}
   defaults = 
      property: 'date'
      sort: 'asc'
      paths:
         year: ':year/index.html'   
         month: ':year/:month/index.html'   
         day: ':year/:month/:day/index.html'   
      templates:
         year: 'archive.jade'
         month: 'archive.jade'
         day: 'archive.jade'

   _.defaults options, defaults

   createArchiveObject = (period, year, month, day) ->
      archive = 
         archivedPosts: []
         template: options.templates[period]
         children: {}
         contents: ""
         title: generateArchiveTitle(period, year, month, day)
         path: generateArchivePath(period, year, month, day)
       

   generateArchivePath = (period, year, month, day) ->
      path = options.paths[period].replace(':year', year)
      path = path.replace(':month', month) if month?
      path = path.replace(':day', day) if day?
      return path


   generateArchiveTitle = (period, year, month, day) ->
      date = moment("#{year}-#{month}-#{day}", "YYYY-MM-DD")
      title = year if period is 'year'
      title = date.format("MMMM YYYY") if period is 'month'
      title = date.format("dddd D MMMM YYYY") if period is 'day'
      return title

   # recursively sorts the archived posts by date
   sortArchivedPosts = (archives, order) ->
      for key, value of archives
         value.archivedPosts = _.sortBy value.archivedPosts, 'date'
         value.archivedPosts.reverse() if order is 'desc'
         sortArchivedPosts(value.children, order) if value.children?


   addDateToArchive = (archive, year, month, day) ->
      archive[year] ?= createArchiveObject('year', year)
      archive[year].children[month] ?= createArchiveObject('month', year, month)
      archive[year].children[month].children[day] ?= createArchiveObject('day', year, month, day)


   # recursively adds the archive objects to the files collection
   # pruning the no longer needed children subobject at the same time
   addArchivesToFiles = (archives, files) ->
      for key, value of archives
         addArchivesToFiles(value.children, files) if value.children?
         delete value.children
         files[value.path] = value

   addArchivesToMetadata = (archives, metadata) ->
      metadata.archives = 
         years: _.values archives
         months:  _.flatten _.map archives, (i) -> _.values i.children
         
      _.each metadata.archives.years, (year) ->
         year.months = _.values year.children
         
      
   (files, metalsmith, next) ->
      
      archive = {}
      
      # loop through each file to build its tags collection
      for filename of files

         # pull back the file data
         file = files[filename]
         
         # extract the date as a string
         dateString = file[options.property]

         # we can only archive posts with a date
         continue if not dateString?
         
         # convert to moment and extract the date components
         date = moment(dateString)
         year = date.format('YYYY')
         month = date.format('MM')
         day = date.format('DD')
         
         # ensure an object exists for the year, month and day
         addDateToArchive(archive, year, month, day)
         
         # add the file to each archive object
         archive[year].archivedPosts.push file
         archive[year].children[month].archivedPosts.push file
         archive[year].children[month].children[day].archivedPosts.push file
         
      # sort the archived posts according to the options
      sortArchivedPosts(archive, options.sort)
            
      # add the archive data to metadata for use in navigation
      metadata = metalsmith.metadata()
      addArchivesToMetadata(archive, metadata)

      # add the newly minted archive pages to the files collection
      addArchivesToFiles(archive, files)
         
      next()
