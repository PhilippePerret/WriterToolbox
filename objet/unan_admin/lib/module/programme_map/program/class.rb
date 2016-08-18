# encoding: UTF-8
=begin
Nomenclature
  STRT   Structure
  PERS   Personnage
  DYNA   Dynamique
  THEM   Thématique
  DOCU   Documentation
  ANAF   Analyse de film

  WORK ID du travail absolu.
  PAGE ID de la page de cours propre au programme

  NOTE
    * Il suffit d'indiquer [WORK] ou [PAGE], etc. pour créer un lien qui
      va permettre de créer un work, etc. (sûr pour les works mais à voir
      pour les autres éléments)

=end
raise_unless_admin

class UNANProgramme
  include Singleton

  def raw_code
    @raw_code ||= (UnanAdmin.folder + 'PROGRAMME.TXT').read
  end
  # /raw_code

end
