class ApplicationController < ActionController::API

  if Rails.application.secrets.api_token
    before_action :verify_token
  end

  rescue_from Apipie::ParamError do |e|
    render json: { message: e.message }, status: :unprocessable_entity
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: { message: e.message }, status: :not_found
  end

  protected

  def verify_token
    if CGI.unescape(request.headers['HTTP_AUTHORIZATION'].to_s) =~ /token ([^\s]+)/i
      token = $1
      return nil if token == Rails.application.secrets.api_token
    end

    render json: { message: 'Access denied' }, status: :forbidden
  end

  # Set up Link header according to paginated collection (see
  # http://tools.ietf.org/html/rfc5988).
  #
  # Stolen from api-pagination gem by davidcelis.
  def paginate(collection)
    pages = {}

    unless collection.first_page?
      pages[:first] = 1
      pages[:prev]  = collection.current_page - 1
    end

    unless collection.last_page?
      pages[:last] = collection.total_pages
      pages[:next] = collection.current_page + 1
    end

    links = []
    url = request.original_url.sub(/\?.*$/, '')

    pages.each do |k, v|
      new_params = request.query_parameters.merge(page: v)
      links << %(<#{url}?#{new_params.to_param}>; rel="#{k}")
    end

    headers['Link'] = links.join(', ') unless links.empty?
  end
end
