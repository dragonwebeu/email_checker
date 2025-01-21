# frozen_string_literal: true

require_relative "email_checker/version"

require 'resolv'
require 'net/smtp'

module EmailChecker
  class << self
# Validates basic email format using a simple regex.
# Note: For production use, you might want a more robust check
# or use a dedicated library.

    # Todo: add better email validation here!!
    EMAIL_REGEX = /\A[^@\s]+@[^@\s]+\z/

    def valid_syntax?(email)
      !!(email =~ EMAIL_REGEX)
    end

    # Retrieve the MX records for the domain.
    # Returns an array of Exchange hostnames or an empty array if none found.
    def mx_records_for_domain(domain)
      mx_records = []
      Resolv::DNS.open do |dns|
        resources = dns.getresources(domain, Resolv::DNS::Resource::IN::MX)
        mx_records = resources.map(&:exchange).map(&:to_s)
      end
      mx_records
    rescue StandardError => e
      warn "DNS MX lookup failed: #{e.message}"
      []
    end

    # Tries to verify the email using SMTP commands (EHLO, MAIL FROM, RCPT TO).
    def smtp_check_email(mx_host, recipient_email, from_email = 'test@localhost', helo_domain: 'localhost')
      response = :unknown

      Net::SMTP.start(mx_host, 25, helo_domain, nil, nil, :plain) do |smtp|
        # Check if server responds positively to MAIL FROM
        mailfrom_response = smtp.mailfrom(from_email)
        unless mailfrom_response.status.to_i == 250
          return {mailfrom_response: {status: mailfrom_response.status, message: mailfrom_response.string}}
        end
        # Check if server responds positively to RCPT TO
        rcptto_response = smtp.rcptto(recipient_email)
        unless mailfrom_response.status.to_i == 250
          return {rcptto_response: {status: rcptto_response.status, message: rcptto_response.string}}
        end
        case rcptto_response.status.to_i
        when 250 then response = :valid
        when 550 then response = :invalid
        else          response = :unknown
        end
      end
      {full_result: "#{mx_host} returns: #{response} for #{recipient_email}",result: response}
    rescue Net::SMTPFatalError, Net::SMTPSyntaxError => e
      warn "SMTP error: #{e.message}"
      warn "NB! If :invalid is returned with a server error, it means other servers with valid status are false positive!"
      {full_result: "#{mx_host} returns: invalid for #{recipient_email}",result: :invalid, error: e.message}
    rescue Net::OpenTimeout, Net::ReadTimeout, Errno::ECONNREFUSED, SocketError => e
      warn "Connection error: #{e.message}"
      {full_result: "#{mx_host} returns: error for #{recipient_email}",result: :error, error: e.message}
    rescue StandardError => e
      warn "Unexpected error: #{e.message}"
      {full_result: "#{mx_host} returns: error for #{recipient_email}",result: :error, error: e.message}
    end

    def check_email(email_to, email_from)
      # 1) Check syntax
      return :invalid_syntax unless valid_syntax?(email_to)

      # 2) Extract domain
      domain = email_to.split('@').last

      # 3) Get MX records
      mx_hosts = mx_records_for_domain(domain)
      return :no_mx_records if mx_hosts.empty?

      # 4) Attempt SMTP
      final_result = []
      mx_hosts.each do |mx_host|
        result = smtp_check_email(mx_host, email_to, email_from, helo_domain: domain)
        final_result << result
      end
      final_result
    end
  end
end
