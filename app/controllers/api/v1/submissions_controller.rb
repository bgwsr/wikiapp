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
          recipient = User.select('GROUP_CONCAT(email) emails').where("countries = 'all' OR countries = ? OR countries LIKE ? OR countries LIKE ?", "#{s.country}", "#{s.country},%", "%,#{s.country}")
          if recipient.present?
            SubmissionNotifier.need_verification(recipient.first.emails, s).deliver
            
          end
          render :json => { :info => s }, :status => 200 and return
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
        
        silk_sid = Silker.authenticate( ENV['SILK_EMAIL'], ENV['SILK_PASSWORD'] )
        silker = Silker.new( silk_sid, ENV['SILK_SITE'] )
        
        markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true, :filter_html => true)
        s_silk_xml = silk_content(silk_identifier, params[:category], silk_identifier, markdown.render(URI.decode(params[:content]).gsub("\n", "<br />")))
        
        if silker.create_or_update_page( params[:silk_identifier], s_silk_xml ).nil?
          render :json => { :error => "Houston we have a problem" }, status: :unprocessable_entity and return
        else
          submissions.update_all(status: "merged")
        end
        
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

  private
    def silk_content(page, category, header, content)
      s_silk_page = ''
      s_silk_page = s_silk_page + '<article data-article="" data-format="1" data-title="'+page+'" data-tag-context="/tag/'+URI.decode(category.downcase)+'">'
      s_silk_page = s_silk_page + '  <section class="body">'
      s_silk_page = s_silk_page + '    <div class="layout meta">'
      s_silk_page = s_silk_page + '          '+CGI.unescapeHTML(header)
      s_silk_page = s_silk_page + '    </div>'
      s_silk_page = s_silk_page + '    <div class="layout content">'
      s_silk_page = s_silk_page + '      '
      s_silk_page = s_silk_page + '        '+CGI.unescapeHTML(content)
      s_silk_page = s_silk_page + '      '
      s_silk_page = s_silk_page + '    </div>'
      s_silk_page = s_silk_page + '    <br/>'
      s_silk_page = s_silk_page + '  </section>'
      s_silk_page = s_silk_page + '</article>'
      puts s_silk_page
      s_silk_page
    end
end