# encoding: UTF-8
=begin
Méthodes de customisation des messages
=end
class SiteHtml

  def folder_module_mail
    @folder_module_mail ||= site.folder_lib_optional + 'Site/mail'
  end

class Mail
  class << self


    # Style du body (en fait du body ET du div conteneur principal)
    # Inséré dans une balise DIV contenant tout le mail
    # + Inséré dans la balise <style>...</style>
    def body_style
      "margin: 2em;background-color:black;color:white;"
    end
    # Styles ajoutés à la balise <style>...</style>
    def styles_css
      "div#logo{margin-bottom:2em;background-color:green;}"
    end

    # {StringHTML} Entête du message
    def header
      header_vue = (site.folder_module_mail + "header.erb")
      header_vue.deserb(site) if header_vue.exist?
    end

    # {StringHTML} Pied de page du message
    def footer
      footer_vue = (site.folder_module_mail + "footer.erb")
      footer_vue.deserb(site) if footer_vue.exist?
    end


    # # À ajouter au suject (une espace sera ajoutée après le contenu)
    # site.mail_before_subject
    # # La signature du mail, normalement définie dans la configuration
    # site.mail_signature

    # Méthode pour recevoir l'envoi si on est en OFFLINE
    # Permet d'écrire le message dans un tampon pour pouvoir
    # l'analyser au cours du test
    def send_offline hash_data_message_plus
      # Pour le moment
      debug "Mail qui aurait été envoyé : "
      debug hash_data_message_plus.pretty_inspect
      # TODO L'enregistrer dans un fichier pour pouvoir le lire et
      # le tester
    end

  end # << self
end #/Mail
end #/SiteHtml

site.folder_module_mail.require