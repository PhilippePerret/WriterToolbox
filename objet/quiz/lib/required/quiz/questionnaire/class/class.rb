# encoding: UTF-8
class Quiz

  # Les méthodes principales de n'importe quel objet RestSite
  extend MethodesMainObjets

  class << self

    # Retourne l'instance du questionnaire courant
    #
    # Rappel : le questionnaire courant est le questionnaire
    # qui a '1' en premier bit d'options.
    #
    # Si la base n'est pas définie (par suffix_base, avec dqbr en
    # paramètre) alors on cherche le premier quiz courant dans toutes
    # les bases.
    #
    def current
      @current ||= begin
        q =
          if suffix_base.nil?
            # S'il n'y a pas de suffixe de base défini, on prend le
            # quiz courant (qui, ici, peut être nil)
            @minor_error = 'Suffixe de base non fourni'
            nil
          elsif !database_exist?
            # Si le prefix fourni ne correspond à aucune base
            # Noter que dans ce cas-là, il n'y a pas d'erreur mineure, elle
            # doit être signalée.
            @error = 'Base de données inexistante avec le suffixe fourni'
            nil
          elsif site.current_route.objet_id.nil?
            # Si l'Identifiant n'est pas fourni, on ne produit pas d'erreur
            # mais on prend le quiz courant
            @minor_error = 'Aucun identifiant n’est fourni'
            nil
          elsif get_wanted_quiz.nil?
            # Le quiz demandé n'exite pas (à cause d'un mauvais identifiant
            # ou d'une base qui ne contient aucun quiz). Dans tous les cas
            # on produit une vraie erreur signalé.
            @error = 'Le quiz demandé n’existe pas. Quiz courant proposé.'
            nil
          elsif wanted_quiz_not_authorised?
            # Si le quiz demandé ne peut pas être consulté par l'user
            # courant, on lui signale par une erreur (c'est un cas tout de
            # même normal, lorsqu'on vient de la liste des quiz par exemple)
            # Note : L'erreur @error est définie par la méthode
            # `wanted_quiz_not_authorised?`
            nil
          else
            get_wanted_quiz
          end

        # S'il y a une erreur majeure, il faut l'afficher
        @error.nil? || ( error @error )

        if q.nil?
          # Dans le cas où le quiz voulu n'est pas défini, on prend le
          # quiz courant. Si le quiz courant n'existe pas, on prend le
          # dernier quiz créé qu'on met en quiz courant.
          get_current_quiz(forcer = true)
        else
          q
        end
      end
      @current != nil || raise('LE QUIZ COURANT NE DEVRAIT JAMAIS POUVOIR ÊTRE NUL')
      @current.instance_of?(Quiz) || raise('LE QUIZ COURANT DEVRAIT ÊTRE UN INSTANCE QUIZ…')
      @current
    end

    def table_quiz
      @table_quiz ||= site.dbm_table("quiz_#{suffix_base}", 'quiz')
    end

    def database_exist?
      SiteHtml::DBM_TABLE.database_exist?("boite-a-outils_quiz_#{suffix_base}")
    end

    # Retourne TRUE si le quiz désiré (défini par l'URL) N'est PAS
    # autorisé pour l'user courant.
    def wanted_quiz_not_authorised?
      if get_wanted_quiz.current?
        debug "Le quiz demandé est courant (-> false)"
        return false
      end
      if user.authorized?
        debug "L'auteur est autorisé (-> false)"
        return false
      end
      debug "Visiteur non autorisé à voir le quiz #{get_wanted_quiz.id}/#{get_wanted_quiz.suffix_base}"
      @error = 'Seuls les abonnés peuvent exécuter le questionnaire demandé.'
      flash 'Questionnaire courant affiché.'
      return true
    end

    # Suffix du nom de la base courant
    # {String ou Nil}
    #
    # IL est contenu dans la variable qdbr (qui signifie "q" pour "quiz",
    # "db" pour "database" et "r" pour relname, le nom relatif, sans 'quiz'
    # et sans la racine des bases de données — 'boite-a-outils' pour le BOA)
    #
    # Il peut être défini explicitement par les test avec
    # Quiz.suffix_base=
    def suffix_base
      @suffix_base ||= param(:qdbr).nil_if_empty
    end
    def suffix_base= value; @suffix_base = value end

    # Le quiz demandé par l'url, en fonction du suffixe de
    # base et de l'identifiant
    #
    def get_wanted_quiz
      @get_wanted_quiz ||= begin
        hquiz = table_quiz.get(site.current_route.objet_id)
        hquiz ? Quiz.new(hquiz[:id], suffix_base) : nil
      end
    end

    # Le quiz courant, s'il est défini
    #
    # Le quiz courant se reconnait au fait que son premier bit
    # d'option est à 1
    #
    # +forcer+ Si true, et que le quiz courant n'existe pas, on
    # met en quiz courant le dernier quiz créé (non hors-liste)
    # et on prévient l'administration qu'on a dû faire ça (ce qui
    # ne devrait pas arriver)
    #
    def get_current_quiz forcer = false
      allquiz.each do |iquiz|
        return iquiz if iquiz.current?
      end
      # Si on passe ici, c'est que le quiz courant n'a pas été trouvé
      forcer || (return nil)
      q = get_last_quiz
      opts = q.options.set_bit(0,1)
      q.set( options: opts )
      q.instance_variable_set('@options', opts)
      debug "Options de “#{q.titre}” mis à #{opts}"
      site.send_mail_to_admin(
        subject:  'Quiz : forçage du quiz courant',
        formated: true,
        message: <<-HTML
        <p>Phil</p>
        <p>J'ai dû définir de force le quiz courant, qui n'était pas défini.</p>
        <p>Quiz mis en quiz courant : ##{q.id} dans #{q.suffix_base} (#{q.titre})</p>
        HTML
      )
      return q
    end

    # Le tout dernier quiz créé
    def get_last_quiz
      allquiz.sort_by{|q|q.created_at}.last
    end

  end #/<<self
end #/Quiz
