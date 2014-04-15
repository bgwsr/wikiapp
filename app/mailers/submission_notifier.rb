class SubmissionNotifier < ActionMailer::Base
  default from: "\"Admin\" <gerard@nerubia.com>"

  def need_verification(email_csv, article)
    @article = article
    
    mail( to: "\"Ambassadors\" <bowei@worldstartupreport.com>",
          cc: email_csv,
          subject: "[WorldStartupWiki] A recent submission needs your verification" )
  end
  

end
