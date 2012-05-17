# Email Form Rails *A basic contact form in Rails 3.2+*

A **step-by-step tutorial** on how to build a simple Rails app showing a **contact form / email form / feedback form** to the user.
The user input will be **validated for presence / format / length / etc.** 
If the input is valid the **data will be sent to a specified email address**, otherwise the form is rendered once again displaying error messages and allowing the user to update their form entries.

This app is written in **Rails 3.2** using ActionMailer for Sending Mails, ActiveAttr for extending ActiveModels features, ActiveModel's Validations and SimpleForm as a Form Builder, as well as the Slim templating language (any templating language will do though).
Emails sent in development mode will be displayed in browser using LetterOpener.

The deployed sample is running on Heroku's most current cedar stack. [You may visit the running app here](). To demo email sending it uses Letter Opener in production as well to display the email that would be sent otherwise.

This demo is using these awesome gems: 

**[ActiveAttr](https://github.com/cgriego/active_attr)**: What ActiveModel left out.  
**[Validates Email Format Of](https://github.com/alexdunae/validates_email_format_of)**: Validate e-mail addreses against RFC 2822 and RFC 3696 with this Ruby on Rails plugin and gem.  
**[Simple Form](https://github.com/plataformatec/simple_form)**: Forms made easy for Rails! It's tied to a simple DSL, with no opinion on markup.  
**[Letter Opener](https://github.com/ryanb/letter_opener)**: Preview mail in the browser instead of sending.  
**[Slim Rails](https://github.com/leogalmeida/slim-rails)**: Provides rails 3 generators for slim.
(ERB or HAML will do as well)

ActiveRecord Validations will be used as well to validate user input.

Before deciding to use any of them go check out their documentation. They are all written by very fine folks.

## The Process

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
Learn more about Validations in the [Ruby on Rails Guides](http://guides.rubyonrails.org/active_record_validations_callbacks.html)

Let's test what we've done so far in the Rails Console
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
That is just the behaviour we want. Now that the model is set up we should display a form to our users.

## Building the Contact Form Controller and View

Let's generate a controller (here: "home") and an action (here: "index") that you want to use to display the email form. You will most certainly want to use a more suitable name for the controller in your app.

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

Update the routes
```
# config/routes.rb
# replace generated get 'home#index' with this next line

resources :home, only: :index

###

root :to => 'home#index'
```

Test your routing by running the `rails server` and opening `http://localhost:3000/` in your browser. You should see a default index view page.

Now let's add a form for our message model using the simple form gem
Now is the time to check out the [documentation of this nice gem](https://github.com/plataformatec/simple_form).

Docs say we need to run a simple_form generator first, so let's do that
```
$ rails generate simple_form:install
Output:
			SimpleForm 2 supports Twitter bootstrap. In case you want to generate bootstrap configuration, please re-run this generator passing --bootstrap as option.
       exist  config
      create  config/initializers/simple_form.rb
      create  config/locales/simple_form.en.yml
      create  lib/templates/slim/scaffold/_form.html.slim
```

We choose that our index view should contain the email form. In the controller action we need to create a new `Message` object we can pass to our corresponding view.
```
# app/controllers/home_controller.rb
class HomeController < ApplicationController
  def index
    @message = Message.new
  end
end
```

Let's use our home#index view to render the form to the user
```
# app/views/home/index.html.slim

h1 Welcome

p You may leave me a mesage right here. Thanks for stopping by.

- flash.each do |name, value|
  p class="#{name}" #{value}

= simple_form_for @message do |f|
  = f.input :name
  = f.input :email
  = f.input :phone
  = f.input :body, as: :text
  = f.button :submit
```

The form should now get rendered on the page. If we submit it however, we run into trouble.
The exception displayed tells us that simple_form automatically generates a url to submit the form to (the form action="..." attribute) that cannot be found.  
We can fix this by supplying the form builder with a path set up to receive the form data.

Let's say we want to sumbit the form to `"/email"` via a `post` request
```
# config/routes.rb
###

match '/email' => 'home#send_email_form', as: :email_form, via: :post

###
```

To have a look at the routes in our app we can run `$ rake routes` (you might need to restart your server for it to pick up this change)
```
$ rake routes

Output:

home_index GET  /home(.:format)  home#index
email_form POST /email(.:format) home#send_email_form
      root      /                home#index
```

Great. Routing is set up.  

We now can provide this action path to our form builder
```
= simple_form_for @message, url: email_form_path do |f|
  = f.input :name
  = f.input :email
  = f.input :phone
  = f.input :body, as: :text
  = f.button :submit
```

The way we have just set up our routes is matching a post request to "/email" to an action called "send_email_form" inside our home controller.  We intend it to be designed to handle our form data and send the email.  
Let's add it to our `home` controller in a way it will display the params object to see if the message is sent correctly.
```
# app/controllers/home_controller.rb
class HomeController < ApplicationController
  def index
    @message = Message.new
  end

  def send_email_form
    # Displays an error showing the params object
    raise params.inspect
  end
end
```

Let's submit our form again. We should get an exception now showing the `params[:message]` object containing the values we just submitted.

Great! The form is submitting properly. Now let's add some logic that checks if the user entries are valid. If they are, the email should be sent (let's leave a todo here for now) and the user should be notified that things went smoothly. If validation failed the form should be rerendered displaying proper error messages that help him fill out the form as expected.

```
# app/controllers/home_controller.rb
def send_email_form
  @message = Message.new(params[:message])
  
  if @message.valid?

    # TODO: Send email

    redirect_to root_path, notice: "Email successfully sent."
  else
    flash.now.alert = "Email could not be sent. Please check your entries."
    render :index
  end

end
```

Play time! Let's test the validation behaviour in the browser.

If all seems to work properly, let's move on to send the email!

# Sending the email containing the form entries

TODO: step-by-step process

```
$ rails g mailer contact_form
Output:
      create  app/mailers/contact_form.rb
      invoke  slim
      create    app/views/contact_form
      invoke  test_unit
      create    test/functional/contact_form_test.rb
```



