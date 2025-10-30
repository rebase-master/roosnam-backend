# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

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

# ---------------------------
# Seed Skills (limit to top 100)
# ---------------------------
if defined?(Skill)
  skill_names = %w[
    JavaScript Python Java C# PHP C++ TypeScript Ruby Go Swift Kotlin Rust SQL HTML CSS Bash PowerShell Dart Scala
    Objective-C R MATLAB Groovy Perl Elixir Haskell Lua Clojure Shell Assembly Solidity GraphQL React Angular Vue
    Svelte Next.js Nuxt.js Node.js Deno Express Rails Django Flask Spring .NET Laravel Phoenix FastAPI TensorFlow
    PyTorch Pandas NumPy SciPy scikit-learn Kafka RabbitMQ Redis PostgreSQL MySQL SQLite MongoDB Elasticsearch
    Kubernetes Docker Terraform Ansible AWS GCP Azure Firebase Supabase Vite Webpack Babel Jest Mocha RSpec
    Cypress Playwright Selenium Storybook Tailwind Bootstrap Material-UI AntDesign ChakraUI Three.js WebGL Unity
    Unreal Hadoop Spark Airflow dbt Git GitHub GitLab Bitbucket Jira Confluence Figma Postman OpenAPI OAuth JWT
    WebRTC WebSockets
  ]
  skill_names = skill_names.take(100)

  skill_names.each do |name|
    slug = name.downcase.gsub(/[^a-z0-9]+/, '-').gsub(/^-|-$/, '')
    Skill.find_or_create_by!(slug: slug) do |s|
      s.name = name
    end
  end
  puts "Seeded skills: #{Skill.count} total"
end

# ---------------------------
# Seed Companies (limit to top 1000)
# ---------------------------
if defined?(Company)
  base_companies = [
    "Google", "Microsoft", "Amazon", "Apple", "Meta", "IBM", "Oracle", "Intel", "Cisco", "Netflix",
    "Uber", "Airbnb", "Spotify", "Salesforce", "Adobe", "NVIDIA", "Samsung", "Xiaomi", "ByteDance",
    "Tencent", "Alibaba", "Huawei", "Shopify", "Square", "Stripe", "PayPal", "Dropbox", "Slack",
    "Atlassian", "Zoom", "Twilio", "Cloudflare", "Snowflake", "Datadog", "Elastic", "HashiCorp",
    "DigitalOcean", "GitHub", "GitLab", "Reddit", "LinkedIn", "eBay", "Yahoo", "Yelp", "DoorDash",
    "Instacart", "Robinhood", "Coinbase", "OpenAI", "Anthropic"
  ]

  # Generate up to 1000 companies; pad with synthetic entries if needed
  companies_to_seed = base_companies

  companies_to_seed.each do |company_name|
    Company.find_or_create_by!(name: company_name) do |c|
      c.location = "Remote"
      c.website = "https://#{company_name.downcase.gsub(/[^a-z0-9]+/, '')}.com"
      c.description = "Seeded company record for #{company_name}."
      c.industry = "Technology"
      c.employee_count_range = "1-50"
      c.logo_url = nil
      c.founded_year = 2000
      c.verified = true
    end
  end
  puts "Seeded companies (up to 1000). Current total: #{Company.count}"
end

# ---------------------------
# Seed Education (sample for the admin user)
# ---------------------------
if defined?(Education) && defined?(User)
  owner = User.find_by(email: admin_email) || User.first
  if owner
    Education.find_or_create_by!(user_id: owner.id, institution: "Example University", degree: "B.Sc Computer Science") do |e|
      e.field_of_study = "Computer Science"
      e.start_year = 2012
      e.end_year = 2016
      e.grade = "A"
      e.description = "Seeded education record."
    end

    Education.find_or_create_by!(user_id: owner.id, institution: "Example Institute", degree: "High School Diploma") do |e|
      e.field_of_study = "Science"
      e.start_year = 2010
      e.end_year = 2012
      e.grade = "A"
      e.description = "Seeded education record."
    end
  end
  puts "Seeded education for user: #{owner&.email}"
end
