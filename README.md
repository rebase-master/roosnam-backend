# Roosnam Backend API

Rails 8.1 API backend for the Roosnam portfolio platform with SQLite database.

**Single-User Mode**: This application is designed for one person's portfolio. It supports a single admin user who owns all portfolio content.

## Features

- RESTful JSON API for portfolio data
- RailsAdmin interface for content management
- Devise authentication for admin access
- Single-user (singleton) mode with automatic admin enforcement
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

3. Set up environment variables:
   Create a `.env` file or export the following:
   ```bash
   export ADMIN_EMAIL="your-email@example.com"
   export ADMIN_PASSWORD="your-secure-password"
   ```

4. Set up the database and seed the admin user:
   ```bash
   rails db:create db:migrate db:seed
   ```
   
   The seed command creates the single admin user using your `ADMIN_EMAIL` and `ADMIN_PASSWORD` environment variables. This user:
   - Is automatically assigned the `admin` role
   - Owns all portfolio content
   - Cannot be deleted or demoted through the admin interface
   - Is the only user allowed in the system (singleton pattern)

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

All endpoints return data scoped to the single portfolio user:

- **Works**: `/api/v1/works`
- **Company Experiences**: `/api/v1/company_experiences`
- **Client Projects**: `/api/v1/client_projects`
- **Client Reviews**: `/api/v1/client_reviews`
- **Experience Skills**: `/api/v1/experience_skills`
- **Certifications**: `/api/v1/certifications`
- **Education**: `/api/v1/education`

### Example Request

```bash
curl http://localhost:3000/api/v1/company_experiences
```

## Admin Interface

Access the admin dashboard at:
```
http://localhost:3000/admin
```

Login with your admin user credentials (from `ADMIN_EMAIL` and `ADMIN_PASSWORD`) to manage portfolio content through the RailsAdmin interface.

**Single-User Restrictions**:
- You can only edit the existing admin user (email/password changes)
- The admin checkbox is hidden (always enforced as `true`)
- Creating new users or deleting the admin user is prevented

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
- **Singleton User**: Enforced at model level; only one user allowed, always admin
- **API Controllers**: JSON-only controllers under `app/controllers/api/v1/`, automatically scoped to portfolio user
- **Serializers**: ActiveModelSerializers for consistent JSON responses
- **Admin**: RailsAdmin interface for content management
- **Authentication**: Devise for user management with admin flag
- **CORS**: Configured for Next.js frontend in `config/initializers/cors.rb`

## Deployment

The project includes a Dockerfile for containerized deployment. For production deployment:

### Required Environment Variables
```bash
ADMIN_EMAIL=your-email@example.com
ADMIN_PASSWORD=your-secure-password
SECRET_KEY_BASE=generate-with-rails-secret
```

### Additional Considerations
1. Configure CORS to allow only your domain in `config/initializers/cors.rb`
2. Run `rails db:seed` on first deployment to create the admin user
3. Consider using PostgreSQL for production instead of SQLite for better concurrency
4. Set up Redis for Sidekiq background jobs

## License

Private project - All rights reserved
