$: << File.dirname(__FILE__)

require 'sinatra'
require 'post'

set :port, 80

helpers do
  def h text
    Rack::Utils.escape_html text
  end  
end

before '/' do
  @@posts ||= []
end

get '/' do
  erb :main_page, :layout => :layout
end

post '/post' do
  name, content = params[:name], params[:post]
  @@posts << Post.new(name, content, Time.now)
  redirect '/'
end