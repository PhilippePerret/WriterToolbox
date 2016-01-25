# encoding: UTF-8
=begin
Méthodes d'helper des instances Unan::Quiz::Question
=end
class Unan
class Quiz
class Question

  # Mise en forme de la question pour affichage
  # +user_reponse+ Si défini, il faut :
  #   - mettre en exergue la bonne réponse
  #   - mettre en exergue la réponse erronée de l'auteur
  #   - afficher le pourquoi de la bonne réponse.
  # Note : Les réponses de l'utilisateur se trouvent dans
  # +user_reponse+.
  # Rappel : il y a la "bonne" et la "meilleur" réponse suivant
  # que :
  #   Si toutes les réponses sont à 0 sauf 1 => une seule réponse
  #   possible => la "bonne"
  #   Si ≠ points pour ≠ réponses, alors plusieurs réponses possibles
  #   mais une "meilleure", celle qui a le plus de points.
  # Il y aura "bonne", "meilleure" et "pire" réponse.
  def output user_reponse = nil

    unless exist?
      return "[Question ##{id} inexistante]"
    end

    correction_questionnaire = user_reponse != nil

    # Préfix de tous les objets DOM
    prefix = quiz_id.nil? ? "quiz" : "quiz-#{quiz_id}"

    # Pour pouvoir ajouter des propriétés aux réponses de
    # la question, dans le cas où c'est une correction de
    # formulaire, sans modifier la propriété `reponses`
    # originale.
    thereps = reponses.dup

    # Si c'est une correction de questionnaire, il faut
    # faire un premier tour sur les réponses pour les comparer avec
    # les réponses de l'utilisateur. Cela permettra de marquer les
    # types (classes) à affecter aux affichages des réponses ci-desous,
    # à savoir :
    #   - si c'est une bonne réponse, la réponse est mise en vert
    #     elle est sélectionné pour un menu.
    #   - si c'est une mauvaise réponse, la réponse est mise en rouge
    #
    if correction_questionnaire
      # On part du principe que cette question a bien été répondu
      reponse_is_right = true

      rights = Hash::new
      wrongs = Hash::new
      # On fait d'abord un Hash des réponses pour pouvoir les
      # manipuler plus facilement
      hreponses = Hash::new

      thereps.each do |hr|
        # On met cette réponse dans le hash de données de
        # la question.
        hreponses.merge!(hr[:id] => hr)
        # Les points pour cette réponse.
        # On en a besoin si c'est un affichage des réponses au
        # questionnaire.
        points = hr[:points].freeze
        # Pour le moment, quel que soit le type de réponse, on
        # mémorise cette réponse comme bonne ou mauvaise réponse
        # en fonction de son nombre de points.
        if points > 0
          rights.merge! hr[:id] => {id: hr[:id], points: points}
        else
          wrongs.merge! hr[:id] => {id: hr[:id], points: points}
        end
      end # / boucle sur les réponses, en cas de correction de formulaire

      une_seule_bonne_reponse = (rights.count == 1)
      # debug "rights: #{rights.pretty_inspect}"
      # debug "une_seule_bonne_reponse = #{une_seule_bonne_reponse.inspect}"
      if une_seule_bonne_reponse
        # => Une seule "bonne" réponse
        good_or_best = rights.values.first
      else
        # => Une "meilleure" réponse
        good_or_best = rights.sort_by{ |k, h| h[:points] }.reverse.first[1]
      end
      # Maintenant qu'on a récupéré la ou les bonnes réponses, on
      # les indique dans les réponses en indiquant aussi si c'est
      # une mauvaise réponse de l'utilisateur.
      hreponses.each do |rid, rdata|

        # On "marque" la bonne ou la meilleure réponse
        if rid == good_or_best[:id]
          hreponses[rid].merge!(
            label:  "#{une_seule_bonne_reponse ? 'bonne' : 'meilleure'} réponse",
            result: (une_seule_bonne_reponse ? 'good' : 'best')
          )
          # S'il y a une seule bonne réponse et que l'user n'a pas
          # donné celle-là, on signale que sa réponse est mauvaise.
          if une_seule_bonne_reponse && user_reponse[:value] != rid
            # hreponses[user_reponse[:value]].merge!(result: 'wrong')
            reponse_is_right = false
          end
        elsif wrongs.keys.include?(rid)
          # On "marque" une mauvaise réponse de l'utilisateur
          if (user_reponse[:value].instance_of?(Array) && user_reponse[:value].include?(rid)) || (user_reponse[:value] == rid)
            # hreponses[rid].merge!(result: 'wrong')
            reponse_is_right = false
          end
        end
      end

      # debug "hreponses: #{hreponses.pretty_inspect}"

    end # / fin de si c'est une correction de questionnaire

    choix = thereps.collect do |hr|

      # Identifiant de cette réponse
      rid = hr[:id].freeze

      # L'ID de l'élément DOM de cette réponse
      cb_id   = "#{prefix}_q_#{id}_r_#{rid}".freeze

      # Le libellé de la réponse
      # Pourra être modifié si c'est une correction de questionnaire
      # et que c'est la bonne ou la meilleure réponse (cf. ci-dessous)
      libelle = hr[:libelle]

      # Si c'est une correction de questionnaire, il faut voir
      # quelle classe ajouter à la réponse
      class_css = nil
      if correction_questionnaire
        # debug "hreponses[#{rid}] = #{hreponses[rid].pretty_inspect}"
        class_css = hreponses[rid][:result] if hreponses[rid][:result]
        label_reponse = hreponses[rid][:label].nil_if_empty
        libelle += " (#{label_reponse})".in_span(class:'exg') if label_reponse
      end

      # Les différents affichages en fonction du type
      # de réponse (select, radio, etc.)
      # ATTENTION : Ils alimentent le collect donc la dernière ligne
      # de chaque condition doit retourner le string
      if type_a == "m" # En menu select
        libelle.in_option(value: "r_#{rid}", class: class_css)
      # En case à cocher (plusieurs choix)
      elsif type_c == "c"
        cb_name = "quiz[q_#{id}_r_#{rid}]".freeze
        libelle.in_checkbox(id:cb_id, name:cb_name).in_li(class: class_css)
      # EN bouton radio
      elsif type_c == "r"
        cb_name = "quiz[q_#{id}]".freeze
        libelle.in_radio(id:cb_id, name:cb_name, value: rid).in_li(class: class_css)
      end

    end.join # / fin de boucle sur toutes les réponses

    if type_a == "m"
      data_select = {name:"quiz[q_#{id}]", id:"#{prefix}_q_#{id}"}
      data_select.merge!(multiple: true) if type_c == "c"
      choix = choix.in_select( data_select ).in_li
    end

    # Class CSS de la question
    div_css = ['question']

    raison_bad = ""
    if correction_questionnaire
      div_css << (reponse_is_right ? 'good' : 'error')
      if raison
        raison_bad = "Raison de la bonne réponse : #{raison.strip.to_html}".in_div(class:'raison')
      end
    else
    end

    (
      infos_admin                       +
      question.in_div(class:'q')        +
      indications                       +
      choix.in_ul(class:"r #{type_a}")  +
      raison_bad
    ).in_div(class:div_css.join(' '), id:"question-#{id}")
  end

  def infos_admin
    ("##{id} "+lien_edit).in_div(class:'tiny fright adminonly')
  end

  def lien_edit
    return "" unless user.admin?
    "edit".in_a(href:"question/#{id}/edit?in=unan_admin/quiz", target:'_edit_question_quiz_')
  end

  def indications
    ind = String::new
    ind << indication unless indication.empty?
    ind << indication_when_checkboxes if type_c == "c"
    ind.in_div(class:'indication')
  end

  # Texte d'aide pour les questions qui ont des checkboxes au lieu
  # des radios groupes habituels.
  def indication_when_checkboxes
    @indication_when_checkboxes ||= <<-STR
    Cochez tous les choix qui vous semblent pertinents#{indication_ajout_when_select_multiple if type_a=='m'}.
    STR
  end
  def indication_ajout_when_select_multiple
    @indication_ajout_when_select_multiple ||= " (tenir la touche CMD sur Mac ou CTRL sur Unix/Windows pour plusieurs choix)"
  end
end #/Question
end #/Quiz
end #/Unan
