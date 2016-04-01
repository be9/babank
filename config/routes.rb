Rails.application.routes.draw do
  apipie

  scope path: "api/1" do
    resources :customers, only: %i(index create update)
  end

end
