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
      return MyHttpResponse.new(sock, MyHttpRequest.new).error(MyHttpResponse::BAD_REQUEST)
    end

    request_header = read_request_header(sock) if method
    request = MyHttpRequest.new(method, path, http_version, request_header)
    response = MyHttpResponse.new(sock, request)

    puts "Accept request for #{method}[#{path}], #{request_header.inspect}"
    return_response_for_path(response)
  end

  def return_response_for_path(response)
    unless @contents.has_key?(response.request.method) && @contents[response.request.method].has_key?(response.request.path)
      return response.error(MyHttpResponse::NOT_FOUND)
    end

    content = @contents[response.request.method][response.request.path]
    if content.respond_to?(:call)
      return response.handle_request(content)
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

  def read_request_header(sock)
    header = {}
    while line = sock.gets
      break if line == "\r\n"
      key, value = line.chomp.split(/:\s?/, 2)
      header[key] = value
    end
    header
  end
end
