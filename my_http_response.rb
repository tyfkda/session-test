class MyHttpResponse
  OK = 200
  BAD_REQUEST = 400
  NOT_FOUND = 404

  STATUS_MESSAGE = {
    OK => 'OK',
    BAD_REQUEST => 'Bad Request',
    NOT_FOUND => 'Not Found',
  }

  def initialize(sock)
    @sock = sock

    @header = {
      'Content-Type' => 'text/html',
    }
    @cookies = []
  end

  def add_header(header)
    @response_header.merge!(header)
  end

  def add_cookie(cookie)
    @cookies.push(cookie)
  end

  def handle_request(request, callable)
    response_body = callable.call(request, self)

    return_status_line(request, OK)
    @sock.print("Content-Length: #{response_body.length}\r\n")
    @sock.print(@header.map{|k, v| "#{k}: #{v}\r\n"}.join())
    @cookies.each do |line|
      @sock.print("Set-Cookie: #{line}\r\n")
    end
    @sock.print("\r\n")
    @sock.print(response_body)
  end

  def print(value)
    @sock.print(value)
  end

  def error(request, code)
    $stderr.puts("ERROR: #{code} #{STATUS_MESSAGE[code]}")
    return_status_line(request, code)
    @sock.print("\r\n")
    @sock.print("#{code} #{STATUS_MESSAGE[code]}")
  end

  def return_status_line(request, code)
    @sock.print("#{request.http_version} #{code} #{STATUS_MESSAGE[code]}\r\n")
  end
end
