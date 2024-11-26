# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
Project.destroy_all
User.destroy_all

# Crée un utilisateur
user = User.create!(email: "carapuce@test.com", username: 'Carapuce', password: 'carapuce')

# Crée 5 projets avec des noms uniques, associés à cet utilisateur
5.times do |i|
  Project.create!(
    name: "Projet #{i + 1}",
    user: user,
    location: "Paris",
    status: false,
    notes: "note 1",
    starting_date: Date.parse("2024-11-26"),
    end_date: Date.parse("2025-03-12"),
    description: "Un projet super"
  )
end

puts "5 projets créés avec succès pour l'utilisateur #{user.username} !"
