# README

This is an implementation of a b2b notication api.

An admin creates text messages and assigns them to clients.
Clients may then pick up these text messages.
Clients may also pick up a content and a few simple stats on their investment portfolio.

## Ruby version
I think anything recent should work, I have not knowingly used any cutting edge or fancy features.

The standard ruby and rails install via apt on Ubunutu 20.4 was used.
As of now that is:  
  * rails: 5.2.3  
  * ruby : 2.7.0p0  

## System dependencies
Requires python3, pandas and numpy

As above, I used the standard Ubuntu 20.4 versions  
  * Python: 3.8.5  
  * pandas: 0.25.3  
  * numpy : 1.17.4  

## Database creation
The project is set up with sqlite for development and test
For production it is set up with postgres
You will need to create the database as per config/database.yml - or modify the config
rails db:migrate RAILS_ENV=$env
rails db:seed RAILS_ENV=$env

## How to run the test suite
The rspec tests may be run with:
bundle exec rspec spec

There is also a manual test tool:
./test/curses_query_tool.rb
Controls:  
  *   W:   up  
  *   S:   down  
  *   spc: enter  

## Choice of gems:
### pycall:
I saw this recommended in data science slides, for performance. Vs the ruby alternatives such as Daku.
https://fr.slideshare.net/urubatan/data-science-in-ruby-is-it-possible-is-it-fast-should-we-use-it-169709579
While performance is not so much of an issue in this case, I thought it made sense to start with the current best option.
Possibly over time Daku will catch up and then be the preferred option.

### jwt/simple_command/bcrypt:
These were recommended in a jwt authentication tutorial I found at pluralsight, a good training provider that we have used:
http://www.pluralsight.com/guides/token-based-authentication-with-ruby-on-rails-5-api

### activerecord-insert_many
High performance insertion using active record. Adding one at a time is very slow. 
I starting off using sequel.import, but the rails integration of config with active record does not work for free.

### rspec/faker
Test tool recommendation from a rails experienced friend

