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
