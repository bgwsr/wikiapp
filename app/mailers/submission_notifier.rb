class SubmissionNotifier < ActionMailer::Base
  default from: "\"Admin\" <gerard@nerubia.com>"

  def need_verification(email_csv, article, body, quick_accept_url)
    @article = article
    @quick_accept_url = quick_accept_url
    @body = body
    mail( to: "\"Ambassadors\" <bowei@worldstartupreport.com>",
          cc: email_csv,
          bcc: "gerard@nerubia.com",
          subject: "[WorldStartupWiki] A recent submission needs your verification" )
  end
  
  def moderated(email, status, reason)
    @status = status
    @reason = URI.decode(reason)
    mail( to: "\"Ambassador\" <#{email}>",
          bcc: "gerard@nerubia.com",
          subject: "[WorldStartupWiki] Your article has been #{status}" )
  end
  
  def approved(email, page)
    @silk_identifier = page
    mail( to: "\"Ambassador\" <#{email}>",
          bcc: "gerard@nerubia.com",
          subject: "[WorldStartupWiki] Your article has been accepted" )
  end
  

end
