require 'bundler/setup'
require 'compass'
require 'sinatra'
require 'mustache/sinatra'
require 'zurb-foundation'
require 'mongo'
require 'mongoid'

configure do
  Mongoid.load!('mongoid.yml')
end

# Models
class Post
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String
  field :body, type: String
end

class App < Sinatra::Base
  # setup mustache
  register Mustache::Sinatra
  require './views/layout'

  set :mustache, {
    :views     => './views/',
    :templates => './templates/'
  }

  # setup compass
  configure do
    set :haml, {:format => :html5, :escape_html => true}
    set :scss, {:style => :compact, :debug_info => false}
    Compass.add_project_configuration(File.join(Sinatra::Application.root, 'config', 'compass.rb'))
  end

  get '/stylesheets/:name.css' do
    content_type 'text/css', :charset => 'utf-8'
    scss(:'stylesheets/#{params[:name]}' ) 
  end

  # routes
  get '/' do
    Post.create(title: 'Trust the Stache', body: 'Mustache is a great template language for the client and server')
    @post = Post.all.to_a
    mustache :index
  end
end