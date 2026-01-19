class PagesController < ApplicationController
  # devise gem: skip authentication for home page
  skip_before_action :authenticate_user!, only: :home
  
  def home
  end
end
