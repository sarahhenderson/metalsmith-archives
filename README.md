metalsmith-archives
===================

A [Metalsmith](http://metalsmith.io) plugin that generates year, month and day archive pages based on the file date.

Usage
-----

The archives plugin can be used without any options:

```
var archives = require('metalsmith-archives');

Metalsmith.use(archives());

```

This will create archives that include all files that have a `date` property.
One page will be created for each year, month and day found in the file dates.

For instance, if you have two files with dates of July 18th 2014 and November 28th 2014, the plugin will generate:

- `2015/index.html` 
- `2015/07/index.html` 
- `2015/11/index.html` 
- `2015/07/18/index.html` 
- `2015/11/28/index.html` 

The default template it will use is `archive.jade`.

A `postArchives` field will be added to the page data for use in the template, containing a collection of all the pages in that archive.  The postArchives will be sorted in ascending order of date.


All of these options are configurable:

```
var archives = require('metalsmith-archives');

Metalsmith.use(archives({
   property: 'date',
   sort: 'asc',
   paths: {
      year: ':year/index.html',   
      month: ':year/:month/index.html',   
      day: ':year/:month/:day/index.html'   
   },
   templates: {
      year: 'archive.jade',
      month: 'archive.jade',
      day: 'archive.jade'
      }
   }
));

```

In addition, the plugin adds an 'archives' field to the Metalsmith metadata for you to use anywhere in the site.
The structure of this field is:

```
metadata.archives = {
   years: [
      {
         title: '2015'
         path: '2015/index.html'
         archivedPosts: []
      }
   ],
   months: [
      {
         title: 'July 2015'
         path: '2015/07/index.html'
         archivedPosts: []
      },
      {
         title: 'November 2015'
         path: '2015/11/index.html'
         archivedPosts: []
      }
   ]
};
```

Tests
-----
   
   $ npm test
   
Licence
-------

GPLv2
