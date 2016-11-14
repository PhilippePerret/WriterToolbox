# encoding: UTF-8
module ModuleParseRelatifs

  def brins       ; @brins        ||= Array.new end
  def personnages ; @personnages  ||= Array.new end
  def notes       ; @notes        ||= Array.new end
  def scenes      ; @scenes       ||= Array.new end

  # Méthodes qui traite les marques qui suivent le texte du paragraphe
  # Ces marques contiennent les relations aux relatifs. Par exemple,
  # si on trouve la marque "B23", ça signifie que le paragraphe appartient
  # au brin 23.
  #
  # La méthode appelante doit définir @liste_relatifs, la liste string
  # des relatifs à traiter.
  #
  # PRODUIT
  #   La mise des identifiants dans @brins, @personnages, @notes et @scenes
  #   Ces propriétés n'ont pas besoin d'être définies dans la classe
  #   puisqu'elles sont définies ci-dessus
  #
  # Noter que ces marques peuvent ne pas exister ou être nil.
  #
  # C'est la première lettre qui détermine la nature de la marque :
  #   B   Un brin
  #   P   Un personnage
  #   N   Une note
  #   S   Une scène
  #   etc.
  #
  def parse_relatifs

    marques = @liste_relatifs
    marques = marques.nil_if_empty
    marques != nil || (return false)

    marques.split(' ').each do |marque|
      lettre1 = marque[0]
      marque_id = marque[1..-1].to_i
      if marque_id > 0
        case lettre1
        when 'B'  then brins << marque_id
        when 'N'  then notes << marque_id
        when 'P'  then personnages << marque_id
        when 'S'  then scenes << marque_id
        else
          @errors << {who: self, error: "Identifiant de marque inconnu : #{marque}"}
        end
      else
        @errors << {who: self, error: "Mauvaise marque (#{marque})"}
      end
    end
    return true
  end

end #/ ModuleParseRelatifs
