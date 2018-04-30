require 'sinatra'
require 'sinatra/activerecord'
require 'pry'
require 'will_paginate'
require 'will_paginate/active_record'

require_relative './models/user'
require_relative './models/post'
require_relative './models/tag'
require_relative './models/tagging'

set :database, {adapter: 'postgresql', database: 'rumblr'}

configure do
  enable :sessions unless test?
  set :session_secret, "secret"
end

get '/' do
  if session_exists? && current_user
    @user = current_user
    # displays posts that do not belong to the logged in user in homepage
    @posts = Post.where.not(user_id: @user.id).paginate(:page => params[:page], :per_page => 20)
    erb :'users/index', :layout => :'users/layout'
  else
    erb :index, :layout => :'cover'
  end
end

get '/login' do
  erb :'users/login'
end

post '/login' do
  @user = User.find_by(email: params[:email], password: params[:password])
  if @user != nil
    set_as_current_user
    redirect '/'
  else
    # TODO: display error message instead of redirecting/refreshing form
    redirect '/login'
  end
end

get '/signup' do
  erb :'users/signup'
end

post '/signup' do
  @user = User.create(first_name: params[:first_name], last_name: params[:last_name], email: params[:email], password: params[:password], birthday: params[:birthday], username: params[:username])
  set_as_current_user
  redirect '/'
end

get '/logout' do
  session.clear
  redirect '/'
end

get '/posts/new' do
  @user = current_user
  erb :'posts/new', :layout => :'users/layout'
end

post '/posts/new' do
  @user = current_user
  post = Post.create(quote: params[:quote], author: params[:author], user_id: @user.id)
  tags = params[:tags]
  tags.split(' ').each do |tag|
    tag_in_db = Tag.find_by(content: tag)
    if tag_in_db.nil?
      new_tag = Tag.create(content: tag)
      tag_id = new_tag.id
    else
      tag_id = tag_in_db.id
    end
    Tagging.create(post_id: post.id, tag_id: tag_id)
  end
  # after posting, redirect to own blog :)
  redirect "/users/#{@user.id}"
end

get '/users/:id' do
  if User.exists?(params[:id])
    @blog_owner = User.find(params[:id])
    # display posts that belong to blog owner
    @posts = Post.where(user_id: @blog_owner.id).paginate(:page => params[:page], :per_page => 20)
    # if user is logged in, display user layout
    if session_exists? && current_user
      # need @user instance variable for user layout
      @user = current_user
      erb :'users/index', :layout => :'users/layout'
    else
      erb :'users/index'
    end
  else
    # if user doesn't exist
    erb :'users/none'
  end
end

get '/posts/:id/edit' do
  @post = Post.find(params[:id])
  @user = current_user
  @blog_owner = User.find(@post.user_id)
  if @user == @blog_owner
    erb :'posts/edit'
  end
end

put '/posts/:id' do
  @user = current_user
  @post = Post.find(params[:id])
  @post.update(quote: params[:quote], author: params[:author])
  # TODO: fix ability to update tags
  # tags = params[:tags]
  # tags.split(' ').each do |tag|
  #   # determine if tag already exists
  #   tag_in_db = Tag.find_by(content: tag)
  #   if Tagging.find_by(post_id: @post.id, tag_id: tag_in_db.id)
  #     Tagging.update(content: tag)
  #   else
  #     if tag_in_db.nil?
  #       new_tag = Tag.create(content: tag)
  #       tag_id = new_tag.id
  #     else
  #       tag_id = tag_in_db.id
  #     end
  #     Tagging.create(post_id: @post.id, tag_id: tag_id)
  #   end
  # end
  redirect "/users/#{@user.id}"
end

delete '/posts/:id' do
  @user = current_user
  Post.destroy(params[:id])
  redirect "/users/#{@user.id}"
end

get '/profile/' do
  @user = current_user
  erb :'users/profile', :layout => :'users/layout'
end

delete '/users/:id' do
  session.clear
  User.destroy(params[:id])
  redirect "/"
end





private

# returns true if session exists; false if user has logged out
def session_exists?
  session[:id] != nil
end

# finds current user in database by session id
def current_user
  User.find(session[:id])
end

# logs user in
def set_as_current_user
  session[:id] = @user.id
end
