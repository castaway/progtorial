Chapter 1 - Describing your database
====================================

[%# use all chapter files (in order?) to extract contents list? %]
[% contents %] [%# See L<DBIx::Class::Tutorial/CONTENTS> %]

Chapter summary
---------------

This chapter describes how to create a set of Perl modules using
DBIx::Class that describe your database tables, indexes and
relationships.

You should already have a good idea of what your database layout is,
and how you want to be able to access it, before embarking on this
tutorial. If you need help designing your database, have a look in
[Appendix3](http://search.cpan.org/perldoc?DBIx::Class::Tutorial::Appendix3), or buy a good book on
the subject.

[%# Book reccommendations, chapter on db design ! %]

If you already have a database that you are using you can still create
these files by hand following this chapter. You can also use
[DBIx::Class::Schema::Loader](http://search.cpan.org/perldoc?DBIx::Class::Schema::Loader) to create them automatically. Read the
documentation of that manual, or look in
[Appendix2](http://search.cpan.org/perldoc?DBIx::Class::Tutorial::Appendix2) on how to do that.

Perl classes you need to create
-------------------------------

To access your database in your Perl code uing DBIx::Class you need to
create a set of Perl classes that define the layout of your database
structure.

There are three types of source files available. A **Schema class**
defines the top layer object that all other data is accessed via. The
schema object is created with connection information for the
particular database it will be talking to. You can create a second
schema object to a different database (with the same table layout)
using the same class, if you wish.

A **Result class** should be defined for each table or view to be accessed,
which is used by DBIx::Class to represent a row of results for a query
done via that particular table or view. Methods acting on a row of
data can be added here.

**ResultSet classes** are optional and used to store commonly used methods
on sets of data. More about those later on.

<a name="#a-word-about-namespaces"></a>

A word about module namespaces
------------------------------

Current best practice suggests that you name your DBIx::Class files in
the following way:

    ## The Schema class
    <Databasename|Appname>::Schema

    ## The result classes
    <Databasename|Appname>::Schema::Result::<tablename>

    ## The resultset classes
    <Databasename|Appname>::Schema::ResultSet::<tablename>

Here, __Databasename|Appname__ refers to the top-level namespace for
your application. If the set of modules are to be used as a standalone
re-usable set for just this database, use the name of the database or
something that identifies it. If your modules are part of an entire
application, then the application top-level namespace may go here.

    # Examples:
    MyBlog::Schema
    MyBlog::Schema::Result::User
    MyBlog::Schema::ResulSet::User

While the table names in the database are often named using a plural,
eg _users_, the corresponding Result class is usually named in the
singular, as it respresents a single result, or row of the query.

The Schema class
----------------

The basic Schema class is fairly simple, it needs to inherit from
**DBIx::Class::Schema** and call a class method to load all the
associated Result and ResultSet classes.

    package MyBlog::Schema;
    use warnings;
    use strict;
    use base 'DBIx::Class::Schema';

    MyBlog::Schema->load_namespaces();

    1;

`load_namespaces` does the actual work here, it loads all the files
found in the `Result` and `ResultSet` subnamespaces of your schema,
see [A word about namespaces](#a-word-about-namespaces) above. It can
also be configured to use other namespaces, or load only a subset of
the available classes. See
[load_namespaces](http://search.cpan.org/perldoc?DBIx::Class::Schema#load_namespaces)
for documentation.

The loaded files are assumed to be actual **Result classes** (see
below) and **ResultSet classes** (more later) if anything else is
found in the subnamespaces, the load will complain and die.

[%#
For discussions of alternative styles and methods of writing Schema
classes, see [Alternative Schema classes](#pod_Alternative Schema classes) below.
%]

The Result class
----------------

Result classes are used to describe the source (table, view or query)
layout of each basic building block you will use to query the
database. A set of class methods are provided which proxy to calls in
[DBIx::Class::ResultSource](http://search.cpan.org/perldoc?DBIx::Class::ResultSource) to describe the columns and indexes of each source. An
instance of ResultSource is created for you and updated using these
methods. The actual ResultSource object itself is used internally by
DBIx::Class, the user will rarely need it. It can be queried for
example, to retrieve the list of columns that were defined for a
particular Result class.

Create a Result class for each source of data you wish to access, it is
not compulsory to create one for every table and view in the database.

The result class is also used as a base class for the results (or
Rows) of your DBIx::Class database queries, thus methods can be added
to them for use on the actual data.

Result classes should inherit from **DBIx::Class::Core**. This loads a number
of useful sub-components such as the **PK** (Primary key) component for defining and dealing with primary keys, and the **Relationship** component for creating relations to other result classes.

NB:

You can if you wish just inherit from **DBIx::Class**, and load the
components you will be using separately.

### Getting started, the User class

Our user table looks like this (in mysql):

    CREATE TABLE users (
      id INTEGER AUTOINCREMENT PRIMARY KEY,
      realname VARCHAR(255),
      username VARCHAR(255),
      password VARCHAR(255),
      email VARCHAR (255)
    );

This is the result class for the users table:

    1. package MyBlog::Schema::Result::User;
    2. use strict;
    3. use warnings;
    4. use base 'DBIx::Class::Core';
    5.
    6. __PACKAGE__->table('users');

Lines 1-4 are standard Perl code:

- Line 1

The `package` statement tells Perl which module the following code is
defining.

- Lines 2 and 3

The `use strict` and `use warnings` lines turn on useful error
reporting in Perl.

- Line 4

`use base` tells Perl to make this module inherit from the given module.

A note about notation: ___PACKAGE___ is the same as the current
package name in Perl, and it's shorter to write than the package name
itself, so you will see it all over the example code. It is documented
in [perldata](http://search.cpan.org/perldoc?perldata).

Then we get to the DBIx::Class specific bits:

[%#
`load_components` comes from [DBIx::Class::Componentised](http://search.cpan.org/perldoc?DBIx::Class::Componentised) and is
used to load a series of modules whose methods can delegate to each
other. Thus components need to be loaded in a specific order. The
[DBIx::Class::Core](http://search.cpan.org/perldoc?DBIx::Class::Core) component should always be loaded last so that
its methods are called after those of other components.

For a some examples of other useful components, see
L<DBIx::Class::Tutorial::??>.
%]

- Line 6

The `table` method is used to set the name of the database table this class is
using. It is a method in [DBIx::Class::ResultSourceProxy::Table](http://search.cpan.org/perldoc?DBIx::Class::ResultSourceProxy::Table) which is 
loaded as a component by [DBIx::Class::Core](http://search.cpan.org/perldoc?DBIx::Class::Core). 

[%#
That's a long way of saying: You must call it __after__ `load_components`.
%]

Calling the `table` method sets up the [DBIx::Class::ResultSource](http://search.cpan.org/perldoc?DBIx::Class::ResultSource)
instance ready for adding columns to, so this method must also be
called __before__ `add_columns` (see below).

NB: It is sensible to name your Result classes in the singular form;
_User_ not _Users_; since later these will represent a single
row, or user, object. Since tables contain multiple rows of users,
they are generally named in the plural.

### Describing the table structure

Now you can add lines describing the columns in your table.

    8. __PACKAGE__->add_columns(
    9.     id => {
    10.        data_type => 'integer',
    11.        is_auto_increment => 1,
    12.    },
    13.    realname => {
    14.      data_type => 'varchar',
    15.      size => 255,
    16.    },
    17.    username => {
    18.      data_type => 'varchar',
    19.      size => 255,
    20.    },
    21.    password => {
    22.      data_type => 'varchar',
    23.      size => 255,
    24.    },
    25.    email => {
    26.      data_type => 'varchar',
    27.      size => 255,
    28.    },
    29. );

    30. __PACKAGE__->set_primary_key('id');
    31. __PACKAGE__->add_unique_constraint('username_idx' => ['username']);

- Line 8

`add_columns` is called to define all the columns in your table that
you wish to tell DBIx::Class about, you may leave out some of the
table's columns if you wish. 

The `add_columns` call can provide as much or little description of the
columns as it likes, in its simplest form, it can contain just a list
of column names:

    __PACKAGE__->add_columns(qw/id realname username password email/);

This will work quite happily.

The longer version, used above, has several advantages. It can be used
to produce actual database tables from the schema, which will contain
proper types and sizes of columns in the database. It also serves as a
useful reminder to the developer of the columns available.

For the full documentation, read
L<DBIx::Class::ResultSource/add_columns>.

Fully describing the columns including data types and sizes allows you
to create the tables in your database from your schema
definition. This is done using L<DBIx::Class::Schema/deploy>.

- Lines 9 to 12

We add a column called `id` to store the _primary key_ of the
table. This will store a unique `integer` for each row in the
table. The primary key will use a self-incrementing field which most
databases supply, so we set `is_auto_increment` to 1.

- Line 15

The `varchar` column type requires a `size` parameter to tell the
database the maximum length data in the column can be.

- Line 30

Tell DBIx::Class which column or columns contain your _primary key_
by calling `set_primary_key` and passing it a list of column names.

The primary key columns are used by DBIx::Class to determine which
values it should add to the row object after it has been inserted into
the database. They are also used when automatically joining two
tables.

This and other methods dealing with primary keys are described in
[DBIx::Class::PK](http://search.cpan.org/perldoc?DBIx::Class::PK).

- Line 31

`add_unique_constraint` is called to let DBIx::Class know when your
table has other columns which hold unique values across rows (other
than the primary key, which must also be unique). The first argument
is a name for the constraint which can be anything, the second is a
arrayref of column names.

### Table relationships

The table structure information alone will allow you to query
individual tables using DBIx::Class. To do queries involving multiple
joined tables, you need to also describe the relationships between
them.

    32. __PACKAGE__->has_many('posts', 'MyBlog::Schema::Result::Post', 'user_id');

- Line 32

To describe a _one to many_ relationship we call the `has_many`
method. For this one, the `posts` table has a column named
`user_id` that contains the _id_ of the `users` table.

The first argument, `posts`, is a name for the relationship, this is
used as an accessor to retrieve the related items. It is also used
when creating queries to link tables.

The second argument, `MyBlog::Schema::Result::Post`, is the class name
for the related Result class file.

The third argument for `has_many`, `user_id`, describes the column
in the related table that contains the primary key of the table we are
writing the relationship on.

For more on relationships see [DBIx::Class::Relationship](http://search.cpan.org/perldoc?DBIx::Class::Relationship).

### Notes on Result classes

- Data types

The `data_type` field for each column in the `add_columns` is a free
text field, it is only used by DBIx::Class when deploying (creating
tables) the schema to a database. At that point `data_type` values
are converted to the appropriate type for your database by
[SQL::Translator](http://search.cpan.org/perldoc?SQL::Translator).

- More relationship types

[belongs_to](DBIx::Class::Relationship/belongs_to)

[has_one](DBIx::Class::Relationship/has_one)

[might_have](DBIx::Class::Relationship/might_have)

### Exercise: The Post class

The posts table looks like this in mysql:

    CREATE TABLE posts (
      id INT AUTO_INCREMENT,
      user_id INT,
      created_date DATETIME,
      title VARCHAR(255),
      post TEXT,
      INDEX posts_idx_user_id (user_id),
      PRIMARY KEY (id),
      CONSTRAINT posts_fk_user_id FOREIGN KEY (user_id) REFERENCES users (id)
    );


You will need another type of relationship for this class,
`belongs_to`. Use it like this:

    __PACKAGE__->belongs_to('user', 'MyBlog::Schema::Result::User', 'user_id');

As before, the first argument, `user`, is the name of the
relationship, used as an accessor to get the related _User_
object. It is also used in searching to join across the tables.

The second argument is the related class, the _User_ class we created
before.

The third argument is the column in the current class that contains
the primary key of the related class.

Create the Result class for it.

<a name="create-post-class"></a>

[% include_exercise('create-post-class') %]

### More result classes

We will be meeting some more _Result classes_ along the way, I will
describe them when we need them.

The ResultSet class
-------------------

ResultSet classes can be added optionally, overriding the default
[DBIx::Class::ResultSet](http://search.cpan.org/perldoc?DBIx::Class::ResultSet). These are useful for adding oft-used
searches as methods to a set of data, to keep them in the model layer
rather than in the calling code. One ResultSet class can be created
for each Result class in the Schema.

We will visit examples of these later.

## Making a database

If you're starting from scratch and don't actually have a database
yet, run the following now to create one:

    perl -MMyBlog::Schema -le'my $schema = MyBlog::Schema->connect("dbi:SQLite:test.db"); $schema->deploy();'

Installing [DBIx::Class](http://search.cpan.org/perldoc?DBIx::Class) will have also installed [DBD::SQLite](http://search.cpan.org/perldoc?DBD::SQLite), a
small one-file database which is useful for testing and portable
databases for applications.

We will discuss [deployment](http://search.cpan.org/perldoc?DBIx::Class::Tutorial::Deployment) more
at length later when talking about how to change your schema without
having to destroy your existing data.

CONCLUSIONS
-----------

You now have a couple of well-defined Result classes we can use to
actually create and query some data from your database.

Next Chapter
------------

[Creating and finding users](/tutorials/dbix-class/chapter/GettingStarted)

# AUTHOR

Jess Robinson <castaway@desert-island.me.uk>
