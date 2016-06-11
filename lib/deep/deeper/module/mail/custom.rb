# encoding: UTF-8
=begin
Méthodes de customisation des messages
=end
class SiteHtml

  # Path du dossier qui contient ce module
  def folder_module_mail
    @folder_module_mail ||= site.folder_deeper_module + 'mail'
  end

class Mail
  class << self


    # Style du body (en fait du body ET du div conteneur principal)
    # Inséré dans une balise DIV contenant tout le mail
    # + Inséré dans la balise <style>...</style>
    def body_style
      "margin:0;background-color:white;color:#555;font-size:17.2pt"
    end
    # Styles ajoutés à la balise <style>...</style>
    def styles_css
      @styles_css ||= begin
        style_bande_logo      +
        style_message_content +
        style_citation        +
        other_styles          +
        style_signature
      end
    end

    def style_bande_logo
      @style_bande_logo ||= "div#logo{padding:1em 2em;background-color:#578088;color:white;}"
    end

    # Style du message, hors de l'entête (header) donc hors bande
    # logo
    def style_message_content
      @style_message_content ||= "div#message_content{margin:2em 4em}"
    end

    # Style pour la citation d'auteur
    def style_citation
      @style_citation ||= <<-CSS
div#citation{float:right;font-size:13pt!important;width:45%;margin:4px 4px 1em 1em}
div#citation a{text-decoration:none;color:inherit;}
div#citation span#quote_citation{font-style:italic}
div#citation span#quote_auteur{display:block;text-align:right;font-size:0.85em;text-variant:small-caps}
      CSS
    end

    def style_signature
      @style_signature ||= "span#signature{font-size:15.2pt;color:#555}"
    end

    def other_styles
      @other_styles ||= begin
        ".tiny{font-size:11.2pt}"  +
        ".small{font-size:14.3pt}"
      end
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

    # Méthode pour recevoir l'envoi si on est en OFFLINE
    # Permet d'écrire le message dans un tampon pour pouvoir
    # l'analyser au cours du test
    def send_offline hash_data_message_plus
      hash_data_message_plus.merge!(created_at: NOW)
      # debug "Mail qui aurait été envoyé : "
      # debug hash_data_message_plus.pretty_inspect
      tmp_mail_path.write Marshal.dump(hash_data_message_plus)
    end
    def tmp_mail_path
      tmp_mails_folder + tmp_mail_name
    end
    def tmp_mails_folder
      @tmp_mails_folder ||= begin
        fd = site.folder_tmp + 'mails'
        fd.exist? || fd.build
        fd
      end
    end
    def tmp_mail_name
      "mail#{imail}.msh"
    end
    def imail
      @imail ||= 0
      @imail += 1
      "#{@imail}".rjust(4,"0")
    end

  end # << self
end #/Mail
end #/SiteHtml

if defined?(site)
  site.folder_module_mail.require
end
