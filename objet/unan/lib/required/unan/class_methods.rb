# encoding: UTF-8
=begin
Méthodes Unan pour l'envoi des mails

@usage

    Unan::send_mail <data_mail>

=end
class Unan
  class << self

    # Envoi d'un mail
    # ---------------
    # Pour le programme Unan
    def send_mail data_mail
      (Unan::folder_module+'mail').require

      # Test : Pour forcer son envoi, même en local
      # data_mail.merge!(force_offline: true) unless data_mail.has_key?(:force_offline)

      Unan::exec_send_mail data_mail
    rescue Exception => e
      raise e
    end

  end # <<self

end #/Unan
