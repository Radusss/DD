options = { forward_emails_to: 'deliverydisruptive69@gmail.com',
            deliver_emails_to: ["@gmail.com"] }

unless (Rails.env.test? || Rails.env.production?)
  interceptor = MailInterceptor::Interceptor.new(options)
  ActionMailer::Base.register_interceptor(interceptor)
end