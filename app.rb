require 'sinatra'
require 'sinatra/activerecord'
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
  if user_exists? && current_user
    @user = current_user
    # displays posts that do not belong to the logged in user in homepage
    @posts = Post.where.not(user_id: @user.id)
    erb :'users/index', :layout => :'users/layout'
  else
    erb :index
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
      Tagging.create(post_id: post.id, tag_id: new_tag.id)
    else
      Tagging.create(post_id: post.id, tag_id: tag_in_db.id)
    end
  end
  # TODO: should redirect to user's blog sorted by most recent post
  redirect '/'
end



private

# true if user exists
def user_exists?
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
