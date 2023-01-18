class ConfirmationMailer < ApplicationMailer
    def done_email
        mail(to: 'deliverydisruptive69@gmail.com', subject: 'Delivery is done')
    end
end
