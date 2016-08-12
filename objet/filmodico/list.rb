# encoding: UTF-8
class Filmodico
  class << self

    # Retourne la liste de tous les films comme des panneaux par
    # classement alphabétique
    def as_panneaux
      # On récolte tous les films pour les mettre dans des panneaux, un
      # panneau par lettre
      panneaux = Hash.new
      list(as: :data, colonnes:[:titre]).each do |hfilm|
        first_letter = hfilm[:letters][0].capitalize
        unless panneaux.has_key? first_letter
          panneaux.merge!(first_letter => Array::new)
        end
        panneaux[first_letter] << "#{hfilm[:titre]}".in_a(href:"filmodico/#{hfilm[:id]}/show", target:'_film_filmodico_', class:'film')
      end

      # On construit les panneaux (seul le premier est affiché)
      alphabet = ""
      panneaux = panneaux.collect do |letter, arr_letter|
        alphabet << letter.in_a(id:"letter#{letter}", class:(letter == 'A' ? 'active' : nil), onclick:"$.proxy(Filmodico,'show_panneau','#{letter}')()")
        arr_letter.join.in_section(class:'panneau', id:"panneau_#{letter}", style:(letter == 'A' ? '' : "display:none"))
      end.join

      alphabet.in_div(id:'alphabet') + panneaux.in_div(id:'panneaux_letters')

    end

  end #/<< self
end #/Filmodico
