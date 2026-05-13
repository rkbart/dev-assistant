Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "ask", to: "ai#ask"
      get "projects", to: "ai#projects"
      post "index_project", to: "ai#index_project"
    end
  end
end
