require './my_http_server'

if $0 == __FILE__
  http_server = MyHttpServer.new(8881)

  http_server.add_content('GET', '/') do |request, response|
    response.add_cookie('NAME=VALUE')
    response.add_cookie('COUNT=1')

    <<EOD
<html>
  <body>
    Hello, <font style="color:red">my server</font>!
  </body>
</html>
EOD
  end

  http_server.run
end
