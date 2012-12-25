$: << File.dirname(__FILE__)

require 'sinatra'
require 'post'
require 'bb-ruby'
require 'data_mapper'
require 'dm-migrations'

set :port, 80
enable :sessions

DataMapper.setup(:default, 'sqlite:///'<< File.expand_path('../board.db', __FILE__))
DataMapper.finalize
DataMapper.auto_migrate! unless Post.all.count > 0

helpers do
  def h text
    Rack::Utils.escape_html text
  end

  def trip tripcode
    return "" unless tripcode
    trip = "!" << Digest::MD5.hexdigest(tripcode << "salt to annoy duk")[0..8]
  end
end

before do
  session ||= []
end

get '/' do
  @posts = Post.all
  @bbcodes = {
    'Quote' => [
      /&gt;&gt;([0-9]*)/,
      '<a href="#\1">>>\1</a>',
      'Meme arrows',
      '>>123',
      :quote
    ]
  }
  erb :main_page, :layout => :layout
end

post '/post' do
  name, content = params[:name], params[:post]
  session['name'] = name
  session['lastpost'] ||= Time.now.strftime("%s").to_i - 10

  name, tripcode = name.split('#', 2)

  unless name.length < 3 or content.length < 10 or Time.now.strftime("%s").to_i - session['lastpost'].to_i < 10
    post = Post.create :name => name, :tripcode => tripcode, :content => content, :created_at => Time.now
    post.save
  end
  redirect '/'
end