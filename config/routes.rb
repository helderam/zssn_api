Rails.application.routes.draw do
  
  root :to => "application#index"

	resources :survivors, only: [:index, :create, :update, :show] do
  	post :flag_infection, on: :member
  end

  resource :reports, only: [] do
  	get 'infected_survivors'
  	get 'not_infected_survivors'
    get 'resources_by_survivor'
    get 'lost_infected_points'
  end

  post :trade_resources, to: 'trades#trade_resources'

  get '*path' => 'application#index'
  
end
