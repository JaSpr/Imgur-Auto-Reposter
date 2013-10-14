require 'rubygems'
require 'json'
require 'net/https'
require 'etc'
require 'win32/process'
require 'imgur'

class App
    
  def initialize

    @queue   = []
    @in_queue = []
    @client = Imgur::Client.new(config_path: '~/.imgurrc.resposter')

    puts 'starting...'
    puts ''

    # Thread for retrieving old images
    Thread.new do
      while true do
        begin
          @client.refresh_token

          images = @client.images.all(resource: 'gallery', section: 'hot', sort: 'time', page: 823)
          if images
            images.each do |image|
              if image
                @queue.push image unless @in_queue.include? image.id or image.is_album
                @in_queue.push image.id
              end
            end

            puts "Check complete, items in queue: #{@queue.length}"
            puts ''
          end

          sleep 1800
        rescue => exc
          puts "thread 1: #{exc.message}"
          puts exc.backtrace
          puts ''

          sleep 10
        end

      end

    end

    # thread for reposting a single image periodically
    Thread.new do

      sleep 2

      while true do
        begin
          @client.refresh_token

          if @queue.length > 0

            puts "#{@queue.length} items in queue"

            source = @queue.shift

            puts "uploading image... #{source.id}"
            image = @client.images.upload(
                {
                    image: source.link,
                    type: 'url',
                    title: source.title,
                    description: "http://imgur.com/gallery/#{source.id}"
                }
            )

            puts "adding image #{image.id} to gallery"

            image.add_to_gallery(
                {
                    title: source.title,
                    description: "http://imgur.com/gallery/#{source.id}",
                    terms: 1
                }
            )

            puts;

            delay = rand(60...1800)

            puts "sleeping for #{delay} seconds..."
            puts;

            sleep delay
          else
            puts 'waiting for items in queue... '
            sleep 10
          end
        rescue => exc
          puts "thread 2: #{exc.message}"
          puts exc.backtrace
          puts ''
          sleep 10
        end
      end

    end

  end
    
end

App.new
sleep
