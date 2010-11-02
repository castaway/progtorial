Chapter 0 - Introduction to the tutorial
========================================

[% contents %]

Chapter summary
---------------

This page introduces the tutorial and explains it's aims.

In this tutorial we will try to follow a series of logical steps along
the way to creating a fully fledged application with DBIx::Class.

The plan
--------

We're going to build a small blogging application which multiple users
can contribute articles to. Each user can write new main blog posts,
or add comments to existing posts. Each post/thread can be tagged with
descriptive words to help searching. Each tag can list all the posts
associated with it.

An administration section will only be usable by the admins of the
application, and will be able to moderate entries, ban users, delete
users, posts or comments.

Since this is a DBIx::Class tutorial, we'll be concentrating on the
model layer for this application. The interface will be demonstrated
using simple print statements. The complete examples are built with
[Term::Prompt](http://search.cpan.org/dist/Term-Prompt).

We'll create the following tables:

1. Users

    Almost every app needs users, we want people to join in, give
us their details, or we want to remember what they did. In this
application, each comment or post is tied to a particular pre-defined
user.

2. Posts

    A post is a main article with a title and a unique url. It is
created by a user and can have comments associated with it. Each post
can also be tagged.

3. Comments

    Each comment is associated with a particular post, and
written by a particular user.

4. Tags

    Each post can be tagged with any number of descriptive words. We
will restrict these to containing letters and numbers, underscores and
hyphens will become just hyphens. The display for a particular tag
will list all posts tagged with it.

Next Chapter
------------

[Describing the database](/tutorials/dbix-class/chapter/FromScratch)

# AUTHOR

Jess Robinson <castaway@desert-island.me.uk>
