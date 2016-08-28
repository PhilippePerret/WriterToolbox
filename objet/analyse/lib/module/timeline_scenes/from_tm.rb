# encoding: UTF-8
class FilmAnalyse
class << self

  attr_reader :args_tm

  # Méthode principale qui prend en argument un fichier
  # de collecte type TM et en tire un fichier HTML de timeline
  # de scène
  def from_tm_to_timeline fpath

    @args_tm = {
      folder:       File.dirname(fpath),
      data_scenes:  Array.new,
      personnages:  Hash.new
    }

    # PREMIÈRE ÉTAPE : Fichier personnages
    # -------------------------------------
    # On doit parser le fichier personnages pour savoir par quoi
    # remplacer les balises [PERSO#<id perso>]
    #
    # Produit @args_tm[:personnages]
    #
    parse_persos_tm_film fpath

    # ÉTAPE : Extraction des scènes
    # ---------------------------------------
    # Cette première étape prend les temps des
    # scènes du fichier de collecte et peuple la
    # données data_scenes qui sera mise dans les
    # arguments à envoyer à la méthode `build_timeline_scenes`
    parse_tm_film fpath

    # SECONDE ÉTAPES : Construction
    # -----------------------------
    # On envoie les données à la méthode principale qui va
    # construire le fichier.
    build_timeline_scenes @args_tm
  end

  REG_HORLOGE = /(([0-9]:)?[0-9]{1,2}:[0-9]{1,2})/o
  def parse_tm_film fpath
    code_tm = File.open(fpath,'r'){|f| f.read.force_encoding('utf-8')}
    num_scene   = 0
    last_scene  = nil
    lines = code_tm.split("\n")
    while line = lines.shift
      case line
      when /^FIN/
        tim_scene = line.match(/^FIN:(#{REG_HORLOGE})$/).to_a[1].h2s
        last_scene = {
          numero:   nil,
          resume:   'FIN',
          time:     tim_scene
        }
        next
      when /^SCENE/
        tim_scene = line.match(/^SCENE:(#{REG_HORLOGE})$/).to_a[1].h2s
        until line.strip.start_with?('RESUME:')
          line = lines.shift
        end
        res_scene = line.strip.sub(/^RESUME:/,'').strip
        res_scene = remplace_persos_in res_scene
      else
        next
      end

      num_scene += 1
      data_scene = {
        numero:   num_scene,
        resume:   res_scene,
        time:     tim_scene
      }
      @args_tm[:data_scenes] << data_scene
    end
    if last_scene
      @args_tm[:data_scenes] << last_scene
    end
  end

  # Remplacer les balises [PERSO#....] dans le texte str
  def remplace_persos_in str
    str.gsub!(/\[PERSO#([a-zA-Z_]+)\]/){
      tag_perso = $1.freeze
      if @args_tm[:personnages].key?(tag_perso)
        perso = @args_tm[:personnages][tag_perso][:patronyme]
        "personnage:|#{perso}|"
      else
        "[PERSONNAGE INTROUVABLE : #{tag_perso}]"
      end
    }
    return str
  end

  # Parser le fichier personnages pour récupérer tous les personnages
  def parse_persos_tm_film fpath
    # Path du fichier personnages
    folder = File.dirname(fpath)
    faffix = File.basename(fpath, File.extname(fpath))
    fpath_persos = File.join(folder, "#{faffix}.persos")
    File.exist?(fpath_persos) || return
    code_persos = File.open(fpath_persos,'r'){|f| f.read.force_encoding('utf-8')}

    arr_persos = Array.new
    code_persos.split("\n").each do |line|
      line = line.strip
      line != "" || next
      case line
      when /^PERSONNAGE:/
        # On crée un nouveau personnage courant
        val = value_property_perso(line, 'personnage')
        arr_persos << {key: val[:personnage], prenom: nil, nom: nil, pseudo: nil}
      when /^PRENOM/
        arr_persos[-1].merge!(value_property_perso(line, 'prenom'))
      when /^NOM/
        arr_persos[-1].merge!(value_property_perso(line, 'nom'))
      when /^PSEUDO/
        arr_persos[-1].merge!(value_property_perso(line, 'pseudo'))
      end
    end

    hpersos = Hash.new
    arr_persos.each do |hperso|
      hperso.merge!(patronyme: (hperso[:pseudo] || "#{hperso[:prenom]||''} #{hperso[:nom]||''}".strip))
      hpersos.merge! hperso[:key] => hperso
    end

    @args_tm[:personnages] = hpersos
  end
  # /parse_persos_tm_film

  def value_property_perso line, tag
    val = line.sub(/^#{tag.upcase}:/, '').strip
    val = nil if val == 'nil'
    {tag.to_sym => val}
  end

end #/<< self
end #/FilmAnalyse
