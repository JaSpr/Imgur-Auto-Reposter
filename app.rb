require 'rubygems'
require 'json'
require 'net/https'
require 'etc'
require 'win32/process'
require_relative 'lib/imgur'

class App
    
  def initialize

    @queue   = []
    @in_queue = []

    puts 'starting...'
    puts ''

    @imgur = Imgur.new

    # Thread for retrieving old images
    Thread.new do
      puts "running thread 1...\r\n\r\n"
      while true do
        begin
          images = @imgur.refresh_old_image_list

          if images
            images.each do |image|
              if image
                @queue.push image unless @in_queue.include? image['id'] or image['is_album'].eql? true
                @in_queue.push image['id']
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
      puts 'running thread 2...'
      puts ''

      while true do
        begin
          if @queue.length > 0

            puts "#{@queue.length} items in queue"

            post = @queue.shift

            image = @imgur.upload_image post

            puts "found image #{image['id']}"

            response = @imgur.submit_to_gallery image['id'], post unless image['id'].nil? or image['id'].eql? '' or image['id'].eql? 0

            puts response.to_s
            puts ''

            sleep rand(60...1800)
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
