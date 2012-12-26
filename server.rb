$: << File.dirname(__FILE__)

require 'sinatra'
require 'bb-ruby'
require 'data_mapper'
require 'dm-migrations'

require 'post'
require 'helpers'

set :port, 80
set :root, File.dirname(__FILE__)
enable :sessions

DataMapper.setup(:default, 'sqlite:///'<< File.expand_path('../board.db', __FILE__))
DataMapper.finalize
DataMapper.auto_upgrade!

before do
  session ||= {}
  @@request_times ||= {}
end

get '/' do
  @posts = Post.all
  @bbcodes = bbcodes
  erb :main_page, :layout => :layout
end

post '/post' do
  name, tripcode, content, created_at, image, thumb, ip = gen_post(params)

  unless session['lastpost'].to_i < 10
    post = Post.create({:name => name,
                        :tripcode => tripcode,
                        :content => content,
                        :created_at => created_at,
                        :image => image,
                        :thumb => thumb,
                        :ip => ip})
  end
  redirect '/'
end