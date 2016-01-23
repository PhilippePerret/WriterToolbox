# encoding: UTF-8
=begin
Class Unan::Program::StarterPDay
--------------------------------
Extention pour la gestion des messages
=end
class Unan
class Program
class StarterPDay

  # ---------------------------------------------------------------------
  #   Classe, donc pour le check en général, tout programme confondus
  # ---------------------------------------------------------------------
  class << self


  end # << self

  # ---------------------------------------------------------------------
  #   Instance, donc pour le check du programme en particulier
  # ---------------------------------------------------------------------
  def mail_auteur
    @mail_auteur ||= MailAuteur::new(self)
  end

  class MailAuteur

    # Le starter-pday
    attr_reader :starter

    def initialize starter
      @starter = starter
    end

    # Méthode principale pour envoyer le mail à l'auteur
    def send_mail
      auteur.send_mail(
        subject: "Rapport journalier du #{NOW.as_human_date}",
        message: content,
        formated: true
      )
    rescue Exception => e
      mess_err "#ERREUR ENVOI MAIL USER DE PROGRAM : #{e.message}\n\n" + e.backtrace.join("\n") 
      debug mess_err
      auteur.add_error mess_err
      false
    else
      true
    end

    def content
      c = "Bonjour #{auteur.pseudo},".in_p
      c << introduction.to_s if introduction?
      if nouveaux_travaux?
        nouveaux_travaux.titre = "Nouveaux travaux"
        c << nouveaux_travaux.to_s
      end
      if travaux_courants?
        travaux_courants.titre = "Travaux courants"
        c << travaux_courants.to_s
      end
      c << conclusion.to_s if conclusion?
      return c
    end

    def introduction      ; @introduction     ||= Section::new(self)  end
    def introduction?     ; introduction      != "" end
    def travaux_courants  ; @travaux_courants  ||= Section::new(self)  end
    def travaux_courants? ; travaux_courants  != "" end
    def nouveaux_travaux  ; @nouveaux_travaux ||= Section::new(self)  end
    def nouveaux_travaux? ; nouveaux_travaux  != "" end
    def conclusion        ; @conclusion       ||= Section::new(self)  end
    def conclusion?       ; conclusion        != "" end

    # Petit texte ajouté à la fin des mails indiquant pourquoi ils sont
    # envoyés à l'utilisateur.
    def motif_reception_mail
      if auteur.daily_summary?
        "Vous recevez ce mail parce que vous êtes inscrit#{auteur.f_e} au programme “Un An Un Script” et que vous désirez recevoir un rapport journalier et être informé#{auteur.f_e} des nouveaux travaux. Pour modifier ce comportement et ne recevoir des messages qu'en cas de nouveaux travaux, vous pouvez modifier vos préférences dans <%= Unan::lien_bureau('votre bureau') %>."
      else
        "Vous recevez ce mail parce que vous êtes inscrit#{auteur.f_e} au programme “Un An Un Script” et que vous désirez ne recevoir des messages que lorsque de nouveaux travaux sont demandés. Pour modifier ce comportement et recevoir des messages quotidiens vous rappelant votre travail courant, vous pouvez modifier vos préférences dans <%= Unan::lien_bureau('votre bureau') %>."
      end
    end

    def auteur ; @auteur ||= starter.auteur end

    # Pour gérer les sections du mail
    class Section
      attr_reader :mail
      attr_reader :content
      # Titre de la section qui sera ajouté dans un h3
      attr_accessor :titre
      def initialize mail
        @mail     = mail
        @content  = ""
      end

      # Pour obtenir le contenu de la section
      def to_s
        c = ""
        c << "<h3>#{titre}</h3>" unless titre.nil?
        c << content
        c
      end

      # Pour ajouter du texte à la section
      def << str
        @content << str
      end
    end
  end #/Mail
end #/StarterPDay
end #/Program
end #/Unan
