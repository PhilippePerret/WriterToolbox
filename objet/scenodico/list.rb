# encoding: UTF-8
class Scenodico
  class << self

    # Affichage du scénodico sous forme de panneaux par lettres
    # avec un alphabet qui permet d'afficher chaque panneau
    # C'est l'affichage du dictionnaire classique
    def in_panneaux

      # On récolte tous les mots pour les mettre dans des panneaux, un
      # panneau par lettre
      panneaux = Hash::new
      list(as: :data, colonnes:[:mot]).each do |hmot|
        first_letter = hmot[:letters][0].capitalize
        unless panneaux.key? first_letter
          panneaux.merge!(first_letter => Array::new)
        end
        panneaux[first_letter] << "#{hmot[:mot]}".in_a(href:"scenodico/#{hmot[:id]}/show", target:'_mot_scenodico_', class:'mot')
      end

      # On construit les panneaux (seul le premier est affiché)
      alphabet = ""
      panneaux = panneaux.collect do |letter, arr_letter|
        alphabet << letter.in_a(id:"letter#{letter}", class:(letter == 'A' ? 'active' : nil), onclick:"$.proxy(Scenodico,'show_panneau','#{letter}')()")
        arr_letter.join.in_section(class:'panneau', id:"panneau_#{letter}", style:(letter == 'A' ? '' : "display:none"))
      end.join

      alphabet.in_div(id:'alphabet') + panneaux.in_div(id:'panneaux_letters')
    end

  end # /<< self
end # Scenodico
