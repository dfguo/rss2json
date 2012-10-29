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
      json_object = fetch_json_from_rss(rss_feed)
      @errors << "Not a valid rss feed." if json_object.nil? or json_object['error']
    end
    
    if @errors.empty? 
      render :json => json_object
    else
      render :json => {:status => 'error', :errors => @errors.join(' ')}
    end
  end
  
  
  private
  
  def fetch_json_from_rss(rss_feed)
    json_object = Rails.cache.read(rss_feed)
    if json_object.nil?
      begin
        content = open("http://www.blastcasta.com/feed-to-json.aspx?feedurl=#{URI.escape(rss_feed)}").read
        json_object = JSON.parse(content)
      rescue
        json_object = {'error' => true}.to_json # default value for a faulty url
      end
      Rails.cache.write(rss_feed, json_object, :expires_in => 25.minutes)
    end
    
    json_object
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