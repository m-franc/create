# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
Conversation.destroy_all
User.destroy_all
Project.destroy_all

# Crée un utilisateur
owner = User.create!(email: "owner@test.com", username: 'Owner', password: 'carapuce')
member = User.create!(email: "member@test.com", username: 'Member', password: 'carapuce')

projects = []# Crée 5 projets avec des noms uniques, associés à cet utilisateur
5.times do |i|
  projects.push(Project.create!(name: "Projet #{i + 1}", description: "not blank", user: owner))
end

puts "5 projets créés avec succès pour l'utilisateur #{owner.username} !"

project_user = ProjectUser.create!(project: projects[0], user: member)

Task.create!(name: "repetition", description: "acte 4 scène 6", project: projects[0], user: [member, owner].sample)
Task.create!(name: "repetition", description: "acte 4 scène 7", project: projects[0], user: [member, owner].sample)
Task.create!(name: "repetition", description: "acte 4 scène 8", project: projects[0], user: [member, owner].sample)
Task.create!(name: "repetition", description: "acte 4 scène 9", project: projects[0], user: [member, owner].sample)
Task.create!(name: "repetition", description: "acte 4 scène 10", project: projects[0], user: [member, owner].sample)
Task.create!(name: "repetition", description: "acte 4 scène 11", project: projects[0], user: [member, owner].sample)
