require 'submission'
require 'spec'
require 'rack/test'
require 'pp'

set :environment, :test

describe "Submission Service" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before(:each) do
    header "X_PACKAGE_NAME", "ateam"
    header "CONTENT_MD5", "cccccccccccccccccccccccccccccccc"
  end

  it "returns 405 on GET" do
    get '/'

    last_response.status.should == 405
  end

  it "returns 405 on DELETE" do
    delete '/'

    last_response.status.should == 405
  end

  it "returns 405 on HEAD" do
    head '/'

    last_response.status.should == 405
  end

  it "returns 400 on POST if request is missing X-Package-Name header" do
    header "X_PACKAGE_NAME", nil

    post "/", "FOO"

    last_response.status.should == 400
    last_response.body.should == "Missing header: X_PACKAGE_NAME" 
  end

  it "returns 400 on POST if request is missing Content-MD5 header" do
    header "CONTENT_MD5", nil

    post "/", "FOO"

    last_response.status.should == 400
    last_response.body.should == "Missing header: CONTENT_MD5" 
  end

  it "returns 400 on POST if there is no body" do
    post "/"

    last_response.status.should == 400
    last_response.body.should == "Missing body" 
  end

  it "returns 400 on POST if md5 checksum of body does not match md5 query parameter" do
  end
end
