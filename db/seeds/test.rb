# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Employee.create({ name: 'Mark', surname: 'Watson', username: 'markw', admin: true })
Employee.create({ name: 'John', surname: 'Smith', username: 'johns', admin: false })
User.create!(email: 'markw@yova.ch', password: 'foo', password_confirmation: 'foo', name: 'markw')
User.create!(email: 'johns@yova.ch', password: 'bar', password_confirmation: 'bar', name: 'johns')
User.create!(email: 'mrgates@microsoft.com', password: 'password1', password_confirmation: 'password1', name: 'bgates')
User.create!(email: 'zucker@facebook.com', password: 'password2', password_confirmation: 'password2',
             name: 'mzuckerberg')
User.create!(email: 'gorilla@lehman.com', password: 'password3', password_confirmation: 'password3', name: 'dfuld')
@cl = Client.create({ name: 'Bill', surname: 'Gates', username: 'bgates' })
Portfolio.create({ name: 'my first portfolio', client: @cl })
Portfolio.create({ name: 'my second portfolio', client: @cl })
@cl = Client.create({ name: 'Mark', surname: 'Zuckerberg', username: 'mzuckerberg' })
Portfolio.create({ name: 'save the world', client: @cl })
@cl = Client.create({ name: 'Dick', surname: 'Fuld', username: 'dfuld' })

