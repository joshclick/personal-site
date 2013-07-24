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
    @test = 'asdf'
    @posts = Post.all.descending(:created_at).limit(5).to_a
    mustache :index
  end

  get '/new' do
    @post = Post.new
    mustache :new
  end

  post '/' do
    @post = Post.create(params[:post])
    redirect '/'
  end

  get '/:id' do |id|
    @post = Post.find(id)
    mustache :show
  end

  get '/:id/edit' do |id|
    @post = Post.find(id)
    mustache :edit
  end

  put '/:id' do |id|
    @post = Post.find(id)
    @post.update_attributes(params[:post])
    mustache :show
  end

  delete '/:id' do |id|
    @post = Post.find(id)
    @post.delete
    redirect '/'
  end
end