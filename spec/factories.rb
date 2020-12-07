FactoryBot.define do

  isadmin = [true,false]

  factory :employee, class: Employee do
    name {Faker::Name.first_name}
    surname {Faker::Name.last_name}
    admin {isadmin.sample}
    sequence(:username) {|n| "employee#{n}"}
  end

  factory :client, class: Client do
    name {Faker::Name.first_name}
    surname {Faker::Name.last_name}
    sequence(:username) {|n| "client#{n}"}
  end

  factory :user, class: User do
    email {Faker::Name.last_name}
    password {Faker::Superhero.name}
    password_confirmation {password}
  end

  factory :random_notification, class: Notification do
    message {Faker::Lorem.paragraph}
  end
end
