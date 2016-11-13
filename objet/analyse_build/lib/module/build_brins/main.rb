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

  # Méthode qui récolte chaque scène de brin
  #
  # RETURN Un Hash avec en clé l'identifiant du brin et en
  # valeur la liste de toutes les scènes qu'il contient
  def brins_as_hash
    @brins_as_hash ||= begin
      h = Hash.new
      brins.each do |hbrin|
        h.merge!(hbrin[:id] => hbrin.merge(scenes: Array.new))
      end
      scenes.each do |hscene|
        sid   = hscene[:id]
        hscene[:brins_ids].each do |bid|
          # Si un brin défini dans une scène n'existe pas
          h.key?(bid) || raise("Données incorrectes : le brin ##{bid} de la scène ##{sid} (#{hscene[:resume][0..30]}...) n'existe pas.")
          h[bid][:scenes] << sid
        end
      end
      h
    end
  end

end #/AnalyseBuild
