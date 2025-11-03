Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # CORS origins - set via CORS_ORIGINS environment variable
    # Use '*' for development (allows all origins) or specific domain for production
    # Example values:
    # Development: * or http://localhost:3001
    # Production: https://yourdomain.com
    origins ENV.fetch('CORS_ORIGINS', '*')

    resource '/api/*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end

