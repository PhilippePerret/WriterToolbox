# encoding: UTF-8
=begin

  Cf. le fichier _READ_ME_.md

=end
class CRON2
  class SuperLog
    class << self
      def superlog mess, options = nil
        @superlogs ||= Array.new
        @superlogs << "--- #{mess}"
      end

      def clocktime
        @clocktime ||= Time.now.to_i.as_human_date(true, true, ' ', 'à')
      end

      # Message retourné
      def output
        @superlogs ||= ['Aucun message super-log']
        "Super-log du cron du #{clocktime}" +
        @superlogs.collect{|m| m.in_p(class: 'small').join('')
      end

      # Envoi le message à l'administrateur si c'est nécessaire
      def send_superlog_if_required
        # # Remettre cette barrière quand tout fonctionnera
        # return if @superlogs.nil? || @superlogs.empty?

        # On envoie le rapport
        site.send_mail_to_admin(
          subject:        "SUPER-LOG CRON2 - #{clocktime}",
          message:        self.output,
          formated:       true,
          force_offline:  true
        )
      end
    end #/<< self CRON2::SuperLog
  end #/SuperLog
end #/CRON2

# Le superlog doit être utilisé pour envoyer des messages dans le log
# principal envoyé quoditiennement à l'administrateur.
# Il faut vraiment mettre les messages indispensables.
def superlog mess, options = nil
  CRON2::SuperLog.superlog mess, options
end
