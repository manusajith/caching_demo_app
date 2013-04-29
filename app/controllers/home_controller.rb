class HomeController < ApplicationController
	layout false
	caches_page :index
  def index
  	redirect_to articles_path if user_signed_in?
  end
end
