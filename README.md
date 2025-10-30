# Roosnam Backend API

Rails 8.1 API backend for the Roosnam portfolio platform with SQLite database.

## Features

- RESTful JSON API for portfolio data
- RailsAdmin interface for content management
- Devise authentication for admin access
- CORS enabled for Next.js frontend
- SQLite database (file-based, no external DB required)
- Background job support (Sidekiq) for future AI integrations

## Setup

### Requirements

- Ruby 3.2.4 (check `.ruby-version`)
- Bundler
- SQLite3

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   bundle install
   ```

3. Set up the database:
   ```bash
   rails db:create db:migrate
   ```

4. Create an admin user:
   ```bash
   rails console
   ```
   ```ruby
   User.create!(email: 'admin@example.com', password: 'password', admin: true)
   ```

5. Start the server:
   ```bash
   rails server
   ```

The API will be available at `http://localhost:3000`

## API Endpoints

### Base URL
```
http://localhost:3000/api/v1
```

### Public (used by frontend)

- **Works**: `/api/v1/works`
- **Skills**: `/api/v1/skills`

### Example Request

```bash
curl http://localhost:3000/api/v1/companies
```

## Admin Interface

Access the admin dashboard at:
```
http://localhost:3000/admin
```

Login with your admin user credentials to manage portfolio content through the RailsAdmin interface.

## Development

### Database

This project uses SQLite for simplicity. Database files are stored under `storage/` in development/test.

**Note**: SQLite database files are gitignored. Make sure to commit and push migration files, not the database files themselves.

### Running Tests

```bash
rails test
```

### Adding New Models

1. Generate migration: `rails generate migration CreateModelName field:type`
2. Generate model: `rails generate model ModelName`
3. Add associations and validations
4. Run migration: `rails db:migrate`
5. Update API controller and routes

## Architecture

- **Models**: ActiveRecord models with associations and validations
- **API Controllers**: JSON-only controllers under `app/controllers/api/v1/`
- **Admin**: RailsAdmin interface for content management
- **Authentication**: Devise for user management with admin flag
- **CORS**: Configured for Next.js frontend in `config/initializers/cors.rb`

## Deployment

The project includes a Dockerfile for containerized deployment. For production deployment, consider:

1. Setting up environment variables
2. Configuring CORS to allow only your domain
3. Using a production database (PostgreSQL) for better performance
4. Setting up Redis for Sidekiq background jobs

## License

Private project - All rights reserved
