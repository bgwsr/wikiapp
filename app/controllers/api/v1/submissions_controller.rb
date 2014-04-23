require 'json'
require 'custom/silker'
require 'redcarpet/compat'
class Api::V1::SubmissionsController < ApplicationController
  include ApplicationHelper
  
  def silker
    silk_sid = Silker.authenticate( ENV['SILK_EMAIL'], ENV['SILK_PASSWORD'] )
    silker = Silker.new( silk_sid, ENV['SILK_SITE'] )
    article = silker.get_private_page_html(URI.encode(params[:silk_identifier]))
    
    render :json => { :article => article }, :status => 200 and return
  end
  
  def silker_page
    silk_sid = ' '
    while silk_sid.nil? || silk_sid.include?(" ")
      silk_sid = Silker.authenticate( ENV['SILK_EMAIL'], ENV['SILK_PASSWORD'] )
    end
    
    silker = Silker.new( silk_sid, ENV['SILK_SITE'] )
    article = silker.get_private_page_html(URI.encode(params[:silk_identifier]))
    html_article = Nokogiri.HTML( article )
    render :json => {contents: reverse_visio(html_article.css('div#nerubia').children.to_s)}, :status => 200 and return
  end

  def create
    if current_user.present?
      if params[:id].present?
        s = Submission.where(id: params[:id])
        if s.present?
          s = s.first
        else
          archive = Archive.find(params[:id])
          s = Submission.new(archive.attributes)
          s.save
        end
        s.status = "pending"
      else
        s = Submission.new
        s.silk_identifier = URI.decode(params[:silk_identifier])
        s.user_id = current_user.id
        s.country = params[:country]
      end
      
      contents = ActiveSupport::JSON.decode(params[:content].to_json)
      contents['body'] = URI.decode(contents["body"])
  
      contents["tags"].each_with_index do |tag,index|
        tag.each do |key,value|
          contents["tags"][index][key] = URI.decode(value)
        end
      end
      s.content = contents.to_json

      if s.save
        recipient = User.select('GROUP_CONCAT(email) emails').where("countries = 'all' OR countries = ? OR countries LIKE ? OR countries LIKE ?", "#{s.country}", "#{s.country},%", "%,#{s.country}")
        if recipient.present?
          markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true, :filter_html => true)

          body = markdown.render(contents['body']).gsub("\n", "<br />")
          quick_accept_url = api_submissions_accept_url(k: encrypt(s.id), a: s.id)
          
          unless params[:id].present?
            SubmissionNotifier.need_verification(recipient.first.emails, s, body.html_safe, quick_accept_url).deliver
          end
          
        end
        
        render :json => { :info => s }, :status => 200, alert: "Your changes has been saved." and return
      end
    end
    
    failure
  end
  
  def update
    if current_user.present? and current_user.ambassador?
      submission = Submission.find(params[:id])
      if submission.present?
        if params[:status].present?
          submission.status = params[:status]
          archive = Archive.new( submission.attributes )
          SubmissionNotifier.moderated(submission.user.email, params[:status], params[:reason]).deliver
        end
        if submission.delete
          archive.id = nil
          archive.save
          render :json => { :info => submission }, :status => 200 and return
        end
      end
    end
    failure
  end
  
  def merge
    
    if current_user.present? and current_user.ambassador?
      silk_identifier = URI.decode(params[:silk_identifier])
      submissions = Submission.where(silk_identifier: silk_identifier)
      Archive.delete_all(id: submissions.first.id)
      archive = Archive.new(submissions.first.attributes)
      contents = ActiveSupport::JSON.decode(archive.content)
      body = URI.decode(params[:content])
      contents["body"] = body
      archive.content = ActiveSupport::JSON.encode(contents)
      
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true, :filter_html => true)
      
      unless silk_content(submissions.first.id, silk_identifier, submissions.first.country, params[:category], contents["tags"], markdown.render(body))
        render :json => { :error => "Houston we have a problem" }, status: :unprocessable_entity and return
      else
        archive.status = "submitted"
        if archive.save
          submissions.destroy_all
        end
      end
      
      render :json => { :info => "Data merged and uploaded to Silk" }, :status => 200 and return
      #render :json => { :info => submissions }, :status => 200 and return
    end
    failure
  end
  
  def accept
    render :json => { :error => "You are not allowed to do that" }, :status => 403 and return unless params[:k].present? && params[:a].present?
    
    key = URI.decode(params[:k])
    
    render :json => { :error => "You are not allowed to do that" }, :status => 403 and return unless decrypt(key) == params[:a]
    
    article = Submission.find(params[:a])

    if article.present?
      if decrypt(key).eql?(article.id.to_s)
        if article.update(status: "approved")
          archive = Archive.new(article.attributes)
          archive.status = "submitted"
          archive.save
          SubmissionNotifier.approved(article.user.email, article.silk_identifier).deliver
          redirect_to root_url, alert: "The submission has been approved. Thank you!" and return
        end
      end
    
    end
    failure
  end
  
  def destroy
    render :json => { :info => "Logged out" }, :status => 200
  end
  
  def failure
    render :json => { :error => "Houston we have a problem" }, :status => 401
  end

  def update_silk
    section = 'Overview'
    section = params[:section] if params[:section].present?
    if params[:content].present? and params[:content][:body].present? and params[:country].present?
      silk_sid = ' '
      while silk_sid.nil? || silk_sid.include?(" ")
        silk_sid = Silker.authenticate( ENV['SILK_EMAIL'], ENV['SILK_PASSWORD'] )
      end
      silker = Silker.new( silk_sid, ENV['SILK_SITE'] )
      
      silk_identifier = "#{params[:country]} #{section}"
      submissions = Submission.where(silk_identifier: silk_identifier)
      submission = submissions.first
      Archive.delete_all(id: submission.id)
      archive = Archive.new(submission.attributes)
      contents = ActiveSupport::JSON.decode(archive.content)
      body = URI.decode(params[:content][:body])
      contents["body"] = body
      archive.content = ActiveSupport::JSON.encode(contents)
      
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true, :filter_html => true)

      body = markdown.render(URI.decode(params[:content][:body]))
      contents = parse_visio(body).gsub("\n", "")
      
      silk_html = dummy(params[:country], section, contents)
      
      silk_result = silker.create_or_update_page( URI.encode(silk_identifier), silk_html )
      
      if !silk_result.nil? and archive.save
        submission.delete
        render :json => {result: silk_result}, :status => 200 and return 
      else
        puts silk_html
        render :json => {result: 'Silk error'}, :status => :unprocessable_entity and return 
      end
    end
    failure
  end
  
  def queue_updates
    render :text => 'Error', status: :unprocessable_entity unless params[:country].present? and params[:silk_identifier].present? and params[:content].present?
    
    status_code = queue_for_moderation(params[:country], params[:silk_identifier], params[:content])
    render :json => {message: 'Done'}, status: 200 and return if status_code.eql?(200)
    render :json => {message: 'Error'}, status: :unprocessable_entity and return if status_code.eql?(:unprocessable_entity)
    render :json => {message: 'You are not allowed to do that!'}, status: 403 and return if status_code.eql?(403)
    
  end



  private

  def queue_for_moderation(country, silk_identifier, contents)
  
    if current_user.present?
      if params[:id].present?
        s = Submission.where(id: params[:id])
        if s.present?
          s = s.first
        else
          archive = Archive.find(params[:id])
          s = Submission.new(archive.attributes)
          s.save
        end
        s.status = "pending"
      else
        s = Submission.new
        s.silk_identifier = URI.decode(silk_identifier)
        s.user_id = current_user.id
        s.country = URI.decode(country)
      end
      
      s.content = contents.to_json

      if s.save
        recipient = User.select('GROUP_CONCAT(email) emails').where("countries = 'all' OR countries = ? OR countries LIKE ? OR countries LIKE ?", "#{s.country}", "#{s.country},%", "%,#{s.country}")
        if recipient.present?
          markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true, :filter_html => true)

          body = markdown.render(contents['body']).gsub("\n", "<br />")
          quick_accept_url = api_submissions_accept_url(k: encrypt(s.id), a: s.id)
          
          unless params[:id].present?
            SubmissionNotifier.need_verification(recipient.first.emails, s, body.html_safe, quick_accept_url).deliver
          end
          
        end
        
        return 200
      end
    else
      return 403
    end
    
    return :unprocessable_entity

  end
  
  def tag_builder( country, category, tags )
    tags_html = '<div style="margin-bottom: 20px;">'
        
    tags_html = tags_html + '<div style="display: inline-block; width: 200px; font-weight: 700; vertical-align: top;">'
    tags_html = tags_html + '<a href="/explore/table/collection/'+URI.decode(category.downcase)+'/column/country">Country</a>'
    tags_html = tags_html + '</div>'

    tags_html = tags_html + '<div style="display: inline-block; width: 300px; vertical-align: top;">'
    tags_html = tags_html + '<a data-tag-uri="http://'+ENV['SILK_SITE']+'.silk.co/tag/country" href="/explore/table/collection/'+URI.decode(category.downcase)+'/column/country/filter/enum/country/'+country+'">' + country.titleize + '</a>'
    tags_html = tags_html + '</div>'
    
    tags.each_with_index do |tag,index|
      tag.each do |key,value|
        unless URI.decode(key).downcase.include?("address") || URI.decode(key).downcase.include?("website")
          tags_html = tags_html + '<div style="display: inline-block; width: 200px; font-weight: 700; vertical-align: top;">'
          tags_html = tags_html + '<a href="/explore/table/collection/'+URI.decode(category.downcase)+'/column/'+URI.decode(key).titleize+'">'+URI.decode(key).titleize+ '</a>'
          tags_html = tags_html + '</div>'
  
          tags_html = tags_html + '<div style="display: inline-block; width: 300px; vertical-align: top;">'
          tags_html = tags_html + '<a data-tag-uri="http://'+ENV['SILK_SITE']+'.silk.co/tag/'+URI.decode(key).titleize+'" href="/explore/table/collection/'+URI.decode(category.downcase)+'/column/'+URI.decode(key).titleize+'/filter/enum/'+URI.decode(key).titleize+'/'+value+'">' + URI.decode(value).titleize + '</a>'
          tags_html = tags_html + '</div>'
        else
          tags_html = tags_html + '<div style="display: inline-block; width: 200px; font-weight: 700; vertical-align: top;">'
          tags_html = tags_html + URI.decode(key).titleize
          tags_html = tags_html + '</div>'
  
          tags_html = tags_html + '<div style="display: inline-block; width: 300px; vertical-align: top;">'
          tags_html = tags_html + URI.decode(value).titleize
          tags_html = tags_html + '</div>'
        end
        
      end
    end
    tags_html + "</div>"
  end
  
  def style_builder
    style = 'font-size: 16px;'
    style = style + 'font-family: proxima-nova, Arial, Helvetica, sans-serif;'
    style = style + 'letter-spacing: 1px;'
    style = style + 'font-weight: bold;'
    style = style + 'color: #555;'
    style
  end
  
  def silk_content(id, page, country, category, tags, content)
    silk_sid = ' '
    while silk_sid.nil? || silk_sid.include?(" ")
      silk_sid = Silker.authenticate( ENV['SILK_EMAIL'], ENV['SILK_PASSWORD'] )
    end
    silker = Silker.new( silk_sid, ENV['SILK_SITE'] )
    data_country,data_collection,data_title = page.split(":")
    s_silk_page = ''
    
    s_silk_page = s_silk_page + '<article data-article="" data-format="1" data-title="'+data_title+'" data-tag-context="/tag/'+URI.decode(category.downcase)+'">'
    s_silk_page = s_silk_page + '  <section class="body">'
    s_silk_page = s_silk_page + '    <div class="layout meta">'
    s_silk_page = s_silk_page + '      <h1 class="button-font" style="'+style_builder+'">'+CGI.unescapeHTML(data_title)+'</h1>'
    s_silk_page = s_silk_page + '    </div>'
    s_silk_page = s_silk_page + '    <div class="layout content">'
    s_silk_page = s_silk_page + '      '
    s_silk_page = s_silk_page + '      <div id="product-bar" style="display:block; width:1px; height:1px; float:right; overflow: visible;"><a href="'+page_edit_url(key: encrypt(id), silk_identifier: URI.encode(page))+'" class="toolbar-button action edit-page" style="color: #ffffff; width: 100px;">Edit Page</a></div>'
    s_silk_page = s_silk_page + '      ' + tag_builder(country, category, tags)
    s_silk_page = s_silk_page + '      '+CGI.unescapeHTML(content.gsub("\n",""))
    s_silk_page = s_silk_page + '      '
    s_silk_page = s_silk_page + '    </div>'
    s_silk_page = s_silk_page + '    <br/>'
    s_silk_page = s_silk_page + '  </section>'
    s_silk_page = s_silk_page + '</article>'
    
    puts s_silk_page
#  silk_sid = Silker.authenticate( 'gerard@nerubia.com', 'passw0rt' )
#  silker = Silker.new(silk_sid, 'nerubia')
#  a = ''
#  silker.create_or_update_page('Nerubia - Philippines', a)
#
    puts "\n\nsilker.create_or_update_page( '#{URI.encode(page)}', '#{s_silk_page}' )\n\n"
    silk_result = silker.create_or_update_page( URI.encode(page), s_silk_page )
    puts "Response from Silk API: #{!silk_result.nil?}"
    !silk_result.nil?
  end
  

end