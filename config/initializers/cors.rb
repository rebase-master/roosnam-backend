Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # In production we must explicitly configure CORS_ORIGINS.
    if Rails.env.production? && ENV['CORS_ORIGINS'].blank?
      raise 'CORS_ORIGINS environment variable must be set in production'
    end

    # Default to the Next.js frontend dev URL in non-production environments.
    origins ENV.fetch('CORS_ORIGINS', 'http://localhost:3001')

    resource '/api/*',
      headers: :any,
             methods: %i[get post put patch delete options head]
  end
end

