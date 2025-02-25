require 'open-uri'

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
puts "Cleaning up database..."
Message.destroy_all
ConversationUser.destroy_all
Conversation.destroy_all
Note.destroy_all
Task.destroy_all
ProjectUser.destroy_all
Project.destroy_all
User.destroy_all

# Create Users
puts "Creating users..."

users_data = [
  { first_name: "Gautier", last_name: "David", email: "gautier.david@theater.com", username: "gautier_d", job: "Theater Director", password: "password123" },
  { first_name: "Nicolas", last_name: "Delfour", email: "nicolas.delfour@theater.com", username: "nicolas_d", job: "Stage Manager", password: "password123" },
  { first_name: "Diane", last_name: "Johnston", email: "diane.johnston@theater.com", username: "diane_j", job: "Costume Designer", password: "password123" },
  { first_name: "Louise", last_name: "Ouldhaddi", email: "louise.ouldhaddi@theater.com", username: "louise_o", job: "Lighting Designer", password: "password123" },
  { first_name: "Thomas", last_name: "Desmoulins", email: "thomas.desmoulins@theater.com", username: "thomas_d", job: "Sound Engineer", password: "password123" },
  { first_name: "Mathieu", last_name: "Trancoso", email: "mathieu.trancoso@theater.com", username: "mathieu_t", job: "Set Designer", password: "password123" },
  { first_name: "Nicolas", last_name: "Bischoff", email: "nicolas.bischoff@theater.com", username: "nicolas_b", job: "Production Manager", password: "password123" },
  { first_name: "Julien", last_name: "Da Silva", email: "julien.dasilva@theater.com", username: "julien_d", job: "Technical Director", password: "password123" },
  { first_name: "Robin", last_name: "Rettien", email: "robin.rettien@theater.com", username: "robin_r", job: "Props Master", password: "password123" },
  { first_name: "Pierre", last_name: "Penhard", email: "pierre.penhard@theater.com", username: "pierre_p", job: "Scenic Artist", password: "password123" },
  { first_name: "Tristan", last_name: "Monteiro", email: "tristan.monteiro@theater.com", username: "tristan_m", job: "Stage Carpenter", password: "password123" },
  { first_name: "Paul", last_name: "Portier", email: "paul.portier@theater.com", username: "paul_p", job: "Lighting Technician", password: "password123" },
  { first_name: "Timothée", last_name: "Régis", email: "timothee.regis@theater.com", username: "timothee_r", job: "Sound Technician", password: "password123" },
  { first_name: "Adil", last_name: "Sari", email: "adil.sari@theater.com", username: "adil_s", job: "Wardrobe Supervisor", password: "password123" },
  { first_name: "Zena", last_name: "El Kurdi", email: "zena.elkurdi@theater.com", username: "zena_e", job: "Makeup Artist", password: "password123" },
  { first_name: "Clothilde", last_name: "Scache", email: "clothilde.scache@theater.com", username: "clothilde_s", job: "Choreographer", password: "password123" },
  { first_name: "Rayan", last_name: "Anser", email: "rayan.anser@theater.com", username: "rayan_a", job: "Production Assistant", password: "password123" },
  { first_name: "Manon", last_name: "Roussel", email: "manon.roussel@theater.com", username: "manon_r", job: "Stage Hand", password: "password123" },
  { first_name: "Mathias", last_name: "Durand", email: "mathias.durand@theater.com", username: "mathias_d", job: "Front of House Manager", password: "password123" },
  { first_name: "Guest", last_name: "Guest", email: "guest@theater.com", username: "guest", job: "Guest", password: "guest123" }
]

users = users_data.map do |user_data|
  User.create!(
    email: user_data[:email],
    password: user_data[:password],
    first_name: user_data[:first_name],
    last_name: user_data[:last_name],
    username: user_data[:username],
    job: user_data[:job]
  )
end

puts "Created #{users.length} users!"

