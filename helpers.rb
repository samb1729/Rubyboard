require 'sinatra'

helpers do
  def h text
    Rack::Utils.escape_html text
  end

  def trip tripcode
    return "" unless tripcode
    trip = "!" << Digest::MD5.hexdigest(tripcode + "salt to annoy duk")[0..8]
  end

  def bbcodes
    {
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
  end
end