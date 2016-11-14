# encoding: UTF-8
class AnalyseBuild

  # = main =
  #
  # Développe les données collectées. Par exemple, ajoute les
  # paragraphes aux brins.
  #
  def developpe_data
    @data_brins   = brins_file.exist?   ? Marshal.load(brins_file.read) : Hash.new
    @data_scenes  = scenes_file.exist?  ? Marshal.load(scenes_file.read)  : Hash.new
    @data_personnages = personnages_file.exist? ? Marshal.load(personnages_file.read) : Hash.new
    debug "\n\n\n@data_brins : #{@data_brins.inspect}"
    debug "\n\n\n@data_scenes : #{@data_scenes.inspect}"
    debug "\n\n\n@data_personnages : #{@data_personnages.inspect}"

    # Définir les paragraphes des brins
    set_paragraphes_of_brins

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
  def set_paragraphes_of_brins

    # On prépare un hash avec en clé l'identifiant du brin et en
    # valeur ses données. On ajoute à cette données la propriété
    # `paragraphes_ids` qui contiendra les identifiants des paragraphes
    # des brins.
    hbrins = Hash.new
    @data_brins.each do |data_brin|
      hbrins.merge!(data_brin[:id] => data_brin.merge(paragraphes_ids: Array.new))
    end

    @data_scenes.each do |data_scene|
      dparagraphes = data_scene[:data_paragraphes]
      unless dparagraphes.empty?
        dparagraphes.each do |data_paragraphe|
          paragraphe_id = data_paragraphe[:id]
          data_paragraphe[:brins].each do |bid|
            hbrins[bid][:paragraphes_ids] << paragraphe_id
          end
        end
      end
    end
    
  end

end #/AnalyseBuild
