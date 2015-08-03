require 'nokogiri'
require 'open-uri'
require 'pry'
require 'json'
require 'rack'

require 'sinatra'
require "sinatra/reloader" if development?

get '/' do
  @properties = all_together_now
  erb :index
end


get '/the_goods.json' do
  all_together_now.to_json
end






def index
  url = "http://www.zoopla.co.uk/for-sale/property/london/mattison-road/n4-1bq/?q=n4%201bq&category=residential&include_shared_accommodation=&keywords=&radius=0&added=&price_min=350000&price_max=500000&beds_min=1&beds_max=3&include_retirement_homes=true&include_shared_ownership=true&new_homes=include&polyenc=yruyHv%7DGgxAtzAem%40lbAcJeSsG%60gEhDxk%40i%40NnDz%40rDO~FgBzFeFbMIzH%7DAxBcD~%40oFzdAfn%40hVc%7DBkHwj%40%7Cc%40bR&search_source=refine&user_alert_id=5495743"
  doc = Nokogiri::HTML(open(url))
  links = []
  doc.css('a:contains("Full details")').each do |link|
    links.push("http://www.zoopla.co.uk" +link['href'])
  end
  links
end


def show(url)
  @doc     = Nokogiri::HTML(open(URI.escape(url)))
  images   = []
  lat_lng  = ""
  google   = ""
  floor    = @doc.css("[data-ga-category='Floorplan']")
  floor    = floor[0].nil? ? nil : floor[0]["href"]
  images   = get_images(@doc.css('.images-thumb'))
  desc     = @doc.css('[itemprop="description"]').text
  price    = @doc.css('.text-price.listing-details-price').text
  lat      = @doc.css('[itemprop="latitude"]')[0]["content"]
  lng      = @doc.css('[itemprop="longitude"]')[0]["content"]

  {
    :images => images,
    :lat => lat,
    :lng => lng,
    :floorplan => floor,
    :description => desc,
    :price => price,
    :link => url
  }
end

def get_images(images)
  _images = []
  images.each do |image|
    src = image["data-photo"]
    _images.push(src)
  end
  _images
end

def lat_long(uri)
  env = Rack::MockRequest.env_for(uri)
  req = Rack::Request.new(env)
  req.params['center']
end

def all_together_now
  json = []
  index.each do |link|
    json.push(show(link))
  end
  json
end


