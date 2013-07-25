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

  set :username,'daz'
  set :token,'maketh1$longandh@rdtoremember'
  set :password,'topsecret'

  helpers do
    def admin? ; request.cookies[settings.username] == settings.token ; end
    def protected! ; halt [ 401, 'Not Authorized' ] unless admin? ; end
  end

  # basic routes
  get('/') { redirect '/about' }
  get('/about') { haml :about }
  get('/story') { haml :story }
  get('/resume') { haml :resume }

  # security
  get('/admin'){ haml :admin }
  post '/login' do
    if params['username']==settings.username&&params['password']==settings.password
        response.set_cookie(settings.username,settings.token) 
        redirect '/'
      else
        "Username or Password incorrect"
    end
  end
  get('/logout'){ response.set_cookie(settings.username, false) ; redirect '/' }

  # blog routes
  get '/blog' do
    @posts = Post.all.descending(:published_on).to_a
    haml :blog
  end

  get '/blog/new' do
    protected!
    haml :new
  end

  post '/blog/new' do
    @post = Post.create(params[:post])
    redirect '/blog'
  end

  get '/blog/edit/:id' do |id|
    protected!
    @post = Post.find(id)
    haml :edit, :locals => { :body => @post.body}
  end

  post '/blog/update/:id' do |id|
    protected!
    @post = Post.find(id)
    @post.update_attributes(params[:post])
    redirect '/blog'
  end

  post '/blog/del/:id' do |id|
    protected!
    @post = Post.find(id)
    @post.delete
    redirect '/blog'
  end
end