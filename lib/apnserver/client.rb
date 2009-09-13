require 'openssl'
require 'socket'

module ApnServer
  class Client
    
    attr_accessor :pem, :host, :port, :password
    
    def initialize(pem, host = 'gateway.push.apple.com', port = 2195, pass = nil)
      @pem, @host, @port, @password = pem, host, port, pass
    end
    
    def connect!
      raise "The path to your pem file is not set." unless self.pem
      raise "The path to your pem file does not exist!" unless File.exist?(self.pem)
      
      @context      = OpenSSL::SSL::SSLContext.new
      @context.cert = OpenSSL::X509::Certificate.new(File.read(self.pem))
      @context.key  = OpenSSL::PKey::RSA.new(File.read(self.pem), self.password)
      
      @sock         = TCPSocket.new(self.host, self.port)
      @ssl          = OpenSSL::SSL::SSLSocket.new(@sock, @context)
      @ssl.connect
      
      return @sock, @ssl
    end
    
    def disconnect!
      @ssl.close
      @sock.close
    end
    
    def write(notification)
      puts "#{Time.now} [#{host}:#{port}] sending #{notification.alert}"
      @ssl.write(notification.to_bytes)
    end
    
    def connected?
      @ssl
    end
  end
end