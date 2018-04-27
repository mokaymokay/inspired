require 'sinatra'
require 'sinatra/activerecord'
require_relative './models/user'
require_relative './models/post'
require_relative './models/tag'
require_relative './models/tagging'

set :database, {adapter: 'postgresql', database: 'rumblr'}

get '/' do
  erb :index
end

get '/login' do
  erb :'/users/login'
end

post '/login' do
  @user = User.find_by(email: params[:email], password: params[:password])
  if @user != nil
    session[:id] = @user.id
    # TODO: redirect to logged in version of homepage - specify in index.erb
    redirect '/'
  else
    # TODO: display error message instead of redirecting?
    redirect '/login'
  end
end
