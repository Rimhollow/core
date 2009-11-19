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
  end

  it "returns 400 on GET" do
    get '/'

    last_response.status.should == 400
  end

  it "returns 400 on DELETE" do
    delete '/'

    last_response.status.should == 400
  end

  it "returns 400 on HEAD" do
    head '/'

    last_response.status.should == 400
  end

  it "returns 400 on POST if request is missing X-Package-Name header" do
    post '/', {:md5 => "cccccccccccccccccccccccccccccccc"}

    last_response.status.should == 400
    last_response.body.should == "Missing parameter: package_name"
  end

  it "returns 400 on POST if request is missing Content-MD5 header" do
    post '/', {:package_name => "ateam"}

    last_response.status.should == 400
    last_response.body.should == "Missing parameter: md5"
  end
end
