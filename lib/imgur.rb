require 'yaml'
require 'logger'
require 'rest-client'
require 'net/https'

class Imgur

  attr_accessor :url, :path, :parser, :logger, :config, :authorize_path, :token_path
  CONFIG_PATH = '~/.imgurrc.resposter'

  def initialize(options={})
    @config = options[:config] || YAML.load_file(File.expand_path(CONFIG_PATH)) || YAML.load_file("config/config.yml")
    @authorize_path = "/oauth2/authorize"
    @token_path = "/oauth2/token"
    @url = URI.parse(options[:url] || "https://api.imgur.com/")
    @logger = options[:logger] || Logger.new(nil)
    @parser = begin ; require 'json'; JSON;end
    @connection = RestClient::Resource.new(@url)
  end

  # Very helpful to keep an access token from expiring
  # If you use before every call, this WILL probably use up extra API calls (limited by Imgur)
  def refresh_token
    response = RestClient.post(
      @url.to_s + @token_path,
      :client_id     => @config[:client_id],
      :client_secret => @config[:client_secret],
      :refresh_token => @config[:refresh_token],
      :grant_type    => 'refresh_token',
    )
    new_params = @parser.load(response)
    @config[:access_token] = new_params['access_token']
    @config[:refresh_token] = new_params['refresh_token']
    File.open(File.expand_path(CONFIG_PATH), 'w') { |f| YAML.dump(@config, f) }
    self.reset!
    true
  end

  # @return [Object]
  def refresh_old_image_list

    puts 'checking for new images from Imgur...'
    puts ''

    _get_from_imgur URI("#{@url}3/gallery/hot/time/#{@config[:start_page]}?showViral=true")
  end

  def reset!
    @config     = nil
    @config     = YAML.load_file(File.expand_path(CONFIG_PATH))
  end

  def upload_image(post)
   uri = URI('https://api.imgur.com/3/image')
   data = {
       image: post['link'],
       type: 'url',
       title: post['title'],
       description: "http://imgur.com/gallery/#{post['id']}"
   }

   puts 'uploading image to Imgur...'

    _post_to_imgur uri, data
  end

  def submit_to_gallery(id, post)
    uri = URI("https://api.imgur.com/3/gallery/#{id}")
    data = {
        :title => post['title'],
        :description => "http://imgur.com/gallery/#{post['id']}",
        :terms => 1
    }

    puts 'submitting to gallery...'

     _post_to_imgur uri, data
  end

  def get_latest_images
   _get_from_imgur URI("#{@url}3/gallery/user/time/0?showViral=false")
  end

  def submit_comment(id, comment)

    uri = URI("#{@url}3/comment")
    data = {
        :image_id => id,
        :comment => comment
    }

    _post_to_imgur uri, data
  end

  private

  # @param [URI] uri
  # @param [Hash] data
  def _post_to_imgur(uri, data)
    http = _generate_http_object uri

    refresh_token

    request = Net::HTTP::Post.new uri
    request.add_field('Authorization', "Bearer #{@config[:access_token]}")

    request.form_data = data

    response = _submit_request http, request

    _handle_response response
  end

  # @param [URI] uri
  def _get_from_imgur(uri)
    http = _generate_http_object uri

    request = Net::HTTP::Get.new uri
    request.add_field('Authorization', "Client-ID #{@config[:client_id]}")

    response = _submit_request http, request

    _handle_response response
  end

  # @param [Object] uri
  # @return [Net::HTTP]
  def _generate_http_object(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    http
  end

  # @return [Object]
  # @param [Object] http
  # @param [Object] request
  def _submit_request(http, request)
    http.start do |http_object|
      http_object.request request
    end
  end

  def _handle_response(response)
    response_json = JSON::parse(response.body)

    if response_json['success']
      response_json['data']
    else
      false
    end
  end
    
end