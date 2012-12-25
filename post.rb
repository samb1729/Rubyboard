class Post
  attr_accessor :name, :content, :time

  def initialize name, content, time
    @name, @content, @time = name, content, time
  end
end