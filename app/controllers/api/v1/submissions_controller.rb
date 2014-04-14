require 'json'
require 'custom/silker'
require 'redcarpet/compat'
class Api::V1::SubmissionsController < ApplicationController
    def create
      if current_user.present?
        s = Submission.new
        s.silk_identifier = URI.decode(params[:silk_identifier])
        s.user_id = current_user.id
        contents = ActiveSupport::JSON.decode(params[:content].to_json)
        contents['body'] = URI.decode(contents["body"])

        contents["tags"].each_with_index do |tag,index|
          tag.each do |key,value|
            contents["tags"][index][key] = URI.decode(value)
          end
        end
        s.content = contents.to_json
        
        s.country = params[:country]
        if s.save
          render :json => { :info => s }, :status => 200 and return
        end
      end
      
      failure
    end
    
    def update
      if current_user.present? and current_user.ambassador?
        submission = Submission.find(params[:id])
        if submission.present?
          submission.status = params[:status] if params[:status].present?
          if submission.save
            render :json => { :info => submission }, :status => 200 and return
          end
        end
      end
      failure
    end
    
    def merge
      if current_user.present? and current_user.ambassador?
#        submissions = Submission.where(silk_identifier: params[:silk_identifier])
#        submissions.update_all(status: "merged")
        
        silk_sid = Silker.authenticate( ENV['SILK_EMAIL'], ENV['SILK_PASSWORD'] )
        silker = Silker.new( silk_sid, ENV['SILK_SITE'] )
        s_silk_xml = silker.get_private_page_html( URI.decode(params[:silk_identifier]) )
        
        puts "original:"
        puts s_silk_xml
        markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true)
        s_silk_xml = '<article data-article="" data-format="1" data-title="'+URI.decode(params[:silk_identifier])+'" data-tag-context="/tag/'+URI.decode(params[:category].downcase)+'">'
        s_silk_xml = s_silk_xml + '<section class="body">'
        s_silk_xml = s_silk_xml + '  <div class="layout meta" style="display:inline-block;float:none;">'
        s_silk_xml = s_silk_xml + '    <p>hello</p>'
        s_silk_xml = s_silk_xml + '    <img src="http://i.imgur.com/IpwY1fe.jpg" alt="Just in case" title="Tooltip" width="42" height="42" />'
        s_silk_xml = s_silk_xml + '    <p>hello2</p>'
        s_silk_xml = s_silk_xml + '  </div>'
        s_silk_xml = s_silk_xml + '<div class="layout content" style="display:inline-block;float:none;">'
        s_silk_xml = s_silk_xml + '  <a data-tag-uri="/tag/reviewer">Gerard</a> is 30 years old.'
        s_silk_xml = s_silk_xml + "  "+markdown.render(URI.decode(params[:content][:body]).gsub("\n", "<br />"))
        s_silk_xml = s_silk_xml + '</div>'
        s_silk_xml = s_silk_xml + '</section>'
        s_silk_xml = s_silk_xml + '</article>'
        
        puts "updated:"
        puts s_silk_xml
        
        silker.create_or_update_page( URI.decode(params[:silk_identifier]), s_silk_xml )
        
        render :json => { :info => s_silk_xml } and return
        #render :json => { :info => submissions }, :status => 200 and return
      end
      failure
    end

    def destroy
      render :json => { :info => "Logged out" }, :status => 200
    end

    def failure
      render :json => { :error => "Houston we have a problem" }, :status => 401
    end
end