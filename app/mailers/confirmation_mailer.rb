class ConfirmationMailer < ApplicationMailer
    def done_email
        mail(to: 'radu_sterie@yahoo.com', subject: 'Delivery is done')
    end
end
