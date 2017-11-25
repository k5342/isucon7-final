require 'erb'
require 'sinatra/base'
require './game'

class App < Sinatra::Base
  use Game

  configure do
    set :public_folder, File.expand_path('../../public', __FILE__)
  end

  configure :development do
    require 'sinatra/reloader'
    register Sinatra::Reloader
  end

  def set_global_mitems
    $m_items = conn.query('SELECT * FROM m_item').map do |raw_item|
      [
        raw_item['item_id'].to_s, 
        MItem.new(
          item_id: raw_item['item_id'],
          power1: raw_item['power1'],
          power2: raw_item['power2'],
          power3: raw_item['power3'],
          power4: raw_item['power4'],
          price1: raw_item['price1'],
          price2: raw_item['price2'],
          price3: raw_item['price3'],
          price4: raw_item['price4'],
        )
      ].to_h
    end
  end

  set_global_mitems
  puts $m_items

  get '/initialize' do
    Game.initialize!
    204
  end

  get '/room/' do
    content_type :json
    { 'host' => '', 'path' => '/ws' }.to_json
  end

  get '/room/:room_name' do
    room_name = ERB::Util.url_encode(params[:room_name])
    path = "/ws/#{room_name}"

    content_type :json
    { 'host' => '', 'path' => path }.to_json
  end

  get '/' do
    send_file File.expand_path('index.html', settings.public_folder)
  end
end
