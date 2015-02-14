require 'erb'
require './my_http_server'

if $0 == __FILE__
  http_server = MyHttpServer.new(8881)

  http_server.add_content('GET', '/') do |request, response|
    if request.header.has_key?('Cookie')
      cookies = Hash[*request.header['Cookie'].split('; ').map {|kv| kv.split('=', 2)}.flatten]
    else
      cookies = {}
    end

    count = cookies.has_key?('count') ? cookies['count'].to_i : 0
    count += 1

    response.add_cookie("count=#{count}")

    erb = ERB.new(<<EOD)
<html>
  <body>
    <p>
      Hello, <font style="color:red">my server</font>!
    </p>
    <p>
      Count: <%= count %>
    </p>
  </body>
</html>
EOD
    erb.result(binding)
  end

  http_server.run
end
