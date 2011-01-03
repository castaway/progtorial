First steps in creating and retrieving database entries
=======================================================

[% contents %][%# See L<DBIx::Class::Tutorial/CONTENTS> %]

Chapter summary
---------------

This chapter explains how to use your DBIx::Class Result classes and
Schema to enter data into the database and retrieve it as perl
objects.

We are working with the `MyBlog` schema described in the
[previous chapter](/tutorials/dbix-class/chapter/FromScratch). We'll
also use [DBD::SQLite](http://search.cpan.org/dist/DBD-SQLite) which
is a database in a single file, and simple to use.

Creating a user entry
---------------------

In our imaginary blog software, we're going to allow multiple users to
sign up to write blog posts, or just comments. The first thing they
will need to do is create a new user, which we will store in the
database.

Working with the database through the DBIx::Class modules requires
several steps:

### First, a schema object

To connect your schema to a specific database, you call the `connect`
method on your schema class, it will return you a schema object.

    use MyBlog::Schema;
    my $schema = MyBlog::Schema->connect('dbi:SQLite:/usr/src/myapp/blogs.db');

The schema object is used for accessing all your database tables,
creating, editing, deleting and searching rows. 

NB: Do **not** let the schema object go out of scope while you are still
using row or resultset objects or they will fail, DBIx::Class does not
keep a reference to the schema object internally.

For other ways to pass the connection info to `connect`, see
http://search.cpan.org/perldoc?DBIx::Class::Schema#connect.

### Then, a Users ResultSet object

Each _Result class_ we created for a table in
[Chapter 1 - Describing your database]((/tutorials/dbix-class/chapter/FromScratch)
is loaded by the _Schema class_ when you `use` it. To deal with a
particular table, you first retrieve the
[ResultSet object](http://search.cpan.org/perldoc?DBIx::Class::ResultSet)
associated with that table using the name of the _Result class_. To
get one for the _users_ table, we do:

    my $users_rs = $schema->resultset('User');

NB: To see which classes your Schema actually loaded, you can call the
`sources` method on your `$schema` object, it returns a list of name strings.

### Now create the user row

Having fetched some new user data from our potential user, we want to
create the new user row and write it straight to the database, so we
use the `create` method on our _ResultSet_ object.

    my $newuser = $users_rs->create(
    {
       realname => $realname,
       username => $username,
       password => $password,
       email    => $email,
    }
    );

NB: We're being lazy here and storing the passwords in plain text, for
better security, you should probably be encrypting the stored
passwords, with something like L<Digest::SHA1>.

Notice we skipped the `id` column in the create. The database will be
supplying that value automatically for new rows. DBIx::Class assumes
this for primary key fields, and will fetch the value of that field
from the database backend for us, if we don't supply it. Create is
documented at http://search.cpan.org/perldoc?DBIx::Class::ResultSet#create.

#### Mini exercise: Store a user

Write a small script to store a row in the user table, using the
information you've learned so far. The username of the user should be
"fredbloggs".

You can assume there will be a variable named `$db_filename` in scope
which can be used for the SQLite database filename.

<a name="insert-user-data"></a>

[% include_exercise('insert-user-data') %]

### Getting data from the user object

The database should have inserted the id of the new user row for us,
we can request the value using the `id` accessor on our `$newuser`
object, which is now a http://search.cpan.org/perldoc?DBIx::Class::Row
instance. Since this is a brand new database, it's probably _1_.

    print $newuser->id();
  
Having created the new user, you'll probably want to use it in some
more code, for example to display a confirmation message saying you
have sent them an activation email. Or extract the email address to
send that email to.

Like the `id` accessor method, all the columns we described in the
_Result class_ are available to retrieve the user data, so to fetch
the email address we can just use this in the code:

    my $eaddress = $newuser->email();

Finding the user again
----------------------

Sometime later, many users have signed up to your application. Now one
of them has returned and wishes to login, since we only allow users to
create blog posts or comments when they are logged in to the
application.

### Using a unique value

To login you ask the user for their _username_ and _password_, and
look up the user in the database using the `username_idx` unique
constraint we added, using the same `$users_rs` _ResultSet_ as
before.

    my $user = $users_rs->find(
    {
      username => $username,
    },
    {
      key => 'username_idx',
    }
    );

Since we specified that _username_ was a unique column, this can
return exactly one result, or none at all. If the user mistyped their
username in the login form, the result will be `undef`, so we can
tell the user they failed:

    if(!$user) {
      print "No such user $username\n";
    }

Then of course we should compare the password they typed in with the
stored one, don't forget to encrypt the one from the login form before
you compare it if you are using encryption.

    if($user->password() eq $password) {
      print "Found you, $username!\n";
    }

This `$user` object is just like the `$newuser` object we got when
we created the user originally, it's another instance with the same
data; the _email_ accessor can be used just as before:

    print $user->email();

#### Mini exercise: Finding a user

Write a sub named `get_fred` which returns a user object representing
the fredbloggs user we created earlier.

You can assume there will be a variable named `$db_filename` in scope
which can be used for the SQLite database filename.

<a name="find-user-data"></a>

[% include_exercise('find-user-data') %]

### Searching on partial data

Eventually, you might want to add functionality to your application to
allow your users to search for each other (crazy, I know). So now
you'll need to be able to take a string that represents part of a name
(or other piece of info) and look for all the matching users.

You get the user to enter the first part of the name of the user they
are looking for, and run a `search` on the _users_ table:

    my $userlist = $user_rs->search({ 
      realname => { like => $searchstring . '%' }
    });

NB: We're using an SQL keyword _LIKE_ here, which does a search using
wildcards, _%_ means any number of characters, ___ can be used to
match any one character.

NB2: In some database systems, LIKE matches case-insensitively, and in
some it doesn't, look it up in your database manual to confirm.

The result of a search is not a single row, but a set of rows, a
_ResultSet_. The resultset can be iterated over to retrieve all the
results and output them:

    while( my $user = $userlist->next() ) {
      print "Search matched user: ", $user->realname, "\n";
    }

NB: In list context `search()` returns a list of the matching row
objects, not a _ResultSet_.

The resultset keeps track of which row you looked at last, so `next`
always returns the next one, starting with the first, and returns
undef when it gets to the end.

Note that `next` returns a single _DBIx::Class::Row_ object, just
like `find` does.

We didn't specify a sort order, so the rows will come out in a
random-looking order. If we want to sort them, we can add a
`order_by` attribute to the search:

    my $userlist = $user_rs->search({ 
      realname => { like => $searchstring . '%' }
    }, {
      order_by => 'realname',
    });

For more information on the search method, look in
http://search.cpan.org/perldoc?DBIx::Class::ResultSet#search. The possible attributes like
`order_by` are listed in [the attributes section](http://search.cpan.org/perldoc?DBIx::Class::ResultSet#ATTRIBUTES).

#### Mini exercise: Find all the Freds

Write a sub called `fred_search` which returns a list of all the
usernames of users whose _realname_ begins with "Fred";

You can assume there will be a variable named `$db_filename` in scope
which can be used for the SQLite database filename.

<a name="fred-search"></a>

[% include_exercise('fred-search') %]

  
Updating the user
-----------------

Now that we've found the user again, we can let them change their
email address, or their password. We can easily show them the existing
values, using the I<accessors>, and retrieve new values to update the
database with.

To set those values, we just call the accessors on the C<$user> object
and call C<update>:

  $user->email($new_email_address);
  $user->password($new_password);

  $user->update();

NB: Don't forget to rehash the password, and present the user with two
password fields to make sure they don't mistype it. 

NB2: Verify the new email address too, by sending them an email they
must respond to.

The C<update> method issues an SQL I<UPDATE> statement, setting the
new column values, using the I<primary key> to match the row.

The update is only done if any of the column values have changed since
the last update or creation of the object.

EXAMPLE
=======

This example covers all the techniques outlined above, in a straight
forward command-line based program. To prompt the user for
information, we're using L<Term::Prompt>. Install it using B<cpan
Term::Prompt> in your console.

F</examples/manipulating_a_user.pl>

CONCLUSIONS
===========

You can now create new rows in the database tables, find them again
and change their values.

EXERCISES
=========

WHERE TO GO NEXT
================

[Enhancing users and making posts](/tutorials/dbix-class/AddingFunctionality)

=head1 TODO

Patches and suggestions welcome.

=head1 AUTHOR

Jess Robinson <castaway@desert-island.me.uk>


