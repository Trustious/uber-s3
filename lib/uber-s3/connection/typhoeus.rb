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
            r.on_complete do |response|
                begin
                    result = UberS3::Response.new({
                        :status => response.code,
                        :header => response.headers,
                        :body   => response.body,
                        :raw    => response
                    })
                rescue
                    puts '#'*50, 'error handling request, will retry', url, params, result.inspect
                    r2 = ::Typhoeus::Request.new(url, params)
                    r2.on_complete do |response2|
                        begin
                            result = UberS3::Response.new({
                                :status => response2.code,
                                :header => response2.headers,
                                :body   => response2.body,
                                :raw    => response2
                            })
                        rescue
                            puts '#'*50, 'error handling request gave up', url, params, result.inspect
                        end
                        result
                    end
                    HYDRA.queue(r2)
                    result
                end
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
