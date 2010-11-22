Simple Perl tutorial demo
=========================

This is the demo tutorial, play with the exercises to see how this
stuff works out in practice.

Each tutorial has a number of exercises that allow you to enter code
to solve a problem. The code you enter will be run against a [Test
Suite]() to determine if it solves the stated problem.  If it doesn't,
we'll give you some information about what went wrong, and let you fix
it.  You can also click for more hints about what the problem might be,
if you need it.


Here's a simple sample exercise: 

Write a perl function named "add" which returns the sum of its arguments.

[% include_exercise('add_function') %]

---

Here's a series of exercises that build on each-other.

Part the First
--------------

Write a function called `first_25_primes` that returns the first 25
prime numbers.  

    sub first_25_primes {
      return (2, 3, 5, ...);
    }

[% include_exercise('prime_function_simple') %]

---

Part the Second
---------------

Now, do it again, without mentioning the actual prime numbers, you cheater.

[% include_exercise('prime_function_noliteral') %]

---

Part the Third
--------------

Make it execute in less then 10 seconds.

[% include_exercise('prime_function_fast') %]

---
