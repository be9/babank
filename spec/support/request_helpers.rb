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

    example = RSpec.current_example

    #if example.metadata[:apiv2]
      ## Allow the role to be set.
      #role_str = opts.delete(:authorize)
      #if role_str && role_str != Member::ROLE_GUEST
        #member.update(role: role_str) if member.role != role_str
        #headers['HTTP_AUTHORIZATION'] = "token #{member.api_v2_token}"
      #end
      ## Allow the token to be passed explicitly if necessary.
      #if token = opts.delete(:token)
        #headers['HTTP_AUTHORIZATION'] = "token #{token}"
      #end
    #end

    send(method, path, opts, headers)
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
end
