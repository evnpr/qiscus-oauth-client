require 'sinatra'
require 'oauth2'
require 'json'
enable :sessions

def client
  OAuth2::Client.new("9c3664f8de6132b35fb22c9dda2c6017602c815a3fd4c07ba7db402597b806dd", "ec7682e7da35625dbd3d01f0a05f41994a1d17794c03de93cae355b66020b38c", :site => "http://localhost:3000")
end

get "/auth/test" do
  redirect client.auth_code.authorize_url(:redirect_uri => redirect_uri)
end

get '/auth/test/callback' do
  access_token = client.auth_code.get_token(params[:code], :redirect_uri => redirect_uri)
  session[:access_token] = access_token.token
  @message = "Successfully authenticated with the server"
  erb :success
end

get '/yet_another' do
  @message = get_response('data.json')
  erb :success
end
get '/another_page' do
  @message = get_response('data.json')
  erb :another
end

def get_response(url)
  access_token = OAuth2::AccessToken.new(client, session[:access_token])
  p access_token
  JSON.parse(access_token.get("/api/v2/mobile/rooms_only").body).first
end


def redirect_uri
  uri = URI.parse(request.url)
  uri.path = '/auth/test/callback'
  uri.query = nil
  uri.to_s
end
