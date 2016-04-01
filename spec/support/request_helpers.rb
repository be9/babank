module RequestHelpers
  def do_post(path, opts = {})
    make_request :post, path, opts
  end

  def do_patch(path, opts = {})
    make_request :patch, path, opts
  end

  def do_get(path, opts = {})
    make_request :get, path, opts
  end

  def do_put(path, opts = {})
    make_request :put, path, opts
  end

  def do_delete(path, opts = {})
    make_request :delete, path, opts
  end

  def json_body
    JSON.parse(response.body)
  end

  private

  def make_request(method, path, opts)
    headers = opts.delete(:headers) || {}

    case RSpec.current_example.metadata[:authorize]
    when true       # Pass proper token
      headers['HTTP_AUTHORIZATION'] = "token #{Rails.application.secrets.api_token}"
    when :bad       # Pass bad token
      headers['HTTP_AUTHORIZATION'] = "token Wr0ngT0k3n"
    when nil        # Pass no token
    else
      raise ArgumentError
    end

    send(method, path, opts, headers)
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
end
