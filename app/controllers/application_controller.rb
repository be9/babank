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
end
