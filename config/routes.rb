Rails.application.routes.draw do
  resources :articles do
    resources :comments, :only => [:create, :destroy]
  end

  get '/import' => 'importer#import', :as => :importer_import
  get '/export' => 'importer#export', :as => :importer_export
  get '/export/download' => 'importer#download_file', :as => :importer_download_file

  post '/import' => 'importer#import_from_file', :as => :importer_import_file

  root 'articles#index'
end
