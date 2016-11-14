# encoding: UTF-8
class AnalyseBuild

  # Méthode principale appelée pour construire les brins, c'est-à-dire
  # prendre la liste des scènes et fabriquer chaque brin à partir de
  # cette liste.
  #
  # Le fichier produit est en HTML et contient la définition de
  # chaque brin, comme des mini-évènemenciers.
  #
  def build_brins
    code_html =
      brins_as_hash.collect do |bid, hbrin|
        hbrin[:titre].in_div(class:'titre') +
        hbrin[:scenes].collect do |sid|
          hscene = scenes[sid - 1]
          "– <b>Scène #{sid}</b> : #{hscene[:resume]}".in_div
        end.join('').in_div(class: 'brin')
      end.join
    brins_html_file.write code_html
    flash "Fichier brins construit avec succès."
  end

  # Méthode qui récolte chaque paragraphe de brin
  #
  # RETURN Un Hash avec en clé l'identifiant du brin et en
  # valeur la liste de toutes les scènes qu'il contient
  def brins_as_hash
    @brins_as_hash ||= begin

      # On prépare le hash qui contiendra les paragraphes et les scènes de
      # chaque brin. Le contenu préféré, ce sont les paragraphes, mais en cas
      # d'absence de paragraphe (lorsque la scène est définie en une seule
      # ligne) on prend la donnée de la scène.
      # TODO : Peut-être qu'il serait plus simple, au moment du parsing du
      # fichier de collecte, de mettre dans :data_paragraphe le résumé lorsqu'il
      # n'y a pas de paragraphe. De cette manière, ici, on n'aurait à traiter
      # que les paragraphes.
      h = Hash.new
      brins.each do |hbrin|
        h.merge!(hbrin[:id] => hbrin.merge(paragraphes: Array.new, scenes: Array.new))
      end

      scenes.each do |hscene|
        sid   = hscene[:id]
        dparagraphes = hscene[:data_paragraphes]
        if dparagraphes.nil? || dparagraphes.empty?
          hscene[:brins_ids].each do |bid|
            # Si un brin défini dans une scène n'existe pas
            h.key?(bid) || raise("Données incorrectes : le brin ##{bid} de la scène ##{sid} (#{hscene[:resume][0..30]}...) n'existe pas.")
            h[bid][:scenes] << sid
          end
        else
          dparagraphes.each_with_index do |data_paragraphe, para_index|
            debug "data_paragraphe : #{data_paragraphe.inspect}"
            data_paragraphe[:brins].each do |bid|
              h.key?(bid) || raise("Données incorrectes : le brin ##{bid} du paragraphe #{para_index} de la scène #{sid} (#{hscene[:resume][0..30]}...) n'existe pas.")
              h[bid][:paragraphes] << data_paragraphe
            end
          end
        end
      end
      h
    end
  end

end #/AnalyseBuild
