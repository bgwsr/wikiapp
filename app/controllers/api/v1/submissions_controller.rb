require 'json'
require 'custom/silker'
class Api::V1::SubmissionsController < ApplicationController
    def create
      if current_user.present?
        s = Submission.new
        s.silk_identifier = params[:silk_identifier]
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
        submissions = Submission.where(silk_identifier: params[:silk_identifier])
        submissions.update_all(status: "merged")
        render :json => { :info => submissions }, :status => 200 and return
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