require 'bundler'
Bundler.setup

require 'ruby-debug'
require 'daitss/proc/wip/process'

app_file = File.join File.dirname(__FILE__), *%w[.. .. app.rb]
require app_file

# Force the application name because polyglot breaks the auto-detection logic.
Sinatra::Application.app_file = app_file
Sinatra::Application.set :environment, :test

require 'net/http'
require 'spec/expectations'
require 'rack/test'
require 'webrat'
require 'nokogiri'

require 'daitss/db/ops'

Webrat.configure do |config|
  config.mode = :rack
end

class MyWorld
  include Rack::Test::Methods
  include Webrat::Methods
  include Webrat::Matchers

  Webrat::Methods.delegate_to_session :response_code, :response_body

  def app
    Sinatra::Application
  end

  def sip name
    File.join File.dirname(__FILE__), '..', 'fixtures', name
  end

  def sip_tarball name
    path = sip name
    tar = %x{tar -c -C #{File.dirname path} -f - #{File.basename path} }
    raise "tar did not work" if $?.exitstatus != 0
    tar
  end

  def sips
    @sips ||= []
  end

  def submit name
    sips << {:sip => name}
    sip_path = sip 'haskell-nums-pdf'
    url = URI.parse "#{Daitss::CONFIG['submission']}/"
    req = Net::HTTP::Post.new url.path
    tar = %x{tar -c -C #{File.dirname sip_path} -f - #{File.basename sip_path} }
    raise "tar did not work" if $?.exitstatus != 0
    req.body = tar
    req.content_type = 'application/tar'
    req.basic_auth 'operator', 'operator'
    req['X-Package-Name'] = File.basename sip_path
    req['Content-MD5'] = Digest::MD5.hexdigest(req.body)
    req['X-Archive-Type'] = 'tar'

    res = Net::HTTP.start(url.host, url.port) do |http|
      http.read_timeout = Daitss::CONFIG['http-timeout']
      http.request req
    end

    debugger unless Net::HTTPSuccess === res
    res.error! unless Net::HTTPSuccess === res
    doc = Nokogiri::XML res.body
    id = (doc % 'IEID').content
    sips.last[:wip] = id
    ws = Workspace.new Daitss::CONFIG['workspace']
    wip = ws[id]
    wip
  end

  def empty_out_workspace
    ws = Workspace.new Daitss::CONFIG['workspace']

    ws.each do |wip|
      wip.stop if wip.running?
      FileUtils.rm_r wip.path
    end

  end

end

World{MyWorld.new}

Before do
  DataMapper.setup :default, Daitss::CONFIG['database-url']
  DataMapper.auto_migrate!

  a = Account.new(
    :name => 'The Test Account',
    :code => 'ACT'
  )

  o = Operator.new(
    :description => "operator",
    :active_start_date => Time.at(0),
    :active_end_date => Time.now + (86400 * 365),
    :identifier => 'operator',
    :first_name => "Op",
    :last_name => "Perator",
    :email => "operator@ufl.edu",
    :phone => "666-6666",
    :address => "FCLA"
  )

  k = AuthenticationKey.new :auth_key => Digest::SHA1.hexdigest('operator')
  o.authentication_key = k

  p = Project.new(
    :name => 'The Test Project',
    :code => 'PRJ'
  )

  a.operations_agents << o
  a.projects << p
  a.save or raise "could not save account"

  $cleanup = []
end

After do
  ws = Workspace.new Daitss::CONFIG['workspace']

  ws.each do|w|
    w.kill if w.running?
    FileUtils.rm_rf w.path
  end

  $cleanup.each { |f| FileUtils.rm_rf f }
end
