require 'yaml'
require 'logger'
require 'rest-client'
require 'net/https'

require_relative 'imgur/base'

class Imgur < ImgurBase

  # @return [Object]
  def refresh_old_image_list

    puts 'checking for new images from Imgur...'
    puts ''

    _get_from_imgur URI("#{@url}3/gallery/hot/time/#{@config[:start_page]}?showViral=true")
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
    
end