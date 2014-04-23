require 'openssl'
require 'base64'

module ApplicationHelper
  def cipher
    OpenSSL::Cipher::Cipher.new('aes-256-cbc')
  end
  
  def cipher_key
    'blah!'
  end
  
  def decrypt(value)
    c = cipher.decrypt
    c.key = Digest::SHA256.digest(cipher_key)
    c.update(Base64.decode64(value.to_s)) + c.final
  end
  
  def encrypt(value)
    c = cipher.encrypt
    c.key = Digest::SHA256.digest(cipher_key)
    Base64.encode64(c.update(value.to_s) + c.final)
  end

  def silk_toc( items )
    list = ''
    items.each_with_index do |item,index|
      list = list + "<li data-level=\"1\"><span>#{index+1}</span><a>#{item}</a></li>"
    end
    return silk_block( '<div data-component-uri="//silk.co/widget/toc/1" data-depth="3" class="toc">
      <div class="title"><span>Table of Contents</span></div>
        <ul>
          '+list+'
        </ul>
      </div>
    </div>' )
  end
  
  def silk_block( content )
    return '<div data-component-uri="//silk.co/block/simple/1" class="block">'+content+'</div>'
  end
  
  def silk_layout_meta( title )
    return '<div class="layout meta">'+silk_block( silk_text( "<h1 style=\"text-align:center\">#{title}</h1>" ) )+'</div>'
  end
  
  def silk_layout_content( id, title, content, items )
    html_silk_content = '<div class="layout content">'
    
    #html_silk_content = html_silk_content + '<div id="product-bar" style="display:block; width:1px; height:1px; float:right; overflow: visible;"><a href="'+page_edit_url(key: encrypt(id), silk_identifier: title)+'" class="toolbar-button action edit-page" style="color: #ffffff; width: 100px;">Edit Page</a></div>'
    puts silk_toc( items )
    
    html_silk_content = html_silk_content + silk_toc( items )
    
    html_silk_content = html_silk_content + silk_block( silk_text( content ) )
    
    
    html_silk_content = html_silk_content + '</div>'
    
    return html_silk_content
  end
  
  def silk_text( content )
    return silk_block('<div data-component-uri="//silk.co/widget/text/1" class="text"><div class="block-content" contenteditable="false">'+content.gsub("\n","")+'</div></div>')
  end
  
  def silk_closure(title, meta, contents)
    html = '<article data-article="" data-format="1" data-title="'+title+'"><section class="body">'
    
    html = html + meta
    html = html + contents
    
    return html + '</section></article>'
  end
  
  def information_page(title, contents, toc)
    
    s_silk_page = silk_closure(title, silk_layout_meta( title ), silk_layout_content( 1, title, contents, toc ))
    
    puts "\n\nsilker.create_or_update_page( '#{URI.encode(title)}', '#{dummy('China', 'Overview', contents)}' )\n\n"
    dummy('China','Overview',contents)
#     s_silk_page
#     silk_result = silker.create_or_update_page( URI.encode(title), s_silk_page )
#     puts "Response from Silk API: #{!silk_result.nil?}"
#     !silk_result.nil?
  end
  
  
  def parse_visio(contents)
      contents.gsub(/@\b(\S*)\b!/, '<div data-component-uri="//silk.co/widget/queryviewer/1" data-queryview-uri="\1"></div>')
  end
  
  def reverse_visio(contents)
    contents.gsub(/<div data-component-uri=\"\/\/silk.co\/widget\/queryviewer\/1\" data-queryview-uri=\"(\S*)\"><\/div>/, '@\1!')
  end
  
  
  def dummy(country, section, contents)
    '
    <article data-article="" data-format="1" data-title="'+"#{country} #{section}"+'" data-tag-context="/tag/Country Information">
      <section class="body">
        <div class="layout meta">
          <div data-component-uri="//silk.co/block/simple/1" class="block">
            <div data-component-uri="//silk.co/widget/text/1" class="text">
              <p>Back to <a href="/page/'+country+'">'+country+' Startup Wiki</a> page</p>
            </div>
          </div>
          <div data-component-uri="//silk.co/block/simple/1" class="block">
            <div data-component-uri="//silk.co/widget/text/1" class="text">
            
              <a href="/page/'+country+'%20Overview"><b>1. Country Overview</b></a>
              
              <div>   <a href="/page/'+country+'%20Overview">At a Glance</a>
              </div>
          
              <div>   <a href="/page/'+country+'%20Overview">Taking A Closer Look</a>
              </div>
              <div>
                <a href="/page/'+country+'%20Ecosystem"><b>2. Startup Ecosystem</b></a></div>
                
              <div>   <a href="/page/'+country+'%20Ecosystem">Notable Startups</a>
              </div>
              
              <div>   <a href="/page/'+country+'%20Ecosystem">Investors</a>
              </div>
              
              <div>   <a href="/page/'+country+'%20Ecosystem">Community</a>
              </div>
              
              <div>   <a href="/page/'+country+'%20Ecosystem">Local Heroes</a>
              </div>
              
              <div>   <a href="/page/'+country+'%20Ecosystem">Government Institutions</a>
              </div>
              
              <div><a href="/page/'+country+'%20Opportunities"><b>3. Opportunities</b></a></div>
              
              <div>   <a href="/page/'+country+'%20Opportunities">Opportunities at a Glance</a>
              </div>
              
              <div>   <a href="/page/'+country+'%20Opportunities">Competitive Advantages</a>
              </div>
              
              <div>   <a href="/page/'+country+'%20Opportunities">Competitive Disadvantages</a>
              </div>
              
              <div>   <a href="/page/'+country+'%20Opportunities">Challenges</a>
              </div>
              
              <div><a href="/page/'+country+'%20Controversies"><b>4. Controversies</b></a></div>
              <div>   <a href="/page/'+country+'%20Controversies">Controversies Overview</a>
              </div>
              
              <div><a href="/page/'+country+'%20Cultural%20Awareness"><b>5. Cultural Awareness</b></a></div>
              
              <div>   <a href="/page/'+country+'%20Cultural%20Awareness">Culture Overview</a>
              </div>
              
              <div>   <a href="/page/'+country+'%20Cultural%20Awareness">Cultural Similarities</a>
              </div>
              
              <div>   <a href="/page/'+country+'%20Cultural%20Awareness">Cultural Surprises</a>
              </div>
              
              <div><b><a href="/page/'+country+'%20Establishing%20Your%20Startup">6. Establishing Your Startup</a></b></div>
              
              <div>   <a href="/page/'+country+'%20Establishing%20Your%20Startup">Notable policies</a>
              </div>
              
              <div>   <a href="/page/'+country+'%20Establishing%20Your%20Startup">Talent Pool</a>
              </div>
              
              <div>   <a href="/page/'+country+'%20Establishing%20Your%20Startup">Visa</a>
              </div>
              
              <div><b><a href="/page/'+country+'%20Advice">7. Advice</a></b></div>
              
              <div>   <a href="/page/'+country+'%20Advice">Advice for Local Entrepreneurs</a>
              </div>
              
              <div>   <a href="/page/'+country+'%20Advice">Advice for Foreign Entrepren...</a>
              </div>
              
              <div>   <a href="/page/'+country+'%20Advice">Advice for Foreign Investors</a>
              </div>
              
              <div>   <a href="/page/'+country+'%20Advice">Advice for Foreign Companies</a>
              </div>

            </div>
          </div>
        </div>
        <div class="layout content">
          <div id="product-bar" style="display:block; width:1px; height:1px; float:right; overflow: visible;"><a href="'+information_edit_url(port: 80, host: 'contribute.worldstartupwiki.org', country: country, page: section)+'" class="toolbar-button action edit-page" style="color: #ffffff; width: 100px;">Edit Page</a></div>
        
          <div data-component-uri="//silk.co/block/simple/1" class="block"><div data-component-uri="//silk.co/widget/text/1" class="header text"><h1>'+country+' '+section+'</h1></div></div>
          
          <div data-component-uri="//silk.co/block/simple/1" class="block">
            <div data-component-uri="//silk.co/widget/toc/1" data-depth="3"/>
          </div>
    
          <div data-component-uri="//silk.co/block/simple/1" class="block">
            <div data-component-uri="//silk.co/widget/text/1" class="text">
              <div id="nerubia">'+contents+'</div>
            </div>
          </div>
        </div>
        <br/>
      </section>
    </article>
    '
  end
  
  
  
  
  
end
