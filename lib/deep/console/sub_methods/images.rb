# encoding: UTF-8
=begin
Méthodes pour les taches
=end
class SiteHtml
class Admin
class Console

  class Images
  class << self

    def sub_log mess
      console.sub_log mess
    end

    def balise_image relpath
      relpath = relpath.nil_if_empty

      if relpath.nil?
        # => Il faut donner la syntaxe
        mess = <<-HTML
@syntaxe

    balise image &lt;path/to/image.ext&gt;[ erb]

    Path relatif à partir de ./view/img/
    Ou pour Narration : ./data/unan/pages_semidyn/cnarration/img/

    Si `erb` (ou `ERB`) à la fin, c'est une balise ERB
    qui est retournée.

        HTML

        sub_log mess.in_pre
      else
        # => Il faut donner la balise
        relpath, fin = relpath.split(' ')
        # Afin d'éviter les erreurs bêtes, on signale une erreur si
        # l'image n'existe pas.
        fullpath = "./view/img/#{relpath}"
        if File.exist?(fullpath)
          # res = image(relpath)
          res = "IMAGE[#{relpath}]"
          res = "<%= #{res} %>" if fin.to_s.downcase == 'erb'
          res = "<input type='text' value='#{res}' onfocus='this.select()' />"
        else
          res = "L'image de path `#{fullpath}` est inconnue."
        end
        sub_log res
      end
      ""
    end
  end #/<< self
  end #/Images
end #/Console
end #/Admin
end #/SiteHtml
