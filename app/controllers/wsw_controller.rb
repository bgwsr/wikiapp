class WswController < ApplicationController
  include ApplicationHelper
  def edit
    render json: params and return
  
    render :text => { :error => "You are not allowed to do that" }, :status => 403 and return unless params[:k].present? && params[:a].present?
    
    key = URI.decode(params[:k])
    
    render :text => { :error => "You are not allowed to do that" }, :status => 403 and return unless decrypt(key) == params[:a]
    
    article = Submission.find(params[:a])
    @submission = Submission.find(params[:a])
  end
end
