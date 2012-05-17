class ContactForm < ActionMailer::Base
  
  default from: "github@tklemm.eu"
  default to: "github@tklemm.eu"

  def email_form(message)
  	@message = message
  	mail subject: "[Your Homepage] #{message.name} left a message"
  end

end
