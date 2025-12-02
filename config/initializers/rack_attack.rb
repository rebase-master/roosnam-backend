class Rack::Attack
  # Throttle all requests to API endpoints by IP
  throttle('api/ip', limit: 100, period: 1.minute) do |req|
    req.ip if req.path.start_with?('/api/')
  end

  # Throttle login attempts by IP
  throttle('logins/ip', limit: 5, period: 20.seconds) do |req|
    if req.path == '/users/sign_in' && req.post?
      req.ip
    end
  end

  # Throttle login attempts by email
  throttle('logins/email', limit: 5, period: 20.seconds) do |req|
    if req.path == '/users/sign_in' && req.post?
      # Normalize email to prevent case-based bypass
      req.params.dig('user', 'email')&.downcase&.strip
    end
  end

  # Block obviously malicious or abusive user agents, but avoid blocking common
  # developer tooling like curl or language HTTP clients, which are often used
  # legitimately for health checks and debugging.
  blocklist('block known bad user agents') do |req|
    next false if req.user_agent.blank?

    bad_agents = ['sqlmap', 'nikto', 'acunetix', 'nmap']
    bad_agents.any? { |agent| req.user_agent.downcase.include?(agent) }
  end unless Rails.env.development?

  # Custom throttle response
  self.throttled_responder = lambda do |req|
    [
      429,
      { 'Content-Type' => 'application/json' },
      [{ error: 'Rate limit exceeded. Please try again later.', retry_after: req.env['rack.attack.match_data'][:period] }.to_json]
    ]
  end
end

# Enable caching for rack-attack (use Redis in production)
if Rails.env.production?
  Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(url: ENV['REDIS_URL'])
else
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
end
