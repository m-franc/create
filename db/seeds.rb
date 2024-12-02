# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Clean up existing data
Conversation.destroy_all
User.destroy_all
Project.destroy_all

# Create users
owner = User.create!(
  email: "owner@test.com",
  username: 'Owner',
  password: 'carapuce'
)

member = User.create!(
  email: "member@test.com",
  username: 'Member',
  password: 'carapuce'
)

# Theater projects data
theater_projects = [
  {
    name: "Le Misanthrope",
    description: "Modern adaptation of Molière's masterpiece, exploring themes of honesty and social hypocrisy in contemporary society",
    location: "Théâtre de la Ville, Paris",
    starting_date: Date.new(2024, 3, 15),
    end_date: Date.new(2024, 6, 30),
    tasks: [
      { name: "Costume Design Review", description: "Review and finalize costume designs for main characters" },
      { name: "Act 1 Rehearsal", description: "Focus on the opening scene dynamics and character relationships" }
    ]
  },
  {
    name: "Swan Lake Ballet",
    description: "Contemporary reinterpretation of Tchaikovsky's classic ballet with modern choreography",
    location: "Opéra Garnier",
    starting_date: Date.new(2024, 4, 1),
    end_date: Date.new(2024, 8, 15),
    tasks: [
      { name: "Dance Rehearsal", description: "Practice the transformed swan sequence" },
      { name: "Lighting Design", description: "Finalize lighting cues for lake scenes" }
    ]
  },
  {
    name: "Carmen",
    description: "New production of Bizet's opera set in modern-day Seville",
    location: "Opéra Bastille",
    starting_date: Date.new(2024, 5, 10),
    end_date: Date.new(2024, 9, 20),
    tasks: [
      { name: "Vocal Rehearsal", description: "Habanera aria practice with lead soprano" },
      { name: "Set Construction", description: "Build and paint the tavern scene backdrop" }
    ]
  },
  {
    name: "A Midsummer Night's Dream",
    description: "Immersive theater experience of Shakespeare's magical comedy in a forest setting",
    location: "Bois de Boulogne",
    starting_date: Date.new(2024, 6, 1),
    end_date: Date.new(2024, 7, 31),
    tasks: [
      { name: "Fairy Choreography", description: "Rehearse aerial sequences for fairy scenes" },
      { name: "Props Creation", description: "Create enchanted forest props and magical elements" }
    ]
  },
  {
    name: "The Phantom of the Opera",
    description: "25th anniversary production with enhanced special effects and new orchestrations",
    location: "Théâtre Mogador",
    starting_date: Date.new(2024, 9, 1),
    end_date: Date.new(2024, 12, 31),
    tasks: [
      { name: "Technical Rehearsal", description: "Test chandelier mechanism and safety measures" },
      { name: "Music Rehearsal", description: "Orchestra practice for new arrangements" }
    ]
  }
]

# Create projects and tasks
theater_projects.each do |project_data|
  project = Project.create!(
    name: project_data[:name],
    description: project_data[:description],
    location: project_data[:location],
    starting_date: project_data[:starting_date],
    end_date: project_data[:end_date],
    user: owner,
    status: ["En cours", "En attente", "Terminé"].sample
  )

  # Add member to each project
  ProjectUser.create!(project: project, user: member, status: "0")

  # Create tasks for the project
  project_data[:tasks].each do |task_data|
    Task.create!(
      name: task_data[:name],
      description: task_data[:description],
      project: project,
      user: [member, owner].sample,
      status: ["to-do", "doing", "done"].sample,
      priority: ["low", "medium", "high"].sample,
      deadline: project.end_date - rand(1..30).days
    )
  end
end

puts "Created 5 theater projects with tasks and assigned members!"
