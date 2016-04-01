Apipie.configure do |config|
  config.app_name                = "Babank"
  config.api_base_url            = "/1"
  config.doc_base_url            = "/apipie"
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/**/*.rb"

  config.default_version = '1'
end
