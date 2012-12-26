$: << File.dirname(__FILE__)

require 'sinatra'
require 'post'
require 'bb-ruby'
require 'data_mapper'
require 'dm-migrations'

set :port, 80
set :root, File.dirname(__FILE__)
enable :sessions

DataMapper.setup(:default, 'sqlite:///'<< File.expand_path('../board.db', __FILE__))
DataMapper.finalize
DataMapper.auto_upgrade!

helpers do
  def h text
    Rack::Utils.escape_html text
  end

  def trip tripcode
    return "" unless tripcode
    trip = "!" << Digest::MD5.hexdigest(tripcode + "salt to annoy duk")[0..8]
  end
end

before do
  session ||= []
end

get '/' do
  @posts = Post.all
  @bbcodes = {
    'Quote' => [
      /&gt;&gt;([0-9]+)/,
      '<a href="#\1">>>\1</a>',
      'Meme arrows',
      '>>123',
      :quote
    ],
    'Board link' => [
      /&gt;&gt;&gt;(\/\w+\/)/,
      '<a href="http://boards.4chan.org\1">>>>\1</a>',
      'Cross-site link',
      '>>>/b/',
      :boardlink
    ]
  }
  erb :main_page, :layout => :layout
end

post '/post' do
  name, content = params[:name], params[:post]
  session['name'] = name
  session['lastpost'] ||= Time.now.strftime("%s").to_i - 10

  filename = nil
  thumbnail = nil

  if params[:image] and (params[:image][:tempfile].size < 500 * 1024)
    time = Time.now.strftime("%s").to_i % 100000

    extension = ".jpg" if params[:image][:head] =~ /jpg/
    extension = ".png" if params[:image][:head] =~ /png/
    extension = ".gif" if params[:image][:head] =~ /gif/

    if extension
      filename = 'images/' + time.to_s + extension
      FileUtils.cp params[:image][:tempfile], 'public/' << filename

      thumbnail = 'thumbs/' + time.to_s + '.jpg'
      `convert -resize 120x120 public/#{filename} public/#{thumbnail}`
    end
  end

  name, tripcode = name.split('#', 2)

  unless name.length < 3 or content.length < 10 or Time.now.strftime("%s").to_i - session['lastpost'].to_i < 10
    post = Post.create :name => name, :tripcode => tripcode, :content => content, :created_at => Time.now, :image => filename, :thumb => thumbnail
    post.save
  end
  redirect '/'
end