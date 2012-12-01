require 'typhoeus'

HYDRA = ::Typhoeus::Hydra.new(:max_concurrency => 100)

module UberS3::Connection
  class Typhoeus < Adapter
    
    def request(verb, url, headers={}, body=nil)
      # TODO: see extra steps done in NET::HTTP adapter
      params = {}
      params[:headers] = headers
      params[:method] = verb.to_sym
      params[:body] = body if body

      r = ::Typhoeus::Request.new(url, params)
      result = r.on_complete do |response|
          puts 'INSIDE callback'
          UberS3::Response.new({
              :status => response.code,
              :header => response.headers,
              :body   => response.body,
              :raw    => response
          })
      end
      HYDRA.queue(r)
      UberS3::Response.new({
          :status => 200,
          :header => "",
          :body   => "",
          :raw    => ""
      })
    end
    
  end
end
