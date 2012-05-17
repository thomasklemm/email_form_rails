The email_form_rails app demoes a email form (such as a contact form) in Rails. All data entered into the form is send to a specified email address, no data is saved to a database. Written relying on Rails 3.2 with ActionMailer for Sending Mails, ActiveAttr for extending ActiveModels features, ActiveModel's Validations and SimpleForm as a Form Builder, and the Slim templating language. Emails sent in development mode will be displayed in browser using LetterOpener.The deployed sample is running on Heroku's most current cedar stack.

Create a new Rails app
```
$ rails new email_form
```

Add ActiveAttr and Slim Templating Language
```
# Gemfile.rb
gem 'active_attr'
gem 'slim-rails'
```

Run Bundle Install
```
$ bundle install
or just
$ bundle
```

Generate model Message
```
$ rails generate model Message --skip-migration
$ Output:
      invoke  active_record
      create    app/models/message.rb
      invoke    test_unit
      create      test/unit/message_test.rb
      create      test/fixtures/messages.yml
```


