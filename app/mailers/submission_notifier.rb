class SubmissionNotifier < ActionMailer::Base
  default from: "\"Admin\" <gerard@nerubia.com>"

  def need_verification(email_csv, article)
    @article = article
    
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
  

end
