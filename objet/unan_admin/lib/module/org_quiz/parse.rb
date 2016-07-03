# encoding: utf-8
class OrgQuiz

  # = main =
  #
  # Méthode principale qui parse le fichier emacs en org-mode
  # pour soit créer le questionnaire soit l'actualiser.
  #
  # C'est un parseur top-down.
  def parse
    
    lines.each do |line|
      line = line.nil_if_empty
      line.nil? || line = line.gsub(/# +/, '#+')
      next if line.nil? || line.start_with?('# ')

      if line.start_with?('#+')
        
        prop, value = line.match(/^#+([A-Z]+):(.*)$/).to_a
        value = value.nil_if_empty
        case line_type
        when :question
        # Une donnée pour la question (dernière)
          @qdata[:questions].last.merge!(prop.to_sym => value)
        else
          # Donnée générale
          @qdata.merge!(prop.to_sym => value)
        end

        # On change le type de la ligne courante
        line_type = :general_data
        
      elsif line.start_with?('* ')  # => Une question
        line_type = :question
        
        @qdata[:questions] << {id: nil, question: line, reponses: []}

      elsif line.start_with?('** ') # => une réponse
        line_type = :reponse
        
        @qdata[:questions].last[:reponses] << {reponse: line, points: nil}

      else
        # => Autre chose qu'une question ou qu'une réponse, c'est-à-dire
        #    soit un nombre de points pour une réponse soit une propriété
        #    de question. Fonction du dernier élément.
        case line_type
        when :general_data 
        # Normalement ça ne doit pas arriver
        when :question
          data_question = line.split(' ')
        when :reponse
          points_reponse = line.to_i
          @qdata[:questions].last[:reponses].last.merge!(points: points_reponse)
        else
          raise 'Je ne sais pas comment traiter la donnée.'
        end

        # On doit indiquer le type de la ligne à la fin ici
        # car c'est pour cette condition qu'on a besoin du
        # type de la ligne, a priori.
        line_type = :data
        
      end
    end
  end
end
