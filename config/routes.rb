Rails.application.routes.draw do
  apipie

  scope path: "api/1" do
    resources :customers, only: %i(index create update) do
      resources :accounts, only: %i(index create)
    end

    resources :accounts, only: %i(update show) do
      resources :transfers, only: :index
    end

    resources :transfers, only: %i(create update)
  end

  e_404 = -> hash { [404, {}, ["Not found"]] }

  root to: e_404

  match '*foo', via: [:get, :post, :put, :patch, :delete], to: e_404
end