# Project images mapping
CLOUDINARY_IMAGES = {
  "Les Misérables - Modern Adaptation" => "https://res.cloudinary.com/dj2sxqm1w/image/upload/v1733216788/Les_Mise%CC%81rables_-_Modern_Adaptation_l1fxfl.jpg",
  "A Midsummer Night's Dream" => "https://res.cloudinary.com/dj2sxqm1w/image/upload/v1733216786/A_Midsummer_Night_s_Dream_gdsgfd.webp",
  "Cyrano Digital" => "https://res.cloudinary.com/dj2sxqm1w/image/upload/v1733216787/Cyrano_Digital_gpzai9.webp",
  "The Imaginary Invalid Reimagined" => "https://res.cloudinary.com/dj2sxqm1w/image/upload/v1733216789/The_Imaginary_Invalid_Reimagined_jy8zha.jpg",
  "Don Juan - Electric Nights" => "https://res.cloudinary.com/dj2sxqm1w/image/upload/v1733216787/Don_Juan_-_Electric_Nights_qidgbu.jpg",
  "Antigone of the Streets" => "https://res.cloudinary.com/dj2sxqm1w/image/upload/v1733216787/Antigone_of_the_Streets_jxuuhe.jpg",
  "Three Sisters Live" => "https://res.cloudinary.com/dj2sxqm1w/image/upload/v1733216790/Three_Sisters_Live_floiuu.jpg",
  "Romeo and Juliet - Silent Disco" => "https://res.cloudinary.com/dj2sxqm1w/image/upload/v1733216789/Romeo_and_Juliet_-_Silent_Disco_a0dw73.jpg",
  "The Miser 2.0" => "https://res.cloudinary.com/dj2sxqm1w/image/upload/v1733216790/The_Miser_znp9eq.jpg",
  "Phaedra VR" => "https://res.cloudinary.com/dj2sxqm1w/image/upload/v1733216788/Phaedra_VR_ubvq84.webp"
}

