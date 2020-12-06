FactoryBot.define do
  factory :random_message, class: String do
    Faker::Lorem.paragraph
  end
end
