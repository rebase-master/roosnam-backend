admin_email = ENV.fetch("ADMIN_EMAIL", "admin@example.com")
admin_password = ENV.fetch("ADMIN_PASSWORD", "changeme123")

if defined?(User)
  user = User.find_or_initialize_by(email: admin_email)
  if user.new_record?
    user.password = admin_password
    user.password_confirmation = admin_password
  end
  user.admin = true
  user.save!
  puts "Seeded admin user: #{admin_email}"
end

# Seed Skills for existing Work Experiences
if defined?(Skill) && defined?(WorkExperience)
  work_experiences = WorkExperience.all

  skills_data = [
    # Languages
    { name: "Ruby", proficiency_level: "expert", years_of_experience: 8 },
    { name: "Python", proficiency_level: "advanced", years_of_experience: 5 },
    { name: "JavaScript", proficiency_level: "advanced", years_of_experience: 6 },
    { name: "TypeScript", proficiency_level: "intermediate", years_of_experience: 3 },
    { name: "SQL", proficiency_level: "expert", years_of_experience: 8 },
    # Frameworks
    { name: "Ruby on Rails", proficiency_level: "expert", years_of_experience: 8 },
    { name: "React", proficiency_level: "advanced", years_of_experience: 4 },
    { name: "Next.js", proficiency_level: "intermediate", years_of_experience: 2 },
    { name: "Django", proficiency_level: "intermediate", years_of_experience: 2 },
    # Databases
    { name: "PostgreSQL", proficiency_level: "expert", years_of_experience: 7 },
    { name: "Redis", proficiency_level: "advanced", years_of_experience: 5 },
    { name: "SQLite", proficiency_level: "advanced", years_of_experience: 4 },
    # DevOps & Cloud
    { name: "Docker", proficiency_level: "advanced", years_of_experience: 4 },
    { name: "AWS", proficiency_level: "intermediate", years_of_experience: 3 },
    { name: "CI/CD", proficiency_level: "advanced", years_of_experience: 5 },
    { name: "Kubernetes", proficiency_level: "beginner", years_of_experience: 1 },
    # Tools
    { name: "Git", proficiency_level: "expert", years_of_experience: 8 },
    { name: "Tailwind CSS", proficiency_level: "advanced", years_of_experience: 3 },
  ]

  skills_data.each_with_index do |skill_attrs, index|
    # Distribute skills across work experiences
    work_exp = work_experiences[index % work_experiences.count] if work_experiences.any?

    skill = Skill.find_or_initialize_by(name: skill_attrs[:name])
    skill.assign_attributes(skill_attrs)
    skill.work_experience = work_exp if work_exp
    skill.save!
    puts "Seeded skill: #{skill.name}"
  end
end

# Seed Client Projects
if defined?(ClientProject) && defined?(User)
  user = User.first

  projects_data = [
    {
      name: "E-Commerce Platform",
      description: "Built a full-featured e-commerce platform with inventory management, payment processing, and real-time order tracking. Implemented microservices architecture for scalability.",
      role: "Lead Developer",
      client_name: "RetailTech Inc.",
      tech_stack: "Ruby on Rails, React, PostgreSQL, Redis, Stripe",
      start_date: Date.new(2023, 1, 15),
      end_date: Date.new(2023, 8, 30),
      project_url: "https://example-ecommerce.com"
    },
    {
      name: "Healthcare Management System",
      description: "Developed a comprehensive healthcare management system for clinics and hospitals. Features include patient records, appointment scheduling, billing, and telemedicine integration.",
      role: "Full Stack Developer",
      client_name: "MedCare Solutions",
      tech_stack: "Rails, Vue.js, PostgreSQL, Docker",
      start_date: Date.new(2022, 6, 1),
      end_date: Date.new(2023, 2, 28)
    },
    {
      name: "Real-time Analytics Dashboard",
      description: "Created a real-time analytics dashboard for monitoring business KPIs. Implemented WebSocket connections for live data updates and custom visualization components.",
      role: "Backend Developer",
      client_name: "DataViz Corp",
      tech_stack: "Python, Django, React, Redis, WebSockets",
      start_date: Date.new(2021, 9, 1),
      end_date: Date.new(2022, 3, 15),
      project_url: "https://analytics-demo.example.com"
    }
  ]

  projects_data.each do |project_attrs|
    project = ClientProject.find_or_initialize_by(name: project_attrs[:name])
    project.assign_attributes(project_attrs)
    project.user = user
    project.save!
    puts "Seeded client project: #{project.name}"

    # Link some skills to the project
    tech_names = project_attrs[:tech_stack].split(",").map(&:strip)
    tech_names.each do |tech_name|
      skill = Skill.find_by("LOWER(name) LIKE ?", "%#{tech_name.downcase}%")
      if skill && !project.skills.include?(skill)
        project.skills << skill
        puts "  Linked skill: #{skill.name}"
      end
    end
  end
