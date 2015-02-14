class MyHttpRequest
  attr_reader :method, :path, :http_version, :header

  def self.create(sock, method, path, http_version)
    header = MyHttpRequest.read_header(sock)
    MyHttpRequest.new(method, path, http_version, header)
  end

  def initialize(method = nil, path = nil, http_version = nil, header = nil)
    @method = method || 'GET'
    @path = path || ''
    @http_version = http_version || 'HTTP/1.1'
    @header = header
  end

  private
  def self.read_header(sock)
    header = {}
    while line = sock.gets
      break if line == "\r\n"
      key, value = line.chomp.split(/: /, 2)
      header[key] = value
    end
    header
  end
end
