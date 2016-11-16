# encoding: UTF-8
=begin

  Cf. le fichier _READ_ME_.md

=end
class CRON2
  class SuperLog
    class << self


      def superlog mess, options = nil
        @superlogs ||= Array.new
        options ||= Hash.new
        amorce = options[:error] ? '###' : '---'
        messform = "#{amorce} #{mess}"
        options[:error] && messform = "<span class='warning'>#{messform}</span>"
        @superlogs << messform
      end

      def clocktime
        @clocktime ||= Time.now.to_i.as_human_date(true, true, ' ', 'à')
      end

      # Message retourné
      def output
        @superlogs ||= ['Aucun message super-log']
        "Super-log du cron du #{clocktime}" +
        superlogs_as_message
      end

      # Le message à envoyer
      def superlogs_as_message
        @superlogs_as_message ||= begin
          @superlogs.collect{|m| m.in_div(class: 'small')}.join('')
        end
      end

      # Envoi le message à l'administrateur si c'est nécessaire
      def send_superlog_if_required
        # Remettre cette barrière quand tout fonctionnera
        return if @superlogs.nil? || @superlogs.empty?
        return if same_message_as_last_message?
        Dir.chdir(APP_FOLDER) do
          # On envoie le rapport
          site.send_mail_to_admin(
            subject:        "SUPER-LOG CRON2 - #{clocktime}",
            message:        self.output,
            formated:       true,
            force_offline:  true
          )
        end #/dans le dossier de l'application

        # On enregistre le message envoyé pour pouvoir vérifier
        # que le prochain n'est pas identique.
        save_superlogs_as_message
      end
      # /send_superlog_if_required

      # Retourne true si le message est le même que le dernier message
      # envoyé.
      def same_message_as_last_message?
        old_superlogs_as_message =
          if superlogs_message_file.exist?
            superlogs_message_file.read
          else
            nil
          end
        old_superlogs_as_message == superlogs_as_message
      end
      # /same_message_as_last_message?

      def save_superlogs_as_message
        superlogs_message_file.write superlogs_as_message
      end
      # /save_superlogs_as_message

      # Le fichier pour consigner le message de superlog à envoyer
      def superlogs_message_file
        @superlogs_message_file ||= SuperFile.new('./.superlogs_file.txt')
      end

    end #/<< self CRON2::SuperLog
  end #/SuperLog
end #/CRON2

# Le superlog doit être utilisé pour envoyer des messages dans le log
# principal envoyé quoditiennement à l'administrateur.
# Il faut vraiment mettre les messages indispensables.
#
# Note mettre options[:error] à true pour signaler que c'est une erreur
def superlog mess, options = nil
  CRON2::SuperLog.superlog mess, options
end
