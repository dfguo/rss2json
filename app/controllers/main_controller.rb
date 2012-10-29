require 'open-uri'
require 'json'


class MainController < ApplicationController
  respond_to :json
  
  def rss
    @errors = []
    
    rss_feed = params[:url]
    if not uri?(rss_feed)
      @errors << 'Invalid url.'
    end
    
    if @errors.empty?
      begin
        json_object = fetch_json_from_rss(rss_feed)
      rescue
        @errors << "Not a valid rss feed."
      end
    end
    
    if @errors.empty? 
      render :json => json_object
    else
      render :json => {:status => 'error', :errors => @errors.join(' ')}
    end
  end
  
  
  private
  
  def fetch_json_from_rss(rss_feed)
    Rails.cache.fetch(rss_feed, :expires_in => 25.minutes) {
      content = open("http://www.blastcasta.com/feed-to-json.aspx?feedurl=#{URI.escape(rss_feed)}").read
      json_object = JSON.parse(content)
    }
  end
    
  def uri?(string)
    uri = URI.parse(string)
    %w( http https ).include?(uri.scheme)
  rescue URI::BadURIError
    false
  rescue URI::InvalidURIError
    false
  end
end