class OSDI
  attr_accessor :api_token, :aep_url, :request_content_type, :psh_url, :hc, :debug, :proxy

  require 'hyperclient'

  def initialize(options={})
    @api_token=options[:api_token]
    @aep_url=options[:aep_url]
    @debug=options[:debug]
    @proxy=options[:proxy_url]
    @request_content_type=options[:request_content_type]
  end

  def hyperclient
    connection_options={}
    osdi=::Hyperclient.new(@aep_url) do |client|
      client.headers['OSDI-API-Token']=@api_token
      client.connection(connection_options) do |conn|
        conn.use Faraday::Response::RaiseError
        conn.use FaradayMiddleware::FollowRedirects
        conn.response :detailed_logger if @debug
        conn.adapter :net_http
        conn.request :hal_json
        conn.response :hal_json, content_type: /\bjson$/
        conn.proxy proxy if @proxy
        conn.options[:open_timeout] = 5
        conn.options[:timeout] = 30
        #conn.response :json
      end


    end
    content_type= @request_content_type || 'application/json'
    osdi.headers.update('Content-Type' => content_type)
    @hc=osdi
    osdi

  end


  def psh
    self.hyperclient unless @hc

  end

  def system_tags
    self.hc||=self.hyperclient
    tags=hc['osdi:tags']['osdi:tags']

  end
  def signup(signup_obj)
    self.hc||=self.hyperclient
    psh=hc._links['osdi:person_signup_helper']
    json=Mixer.clean(signup_obj).to_json

    psh._post(json)

  end
end