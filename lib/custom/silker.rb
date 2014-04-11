require 'rest-client'

class Silker

  attr_accessor :silk_sid
  attr_accessor :site_name

  SILK_API_URL    = 'https://api.silk.co/v1.12.5'
  SILK_DOMAIN     = 'silk.co'
  REQUEST_SUFFIX  = '/?type=json'


  class << self

    def authenticate( email, password )
      begin
        result = RestClient.post  "#{ SILK_API_URL }"'/user/signin', 
                                "<signin><email>#{ email }</email><password>#{password}</password></signin>" , 
                                {:content_type => :xml} rescue nil

        if result.code == 200 and result.cookies and result.cookies['silk_sid']
          sid = CGI.unescape( result.cookies['silk_sid'] ).gsub('"', '')
        end
      rescue => e 
        sid = nil
      end
      sid
    end
  end
    
  def initialize( silk_sid, site_name )
    self.silk_sid = silk_sid
    self.site_name = site_name
  end

  def my_site
    "#{self.site_name}.#{ SILK_DOMAIN }"
  end
 
#$ curl https://api.silkapp.com/v1.4.0/site/uri/mysite.silkapp.com/permission
#-b 'silk_sid=...' 
# {:cookies => {:session_id => "1234"}
  
  def permissions 
    begin
      result = RestClient.get "#{ SILK_API_URL }/site/uri/#{ self.my_site }/permission#{ REQUEST_SUFFIX }",
               { cookies: { silk_sid: self.silk_sid } }
    rescue => e
      result = nil
    end
    JSON.parse result
  end


# curl https://api.silkapp.com/v1.4.0/site/uri/site.silkapp.com/page/home
# -b 'silk_sid=...'
  def get_private_page_html( page )
    begin
      result = RestClient.get "#{ SILK_API_URL }/site/uri/#{ self.my_site }/page/#{page}/",
               { cookies: { silk_sid: self.silk_sid } }
    rescue => e
      result = nil
    end
    result
  end

=begin
$ curl https://api.silkapp.com/v1.4.0/site/uri/yoursite.silkapp.com/page/test
-d '<article>...</article>'
-b 'silk_sid=...'
-X PUT
-H 'Content-Type: application/xml'

        result = RestClient.post  "#{ SILK_API_URL }"'/user/signin', 
                                "<signin><email>#{ email }</email><password>#{password}</password></signin>" , 
                                {:content_type => :xml} rescue nil


=end

  def create_or_update_page( page, article )
    begin
      result = RestClient.put "#{ SILK_API_URL }/site/uri/#{ self.my_site }/page/#{page}/",
                article,
               { cookies: { silk_sid: self.silk_sid }, content_type: :xml }
    rescue => e
      result = nil
    end
    result
  end

=begin
$ curl https://api.silkapp.com/v1.4.0/site/uri/yoursite.silkapp.com/taglist
 
# Get the taglist for a public or private site (with authentication)
 
$ curl https://api.silkapp.com/v1.4.0/site/uri/yoursite.silkapp.com/taglist
-b 'silk_sid=...'
=end

  def get_taglist
    begin
      result = RestClient.get "#{ SILK_API_URL }/site/uri/#{ self.my_site }/taglist",
               { cookies: { silk_sid: self.silk_sid } }
    rescue => e
      result = nil
    end
    result
  end

  def bombard!( times, thread_counter = nil ) 
    f = File.open( Rails.root.to_s + '/test/sample_article.xml' )
    the_xml = f.read
    for i in 0...times 
      page_name = "bombard_#{Time.now.to_i.to_s}_#{ rand(100000) }"
      Rails.logger.info "#{ i+1 }... Uploading file #{ page_name } - #{ Time.now.to_s } -- #{ thread_counter.nil? ? '' : thread_counter }"
      result = self.create_or_update_page(page_name, the_xml)
      Rails.logger.info ""
    end
    
    Rails.logger.info ".... Time End : #{Time.now}"

  end

  def threaded_bombard!( thread_count, times )
    Rails.logger.info "... Time start:; #{Time.now}"
    for i in 1..thread_count do 
      puts "... generating thread #{i}..." 
      Thread.new { 
        self.bombard!( times ) 
      }
      puts "... done..."
    end
  end

end
