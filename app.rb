require 'bundler/setup'
require 'compass'
require 'sinatra'
require 'haml'
require 'redcarpet'
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
  field :published_on, type: String
end

class App < Sinatra::Base
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
    haml :index
  end

  get '/blog' do
    @posts = Post.all.descending(:published_on).to_a
    haml :blog
  end

  get '/blog/new' do
    haml :new
  end

  post '/blog' do
    @post = Post.create(params[:post])
    redirect '/blog'
  end

  get '/blog/edit/:id' do |id|
    @post = Post.find(id)
    haml :edit, :locals => { :body => @post.body}
  end

  post '/blog/:id' do |id|
    @post = Post.find(id)
    @post.update_attributes(params[:post])
    redirect '/blog'
  end

  post '/blog/del/:id' do |id|
    @post = Post.find(id)
    @post.delete
    redirect '/blog'
  end
end