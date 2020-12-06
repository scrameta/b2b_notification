# README

This is an implementation of a b2b notication api.

An admin creates text messages and assigns them to clients.
Clients may then pick up these text messages.
Clients may also pick up a content and a few simple status on their investment portfolio.

* Ruby version
Anything recent should work, it was built and tested with 2.7.0. The standard install on Ubunutu 20.4.

* System dependencies
Required python3, pandas and numpy

* Database creation
TODO: postgres..

* Database initialization
Execute the shell script ./runme
This runs the usual migrate and see, followed by some custom seeding

* How to run the test suite
TODO

* Choice of gems:
pycall:
I saw this recommended in data science slides, for performance. Vs the ruby alternatives such as Daku.
https://fr.slideshare.net/urubatan/data-science-in-ruby-is-it-possible-is-it-fast-should-we-use-it-169709579
While performance is not so much of an issue in this case, I thought it made sense to start with the current best option.
Possibly over time Daku will catch up and then be the preferred option.

jwt/simple_command/bcrypt:
These were recommended in a jwt authentication tutorial I found at pluralsight, a good training provider that we have used:
http://www.pluralsight.com/guides/token-based-authentication-with-ruby-on-rails-5-api