# Theater projects data
projects_data = [
  {
    name: "Les Misérables - Modern Adaptation",
    description: "A contemporary adaptation of Victor Hugo's masterpiece, set in today's urban landscape",
    location: "Royal Theatre, London",
    starting_date: Date.today + 2.months,
    end_date: Date.today + 2.months + 2.weeks,
    tasks: [
      { name: "Main roles casting", due_date: Date.today + 14.days, status: "in_progress" },
      { name: "Act 1 rehearsals", due_date: Date.today + 30.days, status: "pending" },
      { name: "Costume design", due_date: Date.today + 7.days, status: "completed" }
    ]
  },
  {
    name: "A Midsummer Night's Dream",
    description: "Dreamlike staging of Shakespeare's play in an urban enchanted forest setting",
    location: "Central Park Amphitheater, New York",
    starting_date: Date.today + 3.months,
    end_date: Date.today + 3.months + 10.days,
    tasks: [
      { name: "Set design", due_date: Date.today + 10.days, status: "in_progress" },
      { name: "Fairy choreography", due_date: Date.today + 20.days, status: "pending" },
      { name: "Music composition", due_date: Date.today + 5.days, status: "completed" }
    ]
  },
  {
    name: "Cyrano Digital",
    description: "Modern version of Cyrano de Bergerac, set in the world of social media",
    location: "Sydney Opera House Studio",
    starting_date: Date.today + 1.month,
    end_date: Date.today + 1.month + 3.weeks,
    tasks: [
      { name: "Script adaptation", due_date: Date.today + 15.days, status: "completed" },
      { name: "Video production", due_date: Date.today + 25.days, status: "in_progress" },
      { name: "Full rehearsal", due_date: Date.today + 40.days, status: "pending" }
    ]
  },
  {
    name: "The Imaginary Invalid Reimagined",
    description: "Interactive and comedic adaptation of Molière's classic",
    location: "Edinburgh Fringe Festival",
    starting_date: Date.today + 4.months,
    end_date: Date.today + 4.months + 1.week,
    tasks: [
      { name: "Improv rehearsals", due_date: Date.today + 12.days, status: "in_progress" },
      { name: "Period costumes", due_date: Date.today + 22.days, status: "pending" },
      { name: "Props collection", due_date: Date.today + 8.days, status: "completed" }
    ]
  },
  {
    name: "Don Juan - Electric Nights",
    description: "Reinterpretation of Don Juan in the modern nightclub scene",
    location: "Warehouse Theatre, Berlin",
    starting_date: Date.today + 2.months + 2.weeks,
    end_date: Date.today + 3.months,
    tasks: [
      { name: "Soundtrack creation", due_date: Date.today + 18.days, status: "in_progress" },
      { name: "Lighting design", due_date: Date.today + 28.days, status: "pending" },
      { name: "Stage design", due_date: Date.today + 9.days, status: "completed" }
    ]
  },
  {
    name: "Antigone of the Streets",
    description: "Contemporary adaptation of Antigone set in an urban environment",
    location: "Chicago Cultural Center",
    starting_date: Date.today + 5.months,
    end_date: Date.today + 5.months + 2.weeks,
    tasks: [
      { name: "Local casting", due_date: Date.today + 20.days, status: "completed" },
      { name: "Rehearsals", due_date: Date.today + 35.days, status: "in_progress" },
      { name: "Urban costumes", due_date: Date.today + 15.days, status: "pending" }
    ]
  },
  {
    name: "Three Sisters Live",
    description: "Modern Chekhov production incorporating live social media elements",
    location: "Digital Arts Center, Tokyo",
    starting_date: Date.today + 3.months + 1.week,
    end_date: Date.today + 3.months + 3.weeks,
    tasks: [
      { name: "Technical tests", due_date: Date.today + 16.days, status: "in_progress" },
      { name: "Dress rehearsal", due_date: Date.today + 26.days, status: "pending" },
      { name: "Digital marketing", due_date: Date.today + 6.days, status: "completed" }
    ]
  },
  {
    name: "Romeo and Juliet - Silent Disco",
    description: "Immersive version where the audience wears wireless headphones",
    location: "Amsterdam Fringe Theater",
    starting_date: Date.today + 6.months,
    end_date: Date.today + 6.months + 10.days,
    tasks: [
      { name: "Sound check", due_date: Date.today + 21.days, status: "in_progress" },
      { name: "Dance rehearsal", due_date: Date.today + 31.days, status: "pending" },
      { name: "Audio mixing", due_date: Date.today + 11.days, status: "completed" }
    ]
  },
  {
    name: "The Miser 2.0",
    description: "Molière's The Miser set in the world of cryptocurrency",
    location: "Tech Hub Theatre, San Francisco",
    starting_date: Date.today + 4.months + 2.weeks,
    end_date: Date.today + 5.months,
    tasks: [
      { name: "Script adaptation", due_date: Date.today + 19.days, status: "completed" },
      { name: "Visual effects", due_date: Date.today + 29.days, status: "in_progress" },
      { name: "Tech props", due_date: Date.today + 13.days, status: "pending" }
    ]
  },
  {
    name: "Phaedra VR",
    description: "Hybrid theatrical experience mixing real and virtual reality",
    location: "Virtual Reality Center, Montreal",
    starting_date: Date.today + 7.months,
    end_date: Date.today + 7.months + 2.weeks,
    tasks: [
      { name: "VR development", due_date: Date.today + 25.days, status: "in_progress" },
      { name: "Technical rehearsal", due_date: Date.today + 40.days, status: "pending" },
      { name: "Costume fitting", due_date: Date.today + 10.days, status: "completed" }
    ]
  }
]