end

# Seed Client Reviews
if defined?(ClientReview) && defined?(ClientProject) && defined?(User)
  user = User.first

  reviews_data = [
    {
      project_name: "E-Commerce Platform",
      reviewer_name: "John Smith",
      reviewer_position: "CTO",
      reviewer_company: "RetailTech Inc.",
      review_text: "Exceptional work on our e-commerce platform! The team delivered a robust, scalable solution that exceeded our expectations. The attention to detail and proactive communication made the collaboration a pleasure.",
      rating: 5
    },
    {
      project_name: "E-Commerce Platform",
      reviewer_name: "Sarah Johnson",
      reviewer_position: "Product Manager",
      reviewer_company: "RetailTech Inc.",
      review_text: "The development process was smooth and transparent. All features were delivered on time, and the code quality was excellent. Highly recommend!",
      rating: 5
    },
    {
      project_name: "Healthcare Management System",
      reviewer_name: "Dr. Michael Chen",
      reviewer_position: "Director of IT",
      reviewer_company: "MedCare Solutions",
      review_text: "The healthcare system has transformed how we manage patient care. The intuitive interface and reliable performance have been praised by our medical staff.",
      rating: 5
    },
    {
      project_name: "Real-time Analytics Dashboard",
      reviewer_name: "Emily Davis",
      reviewer_position: "VP of Engineering",
      reviewer_company: "DataViz Corp",
      review_text: "Outstanding technical expertise! The real-time dashboard provides invaluable insights for our business decisions. The WebSocket implementation is flawless.",
      rating: 4
    }
  ]

  reviews_data.each do |review_attrs|
    project = ClientProject.find_by(name: review_attrs[:project_name])
    next unless project

    review = ClientReview.find_or_initialize_by(
      reviewer_name: review_attrs[:reviewer_name],
      client_project: project
    )
    review.assign_attributes(
      reviewer_position: review_attrs[:reviewer_position],
      reviewer_company: review_attrs[:reviewer_company],
      review_text: review_attrs[:review_text],
      rating: review_attrs[:rating],
      user: user
    )
    review.save!
    puts "Seeded review from: #{review.reviewer_name}"
  end
end

# Seed Certifications
if defined?(Certification) && defined?(User)
  user = User.first

  certifications_data = [
    {
      title: "AWS Certified Solutions Architect",
      issuer: "Amazon Web Services",
      issue_date: Date.new(2023, 3, 15),
      expiration_date: Date.new(2026, 3, 15),
      credential_url: "https://aws.amazon.com/verification/12345"
    },
    {
      title: "Ruby on Rails Developer Certification",
      issuer: "Rails Foundation",
      issue_date: Date.new(2022, 8, 1),
      credential_url: "https://rails.org/certifications/67890"
    },
    {
      title: "Certified Kubernetes Administrator (CKA)",
      issuer: "Cloud Native Computing Foundation",
      issue_date: Date.new(2024, 1, 20),
      expiration_date: Date.new(2027, 1, 20)
    }
  ]

  certifications_data.each do |cert_attrs|
    cert = Certification.find_or_initialize_by(title: cert_attrs[:title], user: user)
    cert.assign_attributes(cert_attrs)
    cert.user = user
    cert.save!
    puts "Seeded certification: #{cert.title}"
  end
end

puts "\n✅ Seeding complete!"
