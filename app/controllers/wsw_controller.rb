class WswController < ApplicationController
  include ApplicationHelper

  def index
    redirect_to new_user_session_url unless current_user.present?
  end

  def edit
    redirect_to new_user_session_url and return unless current_user.present?

    if params[:k].present? && params[:a].present?
      key = URI.decode(params[:k])
      if decrypt(key) == params[:a]
        @submission = Archive.find(params[:a])
      end

    elsif params[:silk_identifier].present?
      @submission = Archive.where(silk_identifier: URI.decode(params[:silk_identifier]), status: "submitted").first
    
    end
    
    render 'edit' and return if @submission.present?
    
    not_allowed
  end
  
  def information
    if params[:s].present? and params[:i].present?
      submission = Submission.where(id: params[:i]).first
      if submission.present? and submission.silk_identifier.eql?( URI.decode(params[:s]) ) and params[:country].present?
        @submission = submission
        @section = (URI.decode(params[:s])[submission.country.length..-1]).strip
        return
      else
        not_allowed
      end
    end
    not_allowed unless params[:country].present?
  end

  def not_allowed
    render :json => { :error => "You are not allowed to do that" }, :status => 403 and return
  end

end
