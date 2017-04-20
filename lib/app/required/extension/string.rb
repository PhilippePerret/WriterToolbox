# encoding: UTF-8

class String

  def formate_balises_erb
    self.gsub(/<%=(.*?)%>/){
      begin
        eval($1.strip)
      rescue Exception => e
        $1
      end
    }
  end

  def formate_balises_propres
    str = self

    p = 'pour_voir.txt'
    File.unlink(p) if File.exist?(p)

    File.open(p, 'wb'){|f| f.write "AU DÉPART\n\n#{str}"}

    str = str.formate_balises_include
    str = str.formate_balises_exemples

    File.open('pour_voir.txt', 'a'){|f| f.write "\n\nAPRÈS CORRECTION\n\n#{str}"}

    str = str.evaluate_codes_ruby
    str = str.formate_mises_en_forme_propres
    str = str.mef_document
    str = str.formate_balises_notes
    str = str.formate_balises_references
    str = str.formate_balises_images
    str = str.formate_balises_mots
    str = str.formate_balises_films
    str = str.formate_balises_scenes
    str = str.formate_balises_livres
    str = str.formate_balises_personnages
    str = str.formate_balises_realisateurs
    str = str.formate_balises_producteurs
    str = str.formate_balises_acteurs
    str = str.formate_balises_auteurs
    str = str.formate_termes_techniques
    str = str.formate_balises_citations

      # debug "STRING APRÈS = #{str.gsub(/</,'&lt;').inspect}"
    return str
  end

  # Formate les balises INCLUDE qui permettent d'inclure des
  # fichiers dans d'autres fichiers.
  # @usage
  #   INCLUDE[path/relatif/to/file.ext]
  def formate_balises_include
    str = self
    str.gsub!(/INCLUDE\[(.*?)\]/){
      sfile = SuperFile.new($1.split('/'))
      if sfile.exist?
        "\n\n" + sfile.read + "\n\n"
      else
        # TODO Ici, alerte administrateur
        "INSERTION FICHIER INTROUVABLE : #{sfile.path}"
      end
    }
    str
  end


  def formate_mises_en_forme_propres

    str = self

    # Le format pour mettre une sorte de note de marge, avec un texte
    # réduit à droite. Ce format est défini par des ++ (au moins 2)
    str = str.gsub(/^(.*?) (\+\++) (.*?)$/){
      note_marge  = $1
      les_plus    = $2
      texte       = $3
      css = {2 => 'vingt', 3 => 'vingtcinq', 4 => 'trente', 5 => 'trentecinq'}[les_plus.length]

      # Puisque le code sera mise entre balises DIV, il ne sera
      # pas corrigé par kramdown. Il faut donc le faire ici, suivant
      # le code du fichier.
      texte = texte.formate_balises_propres
      texte =
        if texte.match(/<%/)
          texte.deserb
        else
          texte.respond_to?(:kramdown) || site.require_module('kramdown')
          texte.kramdown
        end
      (
        note_marge.strip.in_div(class: 'notemarge') +
        texte.strip
      ).in_div(class: "mg #{css}")
    }

    return str
  end


  # Insertion des exemples (balises EXEMPLE)
  #
  # Elles fonctionnent comme les inclusions, sauf que le paramètre
  # est un chemin relatif depuis le dossier :
  #   ./data/unan/page_cours/cnarration/exemples/_textes_/
  # ou
  #   ./data/unan/page_semidyn/cnarration/exemples/_textes_/
  #
  # La méthode est appelée par le fichier :
  #   ./objet/cnarration/lib/module/page/build.rb
  def formate_balises_exemples
    str = self
    str.gsub!(/EXEMPLE\[(.*?)\]/){
      rel_path = $1.freeze
      path_in_cours   = self.class.folder_textes_exemples_in_cours + rel_path
      path_in_semidyn = self.class.folder_textes_exemples_in_semidyn + rel_path
      temp_line = "<adminonly>#{'Éditer l’exemple ci-dessous'.in_a(href: "site/edit_text?path=%s", target: :new)}</adminonly>\n"

      if path_in_cours.exist?
        (temp_line % [CGI.escape(path_in_cours.to_s)]) +
        formate_exemple_in_path(path_in_cours)
      elsif path_in_semidyn.exist?
        (temp_line % [CGI.escape(path_in_semidyn.to_s)]) +
        formate_exemple_in_path(path_in_semidyn)
      else
        error "Un fichier exemple introuvable : #{rel_path}" +
        "(recherché dans #{path_in_cours} et #{path_in_semidyn})".in_div(class: 'small')
        "[ERREUR DE FICHIER EXEMPLE INCONNU : #{rel_path}]"
      end.gsub(/\r/,'')
    }
    str
  end

  # Pour formater les exemples avec Kramdown, il faut les
  # traiter de façon particulière, pour ne pas transformer
  # les parties des notes et les marques `DOC/`. On ne peut
  # pas se contenter d'utiliser la méthode String#kramdown
  #
  # ÇA FOIRE COMPLÈTEMENT LE TRUC, DONC JE ME CONTENTE DE
  # CORRIGER "MANUELLEMENT" QUELS TRUCS MARKDOWN
  #
  def formate_exemple_in_path superfile
    sfstr = superfile.read.gsub(/\r/,'')
    sfstr.gsub!(/\*\*(.*?)\*\*/, '<strong>\1</strong>')
    sfstr.gsub!(/\*(.*?)\*/, '<em>\1</em>')
    return sfstr

    # ibalise   = 0
    # hbalises  = Hash.new
    # while true
    #   found = sfstr.match(/^DOC\/(.*?)$/)
    #   if found
    #     tout = found.to_a.first
    #     ibalise += 1
    #     sfstr.gsub!(/#{Regexp.escape tout}/, "\n\n:::BALISE#{ibalise}:::\n\n")
    #     hbalises.merge!(ibalise => "#{tout}\n")
    #   else
    #     break
    #   end
    # end
    # # Les légendes et la marque de fin de document
    # while true
    #   found = sfstr.match(/^\/(.*?)$/)
    #   if found
    #     tout = found.to_a.first
    #     ibalise += 1
    #     sfstr.gsub!(/#{Regexp.escape tout}/, "\n\n:::BALISE#{ibalise}:::\n\n")
    #     hbalises.merge!(ibalise => "\n#{tout}")
    #   else
    #     break
    #   end
    # end

    # # DEBUG
    # debug "\n\nSTR APRÈS BALISAGE :\n#{sfstr.inspect.gsub(/</,'&lt;')}"
    # # /DEBUG

    # ÇA FOIRE AVEC :
    # sfstr = sfstr.kramdown
    # ÇA FOIRE AUSSI AVEC :
    # sfstr = Kramdown::Document.new(sfstr).to_html


    # # DEBUG
    # debug "\n\nSTR APRÈS KRAMDOWN:\n#{sfstr.inspect.gsub(/</,'&lt;')}"
    # # /DEBUG
    #
    # # On remet les balises en place
    # hbalises.each do |ibalise, balcontent|
    #   sfstr.gsub!(/<p>:::BALISE#{ibalise}:::<\/p>/, "\n#{balcontent}\n")
    # end
    #
    # sfstr.gsub!(/\n\n+/,"\n\n")
    #
    # # DEBUG
    # debug "\n\nSTR APRÈS REBALISAGE:\n#{sfstr.gsub(/</,'&lt;')}"
    # # /DEBUG
    #
    # return sfstr
  end

  class << self
    def folder_textes_exemples_in_cours
      @folder_textes_exemples_in_cours ||= SuperFile.new('./data/unan/pages_cours/cnarration/exemples/_textes_')
    end
    def folder_textes_exemples_in_semidyn
      @folder_textes_exemples_in_semidyn ||= SuperFile.new('./data/unan/pages_semidyn/cnarration/exemples/_textes_')
    end
  end

  # Évalue le code situé entre balise RUBY_ et _RUBY
  #
  # Par mesure de prudence, cette opération n'est possible qu'en
  # offline
  #
  def evaluate_codes_ruby
    OFFLINE || (return self)
    str = self
    str.gsub!(/RUBY_(.*?)_RUBY/m){
      code_ruby = $1.strip
      eval(code_ruby)
    }
    return str
  end

  # Formatage des notes
  # Cf. le mode d'emploi (narration) pour le détail de l'utilisation.
  # Résumé : les notes doivent être formatées de cette façon :
  #     Texte avec note {{1}}
  #     <!-- NOTES -->
  #     {{1: Ceci est la première note}}
  #     <!-- /NOTES -->
  # Peu importe l'ordre des numéros, ils seront toujours remplacés par
  # des numéros incrémentés.
  #
  def formate_balises_notes

    # Il ne faut procéder au formatage que s'il y a des notes
    self =~ /\{\{([0-9]+)\}\}/ || (return self)

    str = self

    str.gsub!(/\{\{([0-9]+)\}\}\{\{([0-9]+)\}\}/){
      "{{#{$1}}}<sup class='virgule'>,</sup>{{#{$2}}}"
    }

    # Pour conserver la correspondance entre l'ID de note attribué au
    # cours de la rédaction et l'INDEX attribué ici pour avoir un ordre
    # incrémentiel (alors que les ID ne se trouvent pas forcément dans
    # l'ordre du document)
    # C'est un Array avec en clé l'ID donné à la rédaction et en valeur
    # un Hash contenant {:id, :index}
    liste_notes = Hash.new

    # Pour incrémenter régulièrement les index de note
    inote = 0

    # Remplacement des renvois aux notes et collecte
    # des notes
    #
    str.gsub!(/ ?\{\{([0-9]+)\}\}/){
      # L'identifiant attribué dans le document
      id_note = $1.freeze

      if liste_notes.key?(id_note)
        index_note = liste_notes[id_note][:index]
      else
        # L'index réel pour que les notes soient dans l'ordre
        inote += 1
        index_note = inote.freeze
        liste_notes.merge!(id_note => {id: id_note, index: index_note})
      end
      "<sup class='note_renvoi'>#{index_note}</sup>"
    }

    # On classe la liste des notes
    liste_notes = liste_notes.sort_by{|idnote, dnote| dnote[:index]}
    # debug "liste_notes : #{liste_notes.inspect}"

    # Recherche des blocs `<!-- NOTES -->`...`<!-- /NOTES -->`
    # pour traiter les notes. Ce bloc doit forcément être présent, qui
    # contient la définition des notes.
    if str =~ /<\!-- NOTES -->/ && str =~ /<\!-- \/NOTES -->/
      str.gsub!(/<\!-- NOTES -->(.*?)<\!-- \/NOTES -->/m){
        def_notes = $1.strip.freeze
        notes_sorted = String.new
        liste_notes.each do |idnote, dnote|
          if def_notes =~ /\{\{#{idnote}:/
            def_note = def_notes.match(/\{\{#{idnote}:(.*?)\}\}/).to_a[1].strip
            notes_sorted << "#{dnote[:index]}   #{def_note}".in_div(class: 'small')
          end
        end

        # On remplace le bloc par la liste des notes classées
        notes_sorted.in_div(class: 'bloc_notes')
      }
    else
      raise 'Des notes sont présentes dans cette page, il faut impérativement définir la définition de ces notes entre la balise `&lt;!-- NOTES -->` et la balise `&lt;!-- /NOTES -->`.'
    end

    return str
  end

  def formate_balises_references
    str = self
    str.gsub!(/REF\[(.*?)\]/){
      pid, ancre, titre = $1.split('|')
      if titre.nil? && ancre != nil
        titre = ancre
        ancre = nil
      end
      lien.cnarration(to: :page, from_book:$narration_book_id, id: pid.to_i, ancre:ancre, titre:titre)
    }
    str
  end

  # Formate les balises images
  #
  # +subfolder+ {String} Un nom de dossier qui peut être transmis
  # parfois pour indiquer un dossier narration ou un dossier
  # d'analyse.
  #
  def formate_balises_images subfolder = nil
    return self unless self.match(/IMAGE\[/)
    self.gsub!(/IMAGE\[(.+?)\]/){
      path, title, legend, expfolder = $1.split('|')
      imgpath = String.seek_image_path_of( path, subfolder || expfolder)
      title.nil? || title = title.gsub(/'/, "’")
      if imgpath != nil

        # La légend, if any
        # La légende peut avoir trois valeur :
        #   1. être nil   => Rien
        #   2. être ""    => On prend le titre comme légende
        #   3. être définie comme telle
        legend =
          case legend
          when "="          then title
          when nil, "null"  then nil
          else legend
          end
        legend = legend.nil? ? "" : "<div class='img_legend'>#{legend}</div>"


        attrs = {}

        # Si `title` se termine par '%', c'est une taille
        # à prendre en compte
        title == nil || begin
          unless (rs = title.scan(/ ?([0-9]{1,3})%$/)).empty?
            taille  = rs.first.first.to_i
            attrs.merge!(style: "width:#{taille}%")
            # Ce qu'il reste du titre
            title   = title.sub(/ ?([0-9]{1,3})%$/, '').strip
          end
        end
        # Soit title est un titre alternatif (qui pourra
        # servir de légende si légende non définie) ou bien
        # c'est un indicateur de position de l'image.
        # Le texte construit retourné
        case title
        when 'inline'
          imgpath.in_img( attrs )
        when 'fright', 'fleft'
          attrs.merge!( class:"image_#{title}" )
          (imgpath.in_img + legend).in_div( attrs )
        else
          title =
            if title == 'plain'
              attrs.merge!(style: 'width:100%')
              ""
            else
              " alt=\"Image : #{title}\""
            end
          attrs = attrs.collect { |attr, val| "#{attr}=\"#{val}\"" }.join(' ')
          img_tag = "<img src=\"#{imgpath}\"#{title} #{attrs} />"
          "<center class='image'><div class='image'>#{img_tag}</div>#{legend}</center>"
        end
      else
        "IMAGE MANQUANTE: #{imgpath} (avec #{path} fourni)"
      end

    }
  end

  def formate_balises_mots
    str = self
    str.gsub!(/MOT\[([0-9]+)\|(.*?)\]/){ lien.mot($1.to_i, $2.to_s) }
    str
  end

  def formate_balises_citations
    str = self
    str.gsub!(/CITATION\[([0-9]+)\|(.*?)\]/){ lien.citation($1.to_i, $2.to_s) }
    str
  end

  def formate_balises_films
    str = self
    str.gsub!(/FILM\[(.*?)(?:\|(.*?))?\]/){ lien.film($1.to_s, {titre: $2}) }
    str
  end

  def formate_balises_scenes # Analyses
    str = self
    str.gsub!(/SCENE\[(.*?)\]/){
      numero, libelle, extra = $1.split('|').collect{|e| e.strip}
      # Je ne sais plus à quoi sert `extra`, il peut avoir
      # la valeur 'true'
      libelle ||= "scène #{numero}"
      libelle.in_a(onclick:"$.proxy(Scenes,'show',#{numero})()")
    }
    str
  end

  def formate_balises_livres
    str = self
    str.gsub!(/LIVRE\[(.*?)\]/){
      ref, titre = $1.split('|')
      lien.livre(titre, ref)
    }
    str.formate_balises_colon('livre')
  end

  def formate_balises_personnages
    self.formate_balises_colon('personnage')
  end

  def formate_balises_acteurs
    self.formate_balises_colon('acteur')
  end

  def formate_balises_realisateurs
    self.formate_balises_colon('realisateur')
  end

  def formate_balises_producteurs
    self.formate_balises_colon('producteur')
  end

  def formate_balises_auteurs
    self.formate_balises_colon('auteur')
  end

  def formate_termes_techniques
    self.formate_balises_colon('tt')
  end

  def formate_balises_colon balise
    str = self
    str.gsub!(/#{balise}:\|(.*?)\|/, "<#{balise}>\\1</#{balise}>")
    str.gsub!(/#{balise}:(.+?)\b/, "<#{balise}>\\1</#{balise}>")
    str
  end


  # Méthodes utiles pour trouver comment interpréter
  # le path (relatif) fourni en argument pour une
  # balise IMAGE
  #
  # Cf. aide
  #
  # Dans l'ordre, le path relatif peut être :
  #
  #   - Un path depuis la racine (on le garde tel quel)
  #   - Un path depuis le dossier général ./view/img/
  #   - Un path depuis le dossier img général Narration
  #     ./data/unan/pages_semidyn/cnarration/img
  #   - Un path depuis un dossier img d'un livre Narration
  #     Le folder doit alors être fourni en argument
  #   - Un path depuis le dossier img général Analyse
  #     ./data/analyse/image
  #   - Un path depuis le dossier img d'une analyse en particulier
  #     Le `folder` doit alors être fourni en 2nd argument
  #
  def self.seek_image_path_of relpath, folder = nil
    debug "\n* RECHERCHE IMAGE *\n* relpath: #{relpath.inspect}\n* folder: #{folder.inspect}"
    extensions =
      if File.extname(relpath) == ''
        ['.png','.jpg', '.gif']
      else
        ['']
      end
    [
      '',
      './view/img/',
      "./data/unan/pages_semidyn/cnarration/img/",
      "./data/unan/pages_semidyn/cnarration/#{folder}/img/",
      "./data/unan/pages_semidyn/cnarration/img/#{folder}/",
      "./data/analyse/image/",
      "./data/analyse/#{folder}/img/",
      "#{folder}" # narration ou autre
    ].each do |prefix_path|
      goodaffixe = "#{prefix_path}#{relpath}"
      extensions.each do |ext|
        goodpath = "#{goodaffixe}#{ext}"
        File.exist?(goodpath) && begin
          debug "BON PATH IMAGE : #{goodpath}"
          return goodpath
        end
        debug "Mauvais path Image : #{goodpath}"
      end
    end
    return nil
  end

end #/String
