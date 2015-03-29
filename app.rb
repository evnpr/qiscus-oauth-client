require 'sinatra'
require 'oauth2'
require 'json'
enable :sessions

def client
  OAuth2::Client.new("b175b563f47a764f86a201d7f7add1d0a1034a6c38d0c3f34c4906db689b77cb", "e48561c1aa6dbb3479a84f35abf6bd8085ca4e21fecc85e94c45babbd20d95b4", :site => "http://staging.qisc.us")
end

get "/" do
  content_type :json
  { :key1 => 'value1', :key2 => 'value2' }.to_json
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
