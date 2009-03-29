Before do
  @handler = AipHandler.new
  @httpd = Mongrel::HttpServer.new "0.0.0.0", "3003"
  @httpd.register "/archive", @handler
  @httpd.run

  url = "http://#{@httpd.host}:#{@httpd.port}/archive"
  @archive = Archive.new url

  @errors = []
end

After do
  @httpd.stop
end
