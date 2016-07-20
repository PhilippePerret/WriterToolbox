# encoding: UTF-8
=begin

  Module de méthodes qui permettent de définir le questionnaire

  Ce module est réservé à un administrateur de niveau supérieur.

=end
if user.manitou?
  class ::Quiz
    # Méthode principale appelée quand on soumet le formulaire des
    # données du quiz
    #
    # On n'empêche jamais d'enregistrer la donnée, mais on fait
    # quelques alertes pour prévenir quand même l'administrateur
    # qui procède à la création.
    def save_data
      debug "data2save : #{data2save.inspect}"
      if exist?
        debug "-> Update du quiz #{id}"
        table_quiz.update(id, data2save)
        flash "Quiz ##{id} actualisé avec succès."
      else
        debug "-> Création du quiz"
        @id = table_quiz.insert(data2save.merge(created_at: NOW))
        flash "Quiz #{id} créé avec succès."
      end
    end

    # Les données à sauvegarder dans la base
    def data2save
      @data2save ||= begin
        h = {}.merge(fdata)
        h.delete(:id)
        h = assemble_options_in(h)
        h[:description] = h[:description].nil_if_empty
        h.merge!(updated_at: NOW)
      end
    end
    # Les données fournies dans le formulaire
    def fdata
      @fdata ||= param(:quiz)
    end

    # Dans les données de formulaire, les options sont dispatchées
    # dans différentes valeurs. Au moment de l'enregistrement des
    # données, on reconstitue ces options et on les retirer du
    # h qui contient les données qui seront enregistrées dans la
    # table quiz
    def assemble_options_in h
      bit_random = h.delete(:random) || '0'
      # Le nombre maximum de questions par formulaire, sur 3 chiffres
      bits_maxq  = (h.delete(:max_questions).nil_if_empty || '0').rjust(3,'0')
      @options = "#{bit_random}#{bits_maxq}"
      h.merge!(options: @options)
      # Pour que ce soit clair qu'il faut le retourner
      return h
    end

  end
end
