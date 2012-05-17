class Message
	# Remove the inheritance from ActiveRecord::Base (class Message < ActiveRecord::Base)

	# Include ActiveAttr functionality
	include ActiveAttr::Model

	# Include ActiveModel::Validations
	include ActiveModel::Validations

	# Define attributes
	attribute :name
	attribute :email
	attribute :phone
	attribute :body

	# Mass assignment security
	# Whitelist attributes that you want to mass assign user given data to
  	attr_accessible :name, :email, :phone, :body

  	# Validations

  	# Name must be present
  	validates_presence_of :name

  	# Email must be present and valid email format
  	validates_presence_of :email
  	validates_format_of :email, with: %r\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/

  	# Phone must be present
  	validates_presence_of :phone

  	# Body is optional but if given must be 500 characters at maximum
  	validates_length_if :body, maximum: 500
end
