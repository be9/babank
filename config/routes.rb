Rails.application.routes.draw do
  apipie

  scope path: "api/1" do
    resources :customers, only: %i(index create update) do
      resources :accounts, only: %i(index create)
    end

    resources :accounts, only: %i(update show)
  end

  root to: -> hash { [404, {}, ["Not found"]] }
end
