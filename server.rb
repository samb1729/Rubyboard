$: << File.dirname(__FILE__)

require 'sinatra'
require 'post'
require 'bb-ruby'

set :port, 80

enable :sessions

helpers do
  def h text
    Rack::Utils.escape_html text
  end  
end

before '/' do
  @@posts ||= []
  session ||= []
end

get '/' do
  erb :main_page, :layout => :layout
end

post '/post' do
  name, content = params[:name], params[:post]
  session['name'] = name
  unless name.length < 3 or content.length < 10
    @@posts << Post.new(name, content.bbcode_to_html({}, true, :disable, :image), Time.now)
  end
  redirect '/'
end