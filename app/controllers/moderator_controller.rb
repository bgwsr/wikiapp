class ModeratorController < ApplicationController
  require 'redcarpet/compat'
  def index
    if current_user.present? and current_user.ambassador?
      if current_user.countries.eql?('all')
        @submissions = Submission.where(status: ["pending", "imported"])
      else
        countries = current_user.countries.split(",")
        @submissions = Submission.where(country: countries, status: ["pending", "imported"])
      end
    else
      render text: "not allowed", status: 403 and return
    end
  end
  
  def verify_entry
    @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true, :filter_html => true)
    if current_user.present? and current_user.ambassador?
      if current_user.countries.eql?('all')
        @submissions = Submission.where(silk_identifier: params[:silk_identifier], status: ["pending", "imported"])
      else
        countries = current_user.countries.split(",")
        @submissions = Submission.where(country: countries, silk_identifier: params[:silk_identifier], status: ["pending", "imported"])
      end
      render text: "not found", status: 404 and return if @submissions.empty?
    else
      render text: "not allowed", status: 403 and return
    end    
  end
end
