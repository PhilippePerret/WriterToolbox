# encoding: UTF-8
class AnalyseBuild

  # = main =
  #
  # Développe les données collectées. Par exemple, ajoute les
  # paragraphes aux brins.
  #
  def developpe_data
    suivi '* Développement de toutes les données…'
    @data_brins   = brins_file.exist?   ? Marshal.load(brins_file.read) : Hash.new
    @data_scenes  = scenes_file.exist?  ? Marshal.load(scenes_file.read)  : Hash.new
    @data_personnages = personnages_file.exist? ? Marshal.load(personnages_file.read) : Hash.new
    debug "\n\n\n@data_brins : #{@data_brins.inspect}"
    debug "\n\n\n@data_scenes : #{@data_scenes.inspect}"
    debug "\n\n\n@data_personnages : #{@data_personnages.inspect}"

    # Définir les paragraphes des brins
    set_paragraphes_of_brins || return


  rescue Exception => e
    debug e
    error "Erreur au cours du développement des données : #{e.message}"
  else
    true # pour poursuivre
  end
  # /developpe_data

  # Methode qui met dans la donnée brins les paragraphes relevés
  #
  # Rappel : chaque paragraphe possède un identifiant propre qui
  # permet de l'identifier. La donnée `paragraphes_ids` du brin
  # contient la liste de ces identifiants.
  #
  # Pour le faire, on passe en revue toutes les scènes, tous les paragraphes
  # de scènes et on regarde leur brin.
  # En plus s'ajoutent les brins de la scène elle-même.
  #
  # RETURN true en cas de succès ou false dans le cas contraire
  #
  def set_paragraphes_of_brins

    suivi '** Ajout des paragraphes et scènes aux brins…'

    # On prépare un hash avec en clé l'identifiant du brin et en
    # valeur ses données. On ajoute à cette données la propriété
    # `paragraphes_ids` qui contiendra les identifiants des paragraphes
    # des brins.
    hbrins = Hash.new
    @data_brins.each do |data_brin|
      hbrins.merge!(data_brin[:id] => data_brin.merge(para_or_scene_ids: Array.new))
    end

    @data_scenes.each do |data_scene|

      # Données des paragraphes de la scène
      dparagraphes = data_scene[:data_paragraphes]

      # Traitement des brins de la scène
      # Rappel : ça n'est pas les brins associés à des paragraphes de la
      # scène, ce sont les brins définis sur une ligne seule, avec tous les
      # relatifs.
      # Dans ce cas, tous les paragraphes de la scène sont associés à ce
      # brin. Si la scène n'a pas de paragraphes, son numéro est entré dans
      # la liste des identifiants.
      unless data_scene[:brins].empty?
        data_scene[:brins].each do |bid|
          if dparagraphes.empty?
            # Quand il n'y a pas de paragraphe
            hbrins[bid][:para_or_scene_ids] << data_scene[:numero]
          else
            dparagraphes.each do |dparagraphe|
              hbrins[bid][:para_or_scene_ids] << dparagraphe[:id]
            end
          end
        end
      end

      # Traitement des paragraphes de la scène.
      # Si ces paragraphes appartiennent à des brins, on
      # les ajoute à ces brins
      unless dparagraphes.empty?
        dparagraphes.each do |data_paragraphe|
          paragraphe_id = data_paragraphe[:id]
          data_paragraphe[:brins].each do |bid|
            hbrins[bid][:para_or_scene_ids] << paragraphe_id
          end
        end
      end
    end
    # /fin de boucle sur toutes les scènes

    # On finit en s'assurant qu'il n'y a pas de doublons
    hbrins.each do |bid, bdata|
      hbrins[bid][:para_or_scene_ids] = bdata[:para_or_scene_ids].uniq
    end


    debug "\n\n\nhbrins à la fin : #{hbrins.pretty_inspect}"

    # Enregistrement des nouvelles données
    brins_file.write(Marshal.dump(hbrins))
    @data_brins = hbrins

  rescue Exception => e
    debug e
    error "Erreur au cours de l'ajout des paragraphes dans les brins : #{e.message}"
  else
    true # pour poursuivre ?
  end

end #/AnalyseBuild
