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
    #
    def save_data
      # debug "data2save : #{data2save.inspect}"
      if exist?
        table_quiz.update(id, data2save)
        flash "Quiz ##{id} actualisé avec succès."
      else
        @id = table_quiz.insert(data2save.merge(created_at: NOW))
        flash "Quiz ##{id} créé avec succès."
      end
      # Si le quiz doit être mis en QUIZ COURANT, il faut modifier les
      # options du quiz courant actuel s'il existe.
      # Noter qu'il faut écarter le quiz courant, qui vient d'être mis
      # en courant.
      if @must_be_quiz_courant
        dcurrent = self.class.get_quiz_courant(but: id)
        if dcurrent.nil?
          # Rien a à faire, il n'y a pas de quiz courant
        else
          # Le quiz courant ne doit plus l'être
          opts = dcurrent.options
          opts[0] = '0'
          dcurrent.set(options: opts)
          debug "Quiz courant précédent (#{dcurrent.id}) décourantisé."
        end
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
      h = traite_current h
      bit_random  = h.delete(:random) == 'on' ? '1' : '0'
      # Le nombre maximum de questions par formulaire, sur 3 chiffres
      bits_maxq  = (h.delete(:max_questions).nil_if_empty || '0').rjust(3,'-')

      # Constition des options
      @options = "#{@bit_courant}#{bit_random}#{bits_maxq}"
      h.merge!(options: @options)
      return h # pour la clarté
    end

    def traite_current h
      @bit_courant = h.delete(:quiz_courant) == 'on' ? '1' : '0'
      if exist?
        # Le quiz courant doit être modifié, mais seulement
        # si ce quiz édité n'est pas le quiz courant
        @must_be_quiz_courant = ! current?
      else
        # Si ce quiz n'existe pas encore (création) alors
        # il faut obligatoirement modifier le quiz courant
        # si ce nouveau quiz doit être mis en courant
        @must_be_quiz_courant = @bit_courant == '1'
      end
      return h
    end

  end
end
