# encoding: UTF-8
raise_unless_admin
class Scenodico
  class << self

    def save_mot
      new_mot = Scenodico::Mot::new
      new_mot.save
    end

    # Prend l'instance du mot +imot+ et retourne
    # un Hash pour son édition (où, par exemple, les listes des
    # relatifs sont transformées en liste string séparées par des
    # espaces, etc.). OBSOLÈTE : Normalement, maintenant, toutes les
    # listes sont enregistrées en string simple.
    def prepare_pour_champs imot
      hmot = imot.get_all
      [:relatifs, :contraires, :synonymes, :categories].each do |key|
        hmot[key].nil? || hmot[key] = hmot.delete(key).join(' ')
      end
      return hmot
    end

    # Méthode invoquée quand on clique le bouton "Edit" pour
    # éditer le mot dont l'identifiant est fourni.
    def edit_mot_by_id
      mot_id = param(:mot)[:id].nil_if_empty.to_i_inn
      if mot_id.nil?
        error "Il faut donner l'ID du mot à voir !"
      else
        hmot = ( prepare_pour_champs Scenodico::get(mot_id) )
        param( :mot => hmot )
      end
    end

  end #/ << self

  class Mot
    # ---------------------------------------------------------------------
    #   Classe
    # ---------------------------------------------------------------------
    class << self

      # Return true si le mot +mot+ existe.
      def mot_existe? mot
        Scenodico::table_mots.count(where:"mot = \"#{mot}\"") > 0
      end

    end # << self
    # ---------------------------------------------------------------------
    #   Instance
    # ---------------------------------------------------------------------

    # = main =
    #
    def save
      @id = data_param[:id].nil_if_empty.to_i_inn
      @is_new_mot = ( nil == @id )
      check_data_to_save_or_raise || return
      if new?
        debug "Création du mot : #{data2save.pretty_inspect}"
        @id = Scenodico::table_mots.insert( data2save )
        flash "Nouveau mot ##{@id} créé avec succès."
        param(:mot => data_param.merge(id: @id, id_interdata: @id_interdata))
      else
        Scenodico::table_mots.update( id, data2save )
        flash "Mot ##{id} updaté."
      end
    end

    def data2save
      @data2save ||= {
        mot:            @mot,
        type_def:       @type_def.to_i,
        definition:     @definition,
        relatifs:       (@relatifs || '').join(' '),
        synonymes:      (@synonymes || '').join(' '),
        contraires:     (@contraires || '').join(' '),
        categories:     (@categories || '').join(' '),
        liens:          @liens
      }
    end

    def new? ; @is_new_mot end

    def data_param
      @data_param ||= param(:mot)
    end

    def check_data_to_save_or_raise

      #  - Mot -
      @mot = data_param[:mot].nil_if_empty
      @mot != nil || raise('Il faut donner le mot à enregistrer !')
      if new?
        raise "Ce mot existe déjà !" if self.class::mot_existe?(@mot)
      end

      # - Type de définition -
      @type_def = data_param[:type_def].to_i # toujours

      # - Définition -
      @definition = data_param[:definition].purified.nil_if_empty
      @definition != nil || raise('Il faut donner la définition du mot !')

      # - Relatifs -
      [:relatifs, :synonymes, :contraires].each do |key|
        val_str = data_param[key].strip
        instance_variable_set("@#{key}", val_str.split(' '))
      end

      # - categories
      @categories = data_param[:categories].nil_if_empty
      @categories = @categories.split(' ') unless @categories.nil?

      # - liens -
      @liens = data_param[:liens].nil_if_empty
      @liens = @liens.split("\n") unless @liens.nil?

    rescue Exception => e
      debug e
      error e.message
    else
      true
    end

  end #/ Mot

end #/ Scenodico

case param(:operation)
when 'save_mot'
  Scenodico::save_mot
when 'edit_mot_by_id'
  Scenodico::edit_mot_by_id
end
