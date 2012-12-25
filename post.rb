def h text
  Rack::Utils.escape_html text
end

class Post
  attr_accessor :name, :content, :time

  def initialize name, content, time
    @name, @content, @time = name, content, time
  end

  def name
    return "<strong>" << @name << "</strong>" unless @name =~ /#/

    name_with_trip = @name.split '#', 2
    trip = Digest::MD5.hexdigest(name_with_trip[1] << "salt to annoy duk")[0..8]

    return "<strong>" << h(name_with_trip[0]) << "</strong>" << " !" << trip
  end
end