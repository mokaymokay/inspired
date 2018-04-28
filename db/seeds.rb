require 'faker'

User.create(first_name: "Kay", last_name: "Mok", email: "kay@example.com", password: "password", birthday: Time.at(rand * Time.now.to_i), username: "mokaymokay")
User.create(first_name: "Chris", last_name: "Holt", email: "cwh@example.com", password: "password", birthday: Time.at(rand * Time.now.to_i), username: "cwholt")

number_of_users = 5

(number_of_users - 2).times do
  first = Faker::Name.first_name
  last = Faker::Name.last_name
  User.create(first_name: first, last_name: last, email: Faker::Internet.email(first), password: "password", birthday: Time.at(rand * Time.now.to_i), username: Faker::Internet.user_name(first + ' ' + last , %w(. _ -)))
end

Post.create(quote: "there is nothing to explain: just be, and live.", author: "manzoni", user_id: 1)
Post.create(quote: "the only constant in a world of tremendous change is the swift passage of time.", author: "cixin liu", user_id: 2)

(number_of_users * 20).times do
  Post.create(quote: Faker::Lorem.sentence, author: Faker::Name.name_with_middle, user_id: 1 + rand(number_of_users))
end

Tag.create(content: "life")
Tag.create(content: "philosophy")
Tag.create(content: "time")
Tag.create(content: "love")
Tag.create(content: "loss")
Tag.create(content: "change")
Tag.create(content: "courage")

Tagging.create(post_id: 1, tag_id: 1)
Tagging.create(post_id: 1, tag_id: 2)
Tagging.create(post_id: 2, tag_id: 1)
Tagging.create(post_id: 2, tag_id: 3)

150.times do
  random_post_id = 1 + rand(number_of_users * 20)
  random_tag_id = 1 + rand(7)
  if Tagging.find_by(post_id: random_post_id, tag_id: random_tag_id) == nil
    Tagging.create(post_id: random_post_id, tag_id: random_tag_id)
  end
end
