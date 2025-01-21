# EmailChecker
## Installation

Add to the application's Gemfile:

```Gemfile
gem 'email_checker', git: 'https://github.com/dragonwebeu/email_checker.git'
```

## Usage

```ruby
# Example usage:
email_to_check = "test.valid@example.eu"
email_from = 'valid.email@gmail.com'
results = EmailChecker.check_email(email_to_check, email_from)
puts "Result for #{email_to_check}: #{results}"
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dragonwebeu/email_checker.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
