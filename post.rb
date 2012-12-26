require 'data_mapper'

def h text
  Rack::Utils.escape_html text
end

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