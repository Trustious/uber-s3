require 'typhoeus'

HYDRA = ::Typhoeus::Hydra.new

module UberS3::Connection
  class Typhoeus < Adapter
    
    def request(verb, url, headers={}, body=nil)
      # TODO: see extra steps done in NET::HTTP adapter
      params = {}
      params[:headers] = headers
      params[:method] = verb.to_sym
      params[:body] = body if body

      r = ::Typhoeus::Request.new(url, params)
      HYDRA.queue(r)
      HYDRA.run

      UberS3::Response.new({
        :status => r.response.code,
        :header => r.response.headers,
        :body   => r.response.body,
        :raw    => r.response
      })
    end
    
  end
end
