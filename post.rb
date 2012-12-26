require 'data_mapper'
require 'sinatra'

class Post
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :tripcode, String
  property :content, Text
  property :created_at, DateTime
  property :image, String, :required => false
  property :thumb, String, :required => false
  property :ip, String, :required => false
end

helpers do
  def gen_post params
    name, content = params[:name], params[:post]
    session['name'] = name
    session['lastpost'] ||= Time.now.strftime("%s").to_i - 10
  
    req_time = @@request_times[request.ip]
  
    if req_time and Time.now.strftime("%s").to_i - req_time.to_i < 10
      return redirect '/'
    end
  
    @@request_times[request.ip] = Time.now.strftime("%s").to_i
  
    image = nil
    thumb = nil
  
    if params[:image] and (params[:image][:tempfile].size < 500 * 1024)
      time = Time.now.strftime("%s").to_i % 100000
  
      extension = ".jpg" if params[:image][:head] =~ /jpg/
      extension = ".png" if params[:image][:head] =~ /png/
      extension = ".gif" if params[:image][:head] =~ /gif/
  
      if extension
        image = 'images/' + time.to_s + extension
        FileUtils.cp params[:image][:tempfile], 'public/' << image
  
        thumb = 'thumbs/' + time.to_s + extension
        `convert -resize 120x120 public/#{image} public/#{thumb}`
      end
    end
  
    name, tripcode = name.split('#', 2)
    created_at = Time.now

    return name, tripcode, content, created_at, image, thumb, request.ip
  end
end