# Create projects and tasks
projects_data.each do |project_data|
  project = Project.create!(
    name: project_data[:name],
    description: project_data[:description],
    location: project_data[:location],
    starting_date: project_data[:starting_date],
    end_date: project_data[:end_date],
    user: users[rand(users.length)],
    status: ["In Progress", "Pending", "Completed"].sample
  )

  # Attach Cloudinary image if available
  if CLOUDINARY_IMAGES[project.name]
    begin
      file = URI.open(CLOUDINARY_IMAGES[project.name])
      project.image.attach(
        io: file,
        filename: "#{project.name.parameterize}.#{CLOUDINARY_IMAGES[project.name].split('.').last}"
      )
    rescue => e
      puts "Failed to attach image for #{project.name}: #{e.message}"
    end
  end

  # Add 2-3 random members to each project
  team_members = users.sample(rand(4..6))
  team_members.each do |member|
    ProjectUser.create!(project: project, user: member, status: "0") unless member == project.user
  end

  # Create 1-2 notes for each project
  note_contents = [
    { title: "Initial Production Meeting", content: "Key points discussed: budget allocation, timeline review, and creative vision for #{project.name}." },
    { title: "Technical Requirements", content: "Listed essential equipment and technical specifications needed for #{project.name}." },
    { title: "Casting Notes", content: "Key character descriptions and special requirements for #{project.name}." },
    { title: "Design Concepts", content: "Main visual themes and aesthetic direction for #{project.name}." },
    { title: "Rehearsal Schedule", content: "Preliminary rehearsal plan and important milestone dates for #{project.name}." }
  ]

  rand(1..2).times do
    note = note_contents.sample
    Note.create!(
      title: note[:title],
      content: note[:content],
      project: project,
      user: team_members.sample
    )
  end

  # Create tasks for the project
  project_data[:tasks].each do |task_data|
    Task.create!(
      name: task_data[:name],
      description: "#{task_data[:name]} - Detailed task for #{project.name} production",
      project: project,
      user: team_members.sample,
      deadline: task_data[:due_date]
    )
  end

  # Create 2-3 conversations for each project
  conversation_topics = [
    { name: "Production Planning", messages: [
      "Let's discuss our initial timeline and major milestones.",
      "We should prioritize casting and rehearsal schedule.",
      "Budget allocation needs to be finalized by next week."
    ]},
    { name: "Technical Setup", messages: [
      "Here's the list of technical requirements we'll need.",
      "The lighting setup needs special attention for the night scenes.",
      "Can we schedule a tech walkthrough next Tuesday?"
    ]},
    { name: "Creative Direction", messages: [
      "I'd like to propose some changes to the second act.",
      "The current design concept really captures our vision.",
      "Let's explore more contemporary elements in the staging."
    ]},
    { name: "Rehearsal Updates", messages: [
      "Today's rehearsal went really well, especially the opening scene.",
      "We might need extra time for the dance sequences.",
      "Can we schedule an additional run-through next week?"
    ]},
    { name: "Design and Costumes", messages: [
      "The costume sketches are ready for review.",
      "We need to adjust the color palette for Act 3.",
      "Props list has been updated with new requirements."
    ]}
  ]

  # Create 2-3 conversations per project
  rand(2..3).times do
    conversation_data = conversation_topics.sample
    conversation = Conversation.create!(
      name: "#{conversation_data[:name]} - #{project.name}",
      project: project
    )

    # Add 3-4 random team members to the conversation
    conversation_members = team_members.sample(rand(3..4))
    conversation_members << project.user unless conversation_members.include?(project.user)

    conversation_members.each do |member|
      ConversationUser.create!(conversation: conversation, user: member)
    end

    # Add messages to the conversation
    conversation_data[:messages].each do |content|
      Message.create!(
        content: content,
        conversation: conversation,
        user: conversation_members.sample,
        created_at: rand(project.starting_date..Date.today)
      )
    end
  end
end
puts "Created 10 theater projects with tasks, conversations, and assigned team members!"
