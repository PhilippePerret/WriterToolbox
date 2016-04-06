# encoding: UTF-8
class Cnarration
class Search

  class << self
    # La recherche courante
    attr_reader :current_search

    # Retourne le code HTML pour le formulaire de recherche
    def formulaire
      site.require 'form_tools'
      form.prefix = "csearch"

      "Formulaire".in_a(onclick:"$('form#search_form').toggle()").in_div(class:'right small', display: current_search!=nil) +
      (
        "proceed_search_in_narration".in_hidden(name: 'operation') +
        form.field_text("Rechercher", :content) +
        form.field_checkbox("Chercher dans les titres", :search_in_titre) +
        form.field_checkbox("Chercher dans les textes", :search_in_texte) +
        form.field_checkbox("Recherche par expression régulière", :regular_search) +
        form.field_checkbox("Rechercher l'expression exacte (min/maj)", :search_exact) +
        form.field_checkbox("Rechercher les mots entiers", :search_whole_word) +
        form.submit_button("Chercher")
      ).in_form(id:'search_form', action: "cnarration/search", class:'dim3070', display: current_search.nil?)
    end

  end # /<<self
end #/Search
end #/Cnarration
