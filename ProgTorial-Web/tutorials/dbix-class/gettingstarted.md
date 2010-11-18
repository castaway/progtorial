First steps in creating and retrieving database entries
=======================================================

[% contents %][%# See L<DBIx::Class::Tutorial/CONTENTS> %]

Chapter summary
---------------

Now that you have created some classes to describe the MyBlog
database, we can create some rows in it to work with.

Creating a user
---------------

So you're collecting information about a new user of your app in some
registration form, and you need to commit that to the database so you
can verify them later when they login.

### First, a schema object

To connect your schema to a specific database, you call the C<connect>
method on your schema class, it will return you a schema object.

  use MyBlog::Schema;
  my $schema = MyBlog::Schema->connect('dbi:SQLite:/usr/src/myapp/blogs.db');

The schema object is used for accessing all your database tables,
creating, editing, deleting and searching rows. 

NB: Do B<not> let the schema object go out of scope while you are still
using row or resultset objects or they will fail, DBIx::Class does not
keep a reference to the schema object internally.

For other ways to pass the connection info to C<connect>, see
L<DBIx::Class::Schema/connect>.

### Then, a Users ResultSet

Each I<Result class> we created for a table in
L<DBIx::Class::Tutorial::FromScratch> is loaded by the I<Schema> class
when you C<use> it. To deal with a particular table, you first
retrieve the L<DBIx::Class::ResultSet> associated with that table using the name of
the I<Result class>. To get one for the I<users> table, we do:

  my $users_rs = $schema->resultset('User');

### Now create the user

Having fetched some new user data from our potential user, we want to
create the new user row and write it straight to the database, so we
use the C<create> method on our I<ResultSet> object.

  my $newuser = $users_rs->create(
    {
       realname => $realname,
       username => $username,
       password => $password,
       email    => $email,
    }
  );

(NB: for better security, you should probably be encrypting the stored
passwords, with something like L<Digest::SHA1>, not storing them in
plain text!)

Notice we skipped the C<id> column in the create. The database will be
supplying that value automatically for new rows. DBIx::Class assumes
this for primary key fields, and will fetch the value of that field
from the database backend for us, if we don't supply it. Create is
documented at L<DBIx::Class::ResultSet/create>.

### Getting data from the user object

So we can ask our C<$newuser> object, which is now a
L<DBIx::Class::Row>, for the id of the new user row. Since this is a
brand new database, it's probably I<1>.

  print $newuser->id();
  
Having created the new user, you'll probably want to use it in some
more code, for example to display a confirmation message saying you
have sent them an activation email. Or extract the email address to
send that email to.

Like the C<id> accessor method, all the columns we described in the
I<Result class> are available to retrieve the user data, so to fetch
the email address we can just use this in the code:

  my $eaddress = $newuser->email();

Finding the user again
----------------------

Sometime later, many users have signed up to your application. Now one
of them has returned and wishes to login, since we only allow users to
create blog posts or comments when they are logged in to the
application.

### Using a unique value

To login you ask the user for their I<username> and I<password>, and
look up the user in the database using the C<username_idx> unique
constraint we added, using the same C<$users_rs> I<ResultSet> as
before.

  my $user = $users_rs->find(
    {
      username => $username,
    },
    {
      key => 'username_idx',
    }
  );

Since we specified that I<username> was a unique column, this can
return exactly one result, or none at all. If the user mistyped their
username in the login form, the result will be I<undef>, so we can
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

This C<$user> object is just like the C<$newuser> object we got when
we created the user originally, it's another instance with the same
data; the I<email> accessor can be used just as before:

  print $user->email();

### Using search criteria

Eventually, you might want to add functionality to your application to
allow your users to search for each other (crazy, I know). So now
you'll need to be able to take a string that represents part of a name
(or other piece of info) and look for all the matching users.

You get the user to enter the first part of the name of the user they
are looking for, and run a C<search> on the I<users> table:

  my $userlist = $user_rs->search({ 
    realname => { like => $searchstring . '%' }
  });

NB: We're using an SQL keyword I<LIKE> here, which does a search using
wildcards, I<%> means any number of characters, I<_> can be used to
match any one character.

NB2: In some database systems, LIKE matches case-insensitively, and in
some it doesn't, look it up in your database manual to confirm.

The result of a search is not a single row, but a set of rows, a
I<ResultSet>. The resultset can be iterated over to retrieve all the
results and output them:

  while( my $user = $userlist->next() ) {
    print "Search matched user: ", $user->realname, "\n";
  }

NB: In list context C<search()> returns a list of the matching row
objects, not a I<ResultSet>.

The resultset keeps track of which row you looked at last, so C<next>
always returns the next one, starting with the first, and returns
undef when it gets to the end.

Note that C<next> returns a single I<DBIx::Class::Row> object, just
like C<find> did.

We didn't specify a sort order, so the rows will come out in a
random-looking order. If we want to sort them, we can add a
C<order_by> attribute to the search:

  my $userlist = $user_rs->search({ 
    realname => { like => $searchstring . '%' }
  }, {
    order_by => 'realname',
  });

For more information on the search method, look in
L<DBIx::Class::ResultSet/search>. The possible attributes like
C<order_by> are listed in L<DBIx::Class::ResultSet/ATTRIBUTES>.
  
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


