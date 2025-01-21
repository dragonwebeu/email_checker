require 'rspec'
require 'resolv'
require 'net/smtp'

RSpec.describe EmailChecker do
  describe '.valid_syntax?' do
    it 'returns true for valid email syntax' do
      expect(EmailChecker.valid_syntax?('test@example.com')).to be true
    end

    it 'returns false for invalid email syntax' do
      expect(EmailChecker.valid_syntax?('invalid-email')).to be false
    end
  end

  describe '.mx_records_for_domain' do
    it 'returns MX records for a valid domain' do
      allow(Resolv::DNS).to receive(:open).and_yield(double(getresources: [double(exchange: 'mail.example.com')]))
      expect(EmailChecker.mx_records_for_domain('example.com')).to eq(['mail.example.com'])
    end

    it 'returns an empty array for a domain with no MX records' do
      allow(Resolv::DNS).to receive(:open).and_yield(double(getresources: []))
      expect(EmailChecker.mx_records_for_domain('no-mx.com')).to eq([])
    end
  end

  describe '.smtp_check_email' do
    let(:smtp) { double('Net::SMTP') }

    before do
      allow(Net::SMTP).to receive(:start).and_yield(smtp)
    end

    it 'returns :valid for a valid email' do
      allow(smtp).to receive(:mailfrom).and_return(double(status: '250'))
      allow(smtp).to receive(:rcptto).and_return(double(status: '250'))
      result = EmailChecker.smtp_check_email('mail.example.com', 'test@example.com')
      expect(result[:result]).to eq(:valid)
    end

    it 'returns :invalid for an invalid email' do
      allow(smtp).to receive(:mailfrom).and_return(double(status: '250'))
      allow(smtp).to receive(:rcptto).and_return(double(status: '550'))
      result = EmailChecker.smtp_check_email('mail.example.com', 'invalid@example.com')
      expect(result[:result]).to eq(:invalid)
    end
  end

  describe '.check_email' do
    it 'returns :invalid_syntax for an email with invalid syntax' do
      expect(EmailChecker.check_email('invalid-email', 'from@example.com')).to eq(:invalid_syntax)
    end

    it 'returns :no_mx_records for a domain with no MX records' do
      allow(EmailChecker).to receive(:valid_syntax?).and_return(true)
      allow(EmailChecker).to receive(:mx_records_for_domain).and_return([])
      expect(EmailChecker.check_email('test@no-mx.com', 'from@example.com')).to eq(:no_mx_records)
    end

    it 'returns results for valid email checks' do
      allow(EmailChecker).to receive(:valid_syntax?).and_return(true)
      allow(EmailChecker).to receive(:mx_records_for_domain).and_return(['mail.example.com'])
      allow(EmailChecker).to receive(:smtp_check_email).and_return({ result: :valid })
      result = EmailChecker.check_email('test@example.com', 'from@example.com')
      expect(result.first[:result]).to eq(:valid)
    end
  end
end
