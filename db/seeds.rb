# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

# See seeds/environment for an environment specific seed
load(Rails.root.join( 'db', 'seeds', "#{Rails.env.downcase}.rb"))

# Common seeding goes here

