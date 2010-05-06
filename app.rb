require 'sinatra'
require 'haml'
require 'sass'
require 'net/http'
require 'nokogiri'

require 'workspace'
require 'wip/process'
require 'wip/state'
require 'wip/json'
require 'daitss/config'

require 'datamapper'
require 'dm-aggregates'
require 'aip'
require 'db/sip'

configure do
  raise "no configuration" unless ENV['CONFIG']
  Daitss::CONFIG.load ENV['CONFIG']

  set :workspace, Workspace.new(Daitss::CONFIG['workspace'])
  DataMapper.setup :default, Daitss::CONFIG['database-url']
end

helpers do

  def submit
    error 400, 'file upload parameter "sip" required' unless params['sip']
    tempfile = params['sip'][:tempfile]
    filename = params['sip'][:filename]
    sip_name = filename[ %r{^(.+)\.\w+$}, 1]
    type = filename[ %r{^.+\.(\w+)$}, 1]

    url = URI.parse "#{Daitss::CONFIG['submission-url']}"
    req = Net::HTTP::Post.new url.path
    req.body = tempfile.read
    req.content_type = 'application/tar'
    req.basic_auth 'operator', 'operator'
    req['X-Package-Name'] = sip_name
    req['Content-MD5'] = Digest::MD5.hexdigest(req.body)
    req['X-Archive-Type'] = type

    res = Net::HTTP.start(url.host, url.port) do |http|
      http.read_timeout = Daitss::CONFIG['http-timeout']
      http.request req
    end

    res.error! unless Net::HTTPSuccess === res
    doc = Nokogiri::XML res.body
    (doc % 'IEID').content
  end

end

get '/stylesheet.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :stylesheet
end

get '/' do
  haml :index
end

get '/submit' do
  haml :submit
end

post '/submit' do
  id = submit
  redirect "/workspace/#{id}"
end

get '/workspace' do

  if request.accept.include? 'application/json'
    settings.workspace.to_json
  else
    haml :workspace
  end

end

post '/workspace' do

  case params['task']
  when 'start'
    startable = settings.workspace.reject { |w| w.running? || w.done? }
    startable.each { |wip| wip.start_task }

  when 'stop'
    stoppable = settings.workspace.select { |w| w.running? }
    stoppable.each { |wip| wip.stop }

  when 'unsnafu'
    unsnafuable= settings.workspace.select { |w| w.snafu? }
    unsnafuable.each { |wip| wip.unsnafu! }

  when nil, '' then error 400, "parameter task is required"
  else error 400, "unknown command: #{params['task']}"
  end

  redirect '/workspace'
end

get '/workspace/:id' do |id|
  @wip = settings.workspace[id] or not_found

  if request.accept.include? 'application/json'
    @wip.to_json
  else
    haml :wip
  end

end

post '/workspace/:id' do |id|
  wip = settings.workspace[id] or not_found

  case params['task']
  when 'start'
    error 400, 'cannot start a running wip' if wip.running?
    wip.start_task

  when 'stop'
    error 400, 'cannot stop an idle wip' unless wip.running?
    wip.stop

  when 'unsnafu'
    error 400, 'can only unsnafu a snafu wip' unless wip.snafu?
    wip.unsnafu!

  when 'stash'
    error 400, 'parameter path is required' unless params['path']
    error 400, "#{params['path']} is not a directory" unless File.directory? params['path']
    FileUtils::mv wip.path, params['path']
    redirect '/'

  when nil, '' then raise 400, 'parameter task is required'
  else error 400, "unknown command: #{params['task']}"
  end

  redirect wip.id
end
