puts "🌱 Seeding generic portfolio data..."

# In production we require explicit, strong admin credentials.
if Rails.env.production?
  admin_email = ENV.fetch('ADMIN_EMAIL') { raise 'ADMIN_EMAIL environment variable is required in production' }
  admin_password = ENV.fetch('ADMIN_PASSWORD') { raise 'ADMIN_PASSWORD environment variable is required in production' }

  if admin_password.length < 12
    raise 'ADMIN_PASSWORD must be at least 12 characters long in production'
  end
else
  # In non-production we fall back to convenient but clearly unsafe defaults.
  admin_email = ENV.fetch('ADMIN_EMAIL', 'admin@example.com')
  admin_password = ENV.fetch('ADMIN_PASSWORD', 'changeme123')
end

ActiveRecord::Base.transaction do
  # Create minimal admin user (required for authentication)
  user = User.find_or_initialize_by(email: admin_email)
  if user.new_record?
    user.password = admin_password
    user.password_confirmation = admin_password
    user.admin = true
    user.save!
    puts "👤 Created admin user: #{admin_email}"
  else
    puts "👤 Admin user already exists: #{admin_email}"
  end

  # Seed generic/reusable skills that developers can leverage
  # These are common technologies that many developers use
  generic_skills = [
    # Languages
    { name: "Python", proficiency_level: nil, years_of_experience: nil },
    { name: "JavaScript", proficiency_level: nil, years_of_experience: nil },
    { name: "TypeScript", proficiency_level: nil, years_of_experience: nil },
    { name: "Ruby", proficiency_level: nil, years_of_experience: nil },
    { name: "Java", proficiency_level: nil, years_of_experience: nil },
    { name: "Golang", proficiency_level: nil, years_of_experience: nil },
    { name: "Rust", proficiency_level: nil, years_of_experience: nil },
    { name: "SQL", proficiency_level: nil, years_of_experience: nil },
    # Frameworks
    { name: "Ruby on Rails", proficiency_level: nil, years_of_experience: nil },
    { name: "React", proficiency_level: nil, years_of_experience: nil },
    { name: "Next.js", proficiency_level: nil, years_of_experience: nil },
    { name: "Node.js", proficiency_level: nil, years_of_experience: nil },
    { name: "Django", proficiency_level: nil, years_of_experience: nil },
    { name: "Vue.js", proficiency_level: nil, years_of_experience: nil },
    { name: "Angular", proficiency_level: nil, years_of_experience: nil },
    # Databases
    { name: "PostgreSQL", proficiency_level: nil, years_of_experience: nil },
    { name: "MySQL", proficiency_level: nil, years_of_experience: nil },
    { name: "Redis", proficiency_level: nil, years_of_experience: nil },
    { name: "MongoDB", proficiency_level: nil, years_of_experience: nil },
    { name: "SQLite", proficiency_level: nil, years_of_experience: nil },
    # Cloud & DevOps
    { name: "AWS", proficiency_level: nil, years_of_experience: nil },
    { name: "Google Cloud Platform", proficiency_level: nil, years_of_experience: nil },
    { name: "Azure", proficiency_level: nil, years_of_experience: nil },
    { name: "Docker", proficiency_level: nil, years_of_experience: nil },
    { name: "Kubernetes", proficiency_level: nil, years_of_experience: nil },
    { name: "CI/CD", proficiency_level: nil, years_of_experience: nil },
    { name: "Terraform", proficiency_level: nil, years_of_experience: nil },
    # ML/AI
    { name: "PyTorch", proficiency_level: nil, years_of_experience: nil },
    { name: "TensorFlow", proficiency_level: nil, years_of_experience: nil },
    { name: "MLOps", proficiency_level: nil, years_of_experience: nil },
    { name: "Computer Vision", proficiency_level: nil, years_of_experience: nil },
    { name: "NLP", proficiency_level: nil, years_of_experience: nil },
    # Tools & Others
    { name: "Git", proficiency_level: nil, years_of_experience: nil },
    { name: "GraphQL", proficiency_level: nil, years_of_experience: nil },
    { name: "Apache Kafka", proficiency_level: nil, years_of_experience: nil },
    { name: "Tailwind CSS", proficiency_level: nil, years_of_experience: nil },
    { name: "Storybook", proficiency_level: nil, years_of_experience: nil }
  ]

  generic_skills.each do |skill_attrs|
    skill = Skill.find_or_initialize_by(name: skill_attrs[:name])
    skill.assign_attributes(skill_attrs)
    skill.save!
    puts "🛠️  Seeded skill: #{skill.name}"
  end

  puts "\n📊 Current counts:"
  puts "  Users: #{User.count}"
  puts "  Skills: #{Skill.count}"
  puts "\n💡 Note: User-specific data (profile, experiences, projects, etc.) should be added via Rails Admin or API."
  puts "   Mock data is available on the frontend when NEXT_PUBLIC_SHOW_MOCK_DATA=true"
end

puts "\n✅ Seeding complete!"
