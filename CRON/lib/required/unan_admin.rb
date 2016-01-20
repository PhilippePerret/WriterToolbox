# encoding: UTF-8
class Unan

  RAPPORT_ADMIN_ONCE_A_DAY = false

  class << self

    # Variable servant d'abord à consigner les messages
    # à consigner et ensuite à contenir le texte String
    # des messages à insérer dans le mail.
    attr_accessor :rapport_administration

    # Pour envoyer un mail à l'administration
    # Pour le moment, cela arrive lorsque l'auteur est trop en
    # dépassement sur ses travaux.
    # S'il y a vraiment trop de messages envoyés (par exemple un
    # toutes les heures au bout d'un certain moment) on pourra imaginer
    # enregistrer les messages dans un fichier qui ne sera envoyé qu'une
    # fois par jour.
    def send_rapport_to_admin

      mail_path = Unan::folder_module + "start_pday/mail/admin_rapport.erb"

      # On construit le rapport total à include dans le mail
      @rapport_administration = @rapport_administration.collect do |key_section, arr_messages|
        next nil if arr_messages.empty?
        titre = case key_section
        when :depassements then "Auteurs en dépassement"
        else "Section sans titre"
        end
        "<h3>#{titre}</h3>" +
        arr_messages.collect { |m| m.in_li }.join.in_ul
      end.compact.join.strip

      # Ne rien envoyer s'il n'y a rien à signaler
      return if @rapport_administration.empty?
      # Ou ajoute un titre avec l'heure et le jour
      @rapport_administration = "<h2>Rapport administration du cronjob du #{NOW.as_human_date(true, true)}</h2>" + @rapport_administration

      if RAPPORT_ADMIN_ONCE_A_DAY
        # On doit consigner le rapport dans un fichier pour
        # ne l'envoyer qu'une fois par jour
        File.open(path_rapport_admin.to_s, 'a') do |f|
          f.write "\n\n#{@rapport_administration}"
        end
        log "Rapport administration consigné dans un fichier"
      end

      if RAPPORT_ADMIN_ONCE_A_DAY && Time.now.hour == 0
        # Le rapport journalier doit être envoyé à l'administrateur
        @rapport_administration = path_rapport_admin.read.freeze
        message_mail = mail_path.deserb( self )
        log "Rapport journalier envoyé à l'administration"
        path_rapport_admin.remove
      else
        # On doit envoyer le rapport toutes les heures
        message_mail = mail_path.deserb( self )
        log "Rapport horaire envoyé à l'administration"
      end


    end

    def path_rapport_admin
      @path_rapport_admin ||= SuperFile::new(['.', 'CRON', 'rapport_admin.html'])
    end
  end #/<< self
end #/Unan
