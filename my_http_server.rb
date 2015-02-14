require 'socket'
require './my_http_request'
require './my_http_response'

class MyHttpServer
  URL_CHARS = %r!a-zA-Z0-9_%/\.\-!

  def initialize(port)
    @port = port
    @contents = Hash.new {|hash, key| hash[key] = {}}
  end

  def add_content(method, path, result = nil, &block)
    @contents[method.upcase][path] = result || block
  end

  def run
    tcp_server = TCPServer.open('', @port)
    puts "Waiting on port #{tcp_server.addr[1]}..."
    while true
      #Thread.start(tcp_server.accept) do |sock|       # save to dynamic variable
      sock = tcp_server.accept
        handle_request(sock)
        sock.close
      #end
    end
  end

  def handle_request(sock)
    method, path, http_version = read_header_top(sock)
    unless method
      return MyHttpResponse.new(sock).error(MyHttpRequest.new, MyHttpResponse::BAD_REQUEST)
    end

    request = MyHttpRequest.create(sock, method, path, http_version)
    response = MyHttpResponse.new(sock)

    puts "Accept request for #{method}[#{path}], #{request.header.inspect}"
    return_response_for_path(request, response)
  end

  def return_response_for_path(request, response)
    unless @contents.has_key?(request.method) && @contents[request.method].has_key?(request.path)
      return response.error(request, MyHttpResponse::NOT_FOUND)
    end

    content = @contents[request.method][request.path]
    if content.respond_to?(:call)
      return response.handle_request(request, content)
    end

    sock.print(content)
  end

  def read_header_top(sock)
    # Get HTTP request header.
    top = sock.gets
    unless top && top.chomp =~ %r!(GET|POST) ([#{URL_CHARS}]*) (HTTP/\d.\d+)$!
      return nil, nil, nil
    end
    return $1, $2, $3
  end
end
