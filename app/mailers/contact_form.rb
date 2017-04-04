class ContactForm < ActionMailer::Base
  
  default from: "mail@example.com"
  default to: "mail@example.com"

  def email_form(message)
  	@message = message
  	mail subject: "[Your Homepage] #{message.name} left a message"
  end

end
