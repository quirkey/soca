# soca

Sammy On Couch App or Sittin' On a Couch App

## What?

A *couchapp* is method of creating applications that live inside CouchDB's 
design documents. This can be a simple as an index.html and as complicated
as a full interactive JavaScript application. couchapp's inherently have a
a bunch of really cool features - easy replication and synchronization,
instant access to store and fetch data from CouchDB, and a full JS API. [Sammy.js](http://code.quirkey.com/sammy) is a perfect fit for couchapps providing a simple programmable controller layer on top of CouchDB's data.

I highly recommend reading the section on couchapps in the [CouchDB Book](http://couchdb.apache.org/relax).

*soca* is a simple command line tool written in ruby for building and pushing 
couchapps. It is similar to and heavily inspired by the canonical couchapp
python tool, [couchapp](http://github.com/couchapp/couchapp), with a number
of key differences.

* local directories do not have to map 1-1 to the design docs directory
* lifecycle hooks for easily adding or modifying the design document with
  ruby tools or plugins.
* architected around using Sammy.js, instead of Evently, which is bundled
  with the python tool.
* super tiny and hackable, with the hope that people will contribute patches
  and plugins.

## Why?

I'm not one to start a language war, I think python is great and the existing 
couchapp tool works great for most situations. In fact I've built apps using
it. I found myself working around the design documents structure, which makes 
sense when in JSON, but much less sense when mapped to the filesystem. By making a simple tool, that takes a JSON map of directories and files and
places them in their expected JSON slot, you make a new sort of couchapp.

Unlike a traditional couchapp, a soca couchapp is actually one way - you're 
source directory is actually 'compiled' into its final state. This allows you
to do things you couldnt before, including bundling js files, using external
tools like [compass](http://compassstyle.org), and just generally following
your own preffered directory structure. This does mean that there is no `soca 
clone` to get a couchapp out of CouchDB - though replicating works the same as 
before (and is probably faster because you push only the docs you need or 
use).

The bottom line is I wanted to build couchapp's with a workflow and structure 
I had already established - `soca` lets me do that.

## How?

`soca` is bundled as a ruby gem so installation is easy-peasy. On a system 
with ruby and ruby gems (OS X for example):

    gem install soca
    
This will give you the `soca` bin as long as gems are in your path.

    soca
    
Will display all the command options.

The typical workflow would be:

    # Generate the app
    soca generate myapp 
    # cd into the app
    cd myapp
    # edit your .couchapprc with the db url
    # Do your work, editing app.js, etc
    # push the app to couchdb
    soca push
    # open the app in a browser
    soca open

Once you get it set up, you can also use 

    soca autopush
    
Which will watch the directory and push your changes automagically.

## TODO

* Better Docs
* More plugins
* More generate options (compass scaffold, etc)
* More example apps

## Copyright/License

Copyright (c) 2010 Aaron Quint under the MIT License. See LICENSE for details.
