puts "Cleaning..."
Mood.destroy_all
Quest.destroy_all
User.delete_all

puts "Creating Users"
user_renata = User.create!(username: "Renata", email: "renata@renata.com", password: "password", total_xp: 20)
user_ninon = User.create!(username: "Ninon", email: "ninon@ninon.com", password: "password", total_xp: 10)
user_lucille = User.create!(username: "Lucille", email: "lucille@lucille.com", password: "password", total_xp: 50)
user_carlo = User.create!(username: "Carlo", email: "carlo@carlo.com", password: "password", total_xp: 30)
user_frank = User.create!(username: "Frank", email: "frank@frank.com", password: "password", total_xp: 40)

puts "Created first Users: #{User.all}"

puts "Creating Quests"
Quest.create!(user_id: user_renata.id, name: "Shop groceries", description: "Get to Supermarket, don't forget Water!", daily: false, completed: false, xp: 10, date: Date.today )
Quest.create!(user_id: user_ninon.id, name: "Clean the desks", description: "Get rid of dust, then use Soap", daily: false, completed: false, xp: 10, date: Date.today )
Quest.create!(user_id: user_lucille.id, name: "Walk the dog", description: "Walk the woof woof through the forest.", daily: true, completed: false, xp: 50, date: Date.today )
Quest.create!(user_id: user_carlo.id, name: "Do some gardening", description: "Lawn mowing and cutting plants.", daily: false, completed: false, xp: 50, date: Date.today )
Quest.create!(user_id: user_frank.id, name: "Do some cleaning", description: "Clean the living room", daily: false, completed: false, xp: 40, date: Date.today )
puts "Created first Users Quest: #{Quest.all}."

puts "Finished seeding with #{User.count} Users, #{Mood.count} Usermoods and #{Quest.count} Quests."
