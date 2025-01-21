# frozen_string_literal: true

require_relative "lib/email_checker/version"

Gem::Specification.new do |spec|
  spec.name = "email_checker"
  spec.version = EmailChecker::VERSION
  spec.authors = ["Henry Maestu"]
  spec.email = ["dragonwebeu@gmail.com"]

  spec.summary = "Email and mail server email verification"
  spec.description = "Check the email validation and whether the mail server is responding to this email."
  spec.homepage = "https://github.com/dragonwebeu/email_checker"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.3.1"

  #spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  #spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
          f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.require_paths = ["lib"]
  # spec.add_dependency "resolve", "~> 0.6.0"
  # spec.add_dependency "net-smtp", "~> 0.1.0"
  spec.add_dependency "resolv"
  spec.add_dependency "net-smtp"
end
