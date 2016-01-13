# encoding: UTF-8
class Unan
class Bureau

  include Singleton

  # Lien vers le panneau-onglet "État (des lieux)" sur le
  # bureau de l'user
  # @usage : <%= bureau.lien_etat %>
  def lien_etat titre = nil, options = nil
    (titre||"État des lieux").in_a( data_lien(:state, options) )
  end

  # Lien vers le panneau-onglet "Travaux" sur le bureau
  # @usage : <%= bureau.lien_travail("votre travail") %>
  def lien_travail titre = nil, options = nil
    (titre||"Travaux").in_a( data_lien(:travaux, options) )
  end
  alias :lien_travaux :lien_travail

  # @usage : <%= bureau.lien_quiz %>
  def lien_quiz titre = nil, options = nil
    (titre||"Quiz").in_a( data_lien(:quiz, options) )
  end
  alias :lien_questionnaires :lien_quiz

  # Vers le panneau-onglet contenant les messages du forum
  # @usage : <%= bureau.lien_messages("mes messages") %>
  def lien_messages
    (titre||"Messages forum").in_a( data_lien(:forum, options) )
  end

  # Vers le panneau-onglet contenant les pages de cours à
  # lire
  # @usage : <%= bureau.lien_pages_cours("mes pages à lire") %>
  def lien_pages_cours
    (titre||"Pages de cours").in_a( data_lien(:pages_cours, options) )
  end

  # Lien vers le panneau-onglet "préférences" sur le bureau
  # de l'user
  # @usage : <%= bureau.lien_preferences("vos préférences") %>
  def lien_preferences titre = nil, options = nil
    (titre||"Préférences").in_a( data_lien(:preferences, options) )
  end


  # Bouton submit
  # Pour avoir une cohérence entre les panneaux
  # @usage    bureau.submit_button
  def submit_button name = "Enregistrer"
    @submit_button ||= begin
      subbtn = form.submit_button(name)
      subbtn.sub!(/class="btn"/, 'class="btn tiny discret"')
    end
  end

  # ---------------------------------------------------------------------
  #   Méthodes fonctionnelles
  # ---------------------------------------------------------------------
  def data_lien onglet_id, options
    data_lien = {href: "bureau/home?in=unan&cong=#{onglet_id}"}
    data_lien.merge!(options) unless options.nil?
    data_lien
  end

end # /Bureau
end # /Unan
