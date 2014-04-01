class ContactMailer < ActionMailer::Base
  raise_delivery_errors = true
  
  def contact_email(from, sender_name, subject, content, for_technical_team, for_scientific_team)
   
    @message = content
    @sender_name = sender_name
    @sender_address = from
    @my_subject = subject
    
    dest = []
    dest += Rails.configuration.destination_emails[:technical] if for_technical_team
    dest += Rails.configuration.destination_emails[:scientific] if for_scientific_team
    
    mail(:from => from, :to => dest, :subject => '[Mail sent through the IFBL website] ' + subject)
  end
end
