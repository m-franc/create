namespace :db do
  desc 'Force reset database: closes connections, drops, creates, migrates, and seeds'
  task force_reset: :environment do
    database = Rails.configuration.database_configuration[Rails.env]["database"]
    
    # Close all connections and drop database using psql
    puts "Closing all database connections and dropping database..."
    system(%(psql -d postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '#{database}';"))
    system(%(psql -d postgres -c 'DROP DATABASE IF EXISTS #{database}';))
    
    # Create, migrate and seed
    puts "Creating database..."
    system("rails db:create")
    puts "Running migrations..."
    system("rails db:migrate")
    puts "Seeding database..."
    system("rails db:seed")
    
    puts "Database reset complete!"
  end
end
