require 'erb'
require './my_http_server'

def create_expiration_time
  past = Time.now.getgm - 1
  past.strftime('%a, %d %b %Y %H:%M:%S %Z')
end

def main
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

    <a href="delete-cookie.html">Delete cookie</a>
  </body>
</html>
EOD
    erb.result(binding)
  end

  http_server.add_content('GET', '/delete-cookie.html') do |request, response|
    response.add_cookie("count=; expires=#{create_expiration_time}")
    erb = ERB.new(<<EOD)
<html>
  <body>
    Cookie Deleted.
    <a href="/">Home</a>
  </body>
</html>
EOD
    erb.result(binding)
  end

  http_server.run
end

main if $0 == __FILE__
