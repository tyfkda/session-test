class MyHttpRequest
  attr_reader :method, :path, :http_version, :request_header

  def initialize(method = nil, path = nil, http_version = nil, request_header = nil)
    @method = method || 'GET'
    @path = path || ''
    @http_version = http_version || 'HTTP/1.1'
    @request_header = request_header
  end
end
