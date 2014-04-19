require 'json'
require 'custom/silker'
require 'redcarpet/compat'
class Api::V1::SubmissionsController < ApplicationController
  include ApplicationHelper

  def create
    if current_user.present?
      if params[:id].present?
        s = Submission.find(params[:id])
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
          SubmissionNotifier.moderated(submission.user.email, params[:status], params[:reason]).deliver
        end
        if submission.save
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
      archive = Archive.new(submissions.first.attributes)
      contents = ActiveSupport::JSON.decode(archive.content)
      body = URI.decode(params[:content])
      contents["body"] = body
      archive.content = ActiveSupport::JSON.encode(contents)
      
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true, :filter_html => true)
      
      unless silk_content(submissions.first.id, silk_identifier, params[:category], contents["tags"], markdown.render(body))
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
  
  private
  def silk_content(id, page, category, tags, content)
    silk_sid = Silker.authenticate( ENV['SILK_EMAIL'], ENV['SILK_PASSWORD'] )
    silker = Silker.new( silk_sid, ENV['SILK_SITE'] )

    tags_html = '<div style="margin-bottom: 20px;">'
    tags.each_with_index do |tag,index|
      tag.each do |key,value|
        
        tags_html = tags_html + '<div style="display: inline-block; width: 200px; font-weight: 700;">'
        tags_html = tags_html + '<a href="/explore/table/collection/'+URI.decode(category.downcase)+'/column/'+key+'">'+URI.decode(key).titleize+ '</a>'
        tags_html = tags_html + '</div>'

        tags_html = tags_html + '<div style="display: inline-block; width: 300px;">'
        tags_html = tags_html + '<a data-tag-uri="http://'+ENV['SILK_SITE']+'.silk.co/tag/'+key.downcase+'" href="/explore/table/collection/'+URI.decode(category.downcase)+'/column/'+key+'/filter/enum/'+key+'/'+value+'">' + URI.decode(value).titleize + '</a>'
        tags_html = tags_html + '</div>'
        
      end
    end
    tags_html = tags_html + "</div>"
    
    s_silk_page = ''
    s_silk_page = s_silk_page + '<article data-article="" data-format="1" data-title="'+page+'" data-tag-context="/tag/'+URI.decode(category.downcase)+'">'
    s_silk_page = s_silk_page + '  <section class="body">'
    s_silk_page = s_silk_page + '    <div class="layout meta">'
    s_silk_page = s_silk_page + '          '+CGI.unescapeHTML(page)
    s_silk_page = s_silk_page + '    </div>'
    s_silk_page = s_silk_page + '    <div class="layout content">'
    s_silk_page = s_silk_page + '      '
    s_silk_page = s_silk_page + '      <div id="product-bar" style="display:block;"><a href="'+page_edit_url(k: encrypt(id), a: id)+'" class="toolbar-button action edit-page" style="color: #ffffff;">Edit Page</a></div>'
    s_silk_page = s_silk_page + '      '+tags_html
    s_silk_page = s_silk_page + '      '+CGI.unescapeHTML(content.gsub("\n",""))
    s_silk_page = s_silk_page + '      '
    s_silk_page = s_silk_page + '    </div>'
    s_silk_page = s_silk_page + '    <br/>'
    s_silk_page = s_silk_page + '  </section>'
    s_silk_page = s_silk_page + '</article>'
    
    puts s_silk_page
    
    silk_result = silker.create_or_update_page( URI.encode(page), s_silk_page )
    puts "Response from Silk API: #{!silk_result.nil?}"
    !silk_result.nil?
  end
end