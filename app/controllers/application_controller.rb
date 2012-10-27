class ApplicationController < ActionController::Base
  before_filter :allow_cross_domain_access
  protect_from_forgery
  
  private
  def allow_cross_domain_access
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Methods"] = "GET"
  end
end
