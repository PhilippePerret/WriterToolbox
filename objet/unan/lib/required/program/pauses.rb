# encoding: UTF-8
=begin

  Module permettant de gérer les pauses du programme.

  TODO
    Prendre en compte les pauses effectuées. Pour le moment,
    on ne peut que mettre en pause et sortir de pause, mais
    le temps n'est pas recalculé en fonction.

=end
class Unan
class Program

  # {Array de Hash}
  # Retourne les pauses enregistrées (ou un Array vide)
  # Chaque élément est un Hash contenant {:start, :end}
  # Lorsqu'une pause est en cours, les options commencent
  # par '01' et le dernière élément de ce Array ne définit
  # que :start, tandis que :end est à nil.
  #
  # NOTE IMPORTANTE : ne pas utiliser le termes `pauses`
  # qui est le nom de la colonne, même si a priori ça n'est
  # pas un problème majeur.
  #
  def get_pauses
    JSON.parse(get(:pauses) || '[]').to_sym
  end

  # Enregistre les nouvelles pauses.
  # Cf. le fichier
  # ./objet/unan_admin/lib/module/programmes_courants/program/methods.rb
  # qui utilise cette méthode.
  def set_pauses _pauses
    set(pauses: _pauses.to_json)
  end

  # Retourne la durée totale de toutes les pauses de l'auteur
  def pause_duration
    d = 0
    get_pauses.each do |hpause|
      hpause[:end] != nil || next
      d += hpause[:end] - hpause[:start]
    end
    return d
  end

end #/Program
end #/Unan
