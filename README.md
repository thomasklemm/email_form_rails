The email_form_rails app demoes a email form (such as a contact form) in Rails. All data entered into the form is send to a specified email address, no data is saved to a database. Written relying on Rails 3.2 with ActionMailer for Sending Mails, ActiveAttr for extending ActiveModels features, ActiveModel's Validations and SimpleForm as a Form Builder, and the Slim templating language. Emails sent in development mode will be displayed in browser using LetterOpener.The deployed sample is running on Heroku's most current cedar stack.

This demo is using these awesome gems:
[ActiveAttr](https://github.com/cgriego/active_attr): What ActiveModel left out.

[Validates Email Format Of](https://github.com/alexdunae/validates_email_format_of): Validate e-mail addreses against RFC 2822 and RFC 3696 with this Ruby on Rails plugin and gem.
 
[Simple Form](https://github.com/plataformatec/simple_form): Forms made easy for Rails! It's tied to a simple DSL, with no opinion on markup.

[Letter Opener](https://github.com/ryanb/letter_opener): Preview mail in the browser instead of sending.
 
[Slim Rails](https://github.com/leogalmeida/slim-rails): Provides rails 3 generators for slim.
(ERB or HAML will do as well)

Before deciding to use any of them you should check out their documentation. They are all written by very fine folks.

## The process

Let's create our new Rails app
```
$ rails new email_form
```

Add the gems to our `Gemfile`  
(it's nicer to actually add them along the way as we need them; if you do this run 'bundle install' and maybe restart you server each time you add a gem)
```
# Gemfile.rb
# ActiveAttr: What ActiveModel left out. https://github.com/cgriego/active_attr
gem 'active_attr'
# Slim Rails: Provides rails 3 generators for slim. https://github.com/leogalmeida/slim-rails
gem 'slim-rails'
# Validates Email Format Of: Validate e-mail addreses against RFC 2822 and RFC 3696 with this Ruby on Rails plugin and gem.. https://github.com/alexdunae/validates_email_format_of
gem 'validates_email_format_of'
# Simple Form: Forms made easy for Rails! It's tied to a simple DSL, with no opinion on markup. https://github.com/plataformatec/simple_form
gem 'simple_form'
# Letter Opener: Preview mail in the browser instead of sending. https://github.com/ryanb/letter_opener
gem "letter_opener", :group => :development
```

Run `bundle install` each time you add a new gem
```
$ bundle install
or just
$ bundle
```

## Building the Message Model

Message Model: Generate
```
$ rails generate model Message --skip-migration
$ Output:
      invoke  active_record
      create    app/models/message.rb
      invoke    test_unit
      create      test/unit/message_test.rb
      create      test/fixtures/messages.yml
```

Message Model: Define attributes
```
# app/models/message.rb
class Message
	# Remove the inheritance from ActiveRecord::Base (class Message < ActiveRecord::Base)

	# Include ActiveAttr functionality
	include ActiveAttr::Model

	# Define attributes
	attribute :name
	attribute :email
	attribute :phone
	attribute :body

	# Mass assignment security
	# Whitelist attributes that you want to mass assign user given data to
  	attr_accessible :name, :email, :phone, :body
end
```

Message Model: Validations
```
# app/models/message.rb
class Message
		###

			# Include ActiveModel::Validations
		include ActiveModel::Validations

		###

	  # Validations
  	# Name must be present
  	validates_presence_of :name

  	# Email must be present and valid email format
  	validates_presence_of :email
  	validates :email, email_format: { message: "is not looking like a valid email address"}

  	# Phone must be present
  	validates_presence_of :phone

  	# Body is optional but if given it must be 500 characters at maximum
  	validates_length_of :body, maximum: 500

end
```
Learn more about Validation in the [Ruby on Rails Guides](http://guides.rubyonrails.org/active_record_validations_callbacks.html)

Test what we've done so far in the Rails Console
```
$ rails console
or shorthand
$ rails c

$ m = Message.new
=> #<Message body: nil, email: nil, name: nil, phone: nil>
$ m.errors.full_messages
=> []
# Run validation
$ m.valid?
=> false
$ m.errors.full_messages
=> ["Name can't be blank", "Email can't be blank", "Email is not looking like a valid email address", "Phone can't be blank"]

$ m.email = "random"
=> "random"
$ m.valid?
=> false
$ m.errors.full_messages
=> ["Name can't be blank", "Email is not looking like a valid email address", "Phone can't be blank"]

$ m.email = "random@random"
=> "random@random"
$ m.valid?
=> false
$ m.errors
=> #<ActiveModel::Errors:0x007f951a7988d8 @base=#<Message body: nil, email: "random@random", name: nil, phone: nil>, @messages={:name=>["can't be blank"], :email=>["is not looking like a valid email address"], :phone=>["can't be blank"]}>
$ m.errors.full_messages
=> ["Name can't be blank", "Email is not looking like a valid email address", "Phone can't be blank"]

$ m.email = "myemail@writer.com"
=> "myemail@writer.com"
$ m.valid?
=> false
$ m.errors
=> #<ActiveModel::Errors:0x007f951a7988d8 @base=#<Message body: nil, email: "myemail@writer.com", name: nil, phone: nil>, @messages={:name=>["can't be blank"], :email=>[], :phone=>["can't be blank"]}>

# => Validation of email format seem to work properly

irb(main):035:0* m.name = "Thomas Klemm"
=> "Thomas Klemm"
irb(main):036:0> m.valid?
=> false
irb(main):037:0> m.errors
=> #<ActiveModel::Errors:0x007f951a7988d8 @base=#<Message body: nil, email: "myemail@writer.com", name: "Thomas Klemm", phone: nil>, @messages={:email=>[], :phone=>["can't be blank"]}>

# => Presence Validation works as expected
```


## Building the Contact Form Controller and View

Generate a controller (here: "home") and an action (here: "index") that you want to use to display the email form
```
$ rails g controller home index
Output:
      create  app/controllers/home_controller.rb
       route  get "home/index"
      invoke  slim
      create    app/views/home
      create    app/views/home/index.html.slim
      invoke  test_unit
      create    test/functional/home_controller_test.rb
      invoke  helper
      create    app/helpers/home_helper.rb
      invoke    test_unit
      create      test/unit/helpers/home_helper_test.rb
      invoke  assets
      invoke    coffee
      create      app/assets/javascripts/home.js.coffee
      invoke    scss
      create      app/assets/stylesheets/home.css.scss
```

Set your routing
```
# config/routes.rb

# replace generated get 'home#index' with next line
resources :home, only: :index

###

root :to => 'home#index'
```

Test your routing by running the rails server and opening `http://localhost:3000/` in your browser. You should see a default index view page.

Now let's add a form for our message model using the simple form gem

First run the simple form generator
```
$ rails generate simple_form:install
Output:
			SimpleForm 2 supports Twitter bootstrap. In case you want to generate bootstrap configuration, please re-run this generator passing --bootstrap as option.
       exist  config
      create  config/initializers/simple_form.rb
      create  config/locales/simple_form.en.yml
      create  lib/templates/slim/scaffold/_form.html.slim
```





```
# config/routes.rb
###

match '/email' => 'home#send_email_form', as: :email_form, via: :post

###
```

noname:email_form thomasklemm$ rake routes
home_index GET  /home(.:format)  home#index
email_form POST /email(.:format) home#send_email_form
      root      /                home#index


noname:email_form thomasklemm$ rails g mailer contact_form
      create  app/mailers/contact_form.rb
      invoke  slim
      create    app/views/contact_form
      invoke  test_unit
      create    test/functional/contact_form_test.rb


