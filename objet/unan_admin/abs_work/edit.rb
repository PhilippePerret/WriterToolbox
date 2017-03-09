# encoding: UTF-8
raise_unless_admin

site.require_objet 'unan'
site.require 'form_tools'
(site.folder_deeper_module + 'data_checker.rb').require

class UnanAdmin
class Program
class AbsWork

  # Pour le check des données
  include DataChecker

  class << self

    # Méthode qui complète le hash des données de l'abs-work en
    # ajoutant toutes les valeurs qui servent au formulaire mais
    # n'apparaissent pas en tant que données, comme la propriété `type`
    # qui permet de définir `narrative_target` (le sujet cible). Note :
    # type_w N'EST PLUS défini de cette façon, il possède sa propre
    # propriété.
    # @usage : data = UnanAdmin::Program::AbsWork::full_data_for( data )
    def full_data_for data

      return nil if data.nil?

      # Ajout des propriétés
      # typeP, narrative_target
      data[:type]           ||= ("0"*16).freeze
      data[:type_resultat]  ||= ("0"*16).freeze
      data.merge!(
        # Décomposition de `type`
        rien:             data[:type][0..1].to_i,
        narrative_target: data[:type][2..3],
        typeP:            data[:type][4].to_i,
        #  Décomposition de `type_resultat`
        support:          data[:type_resultat][0].to_i,
        destinataire:     data[:type_resultat][1].to_i,
        niveau_dev:       data[:type_resultat][2].to_i
      )
      data[:id] = data[:id].to_i_inn

      return data

    end

    # = main =
    #
    # Méthode appelée quand on clique sur le bouton-lien "Éditer"
    # à côté du champ pour entrer l'ID
    # Puisque form_tools se sert en priorité des paramètres pour
    # prendre les valeurs de l'objet (field_value) il faut vider
    # les paramètres de l'abs-work qui a peut-être été édité
    # avant pour ne mettre que l'id
    def edit_other
      wid = param(:work)[:id].to_i_inn
      param(:work => nil)
      if wid.nil?
        error "Il faut indiquer l'ID de l'abs-work à éditer"
      elsif Unan::table_absolute_works.count(where:"id = #{wid}") == 0
        error "L'abs-work d'ID ##{wid} n'existe pas."
      else
        form.objet = full_data_for( Unan::Program::AbsWork::new(wid).get_all )
      end
    end

    # = main =
    #
    # Destruction de l'abs-work (après confirmation).
    # Méthode appelée en bas de ce module lorsqu l'opération
    # est 'destroy_abs_work'
    def destroy
      wid = param(:work)[:id].to_i
      nombre = Unan::table_absolute_works.count(where:"id = #{wid}")
      if nombre == 0
        error "La donnée abs-work d'ID ##{wid} n'existe pas. Impossible de la détruire."
      else
        Unan::table_absolute_works.delete(wid)
        flash "Destruction de l'abs-work #{wid} OK"
      end
    end

    # = main =
    #
    # Sauvegarde de l'abswork. Méthode appelée en bas de ce
    # module lorsque l'opération est "save_abs_work"
    def save
      debug "-> AbsWork.save"
      # On vérifie la validité des données ou on s'en retourne
      check_data_abs_work || return

      save_data || return

      flash "Work ##{data[:id]} enregistré."
      debug "<- AbsWork.save"
    end

    def save_data
      debug "-> AbsWork.save_data"
      # debug data_to_save.pretty_inspect
      if data_to_save[:id]
        Unan::table_absolute_works.set(data_to_save[:id], data_to_save)
      else
        data[:id] = Unan::table_absolute_works.insert(data_to_save)
        param(:work => data)
      end
    rescue Exception => e
      debug e
      error e.message
    else
      return true
    end

    def data_to_save
      @data_to_save ||= begin
        dts = {
          titre:            data[:titre],
          type_w:           data[:type_w],
          duree:            data[:duree],
          type:             data_type,
          travail:          data[:travail],
          parent:           data[:parent],
          prev_work:        data[:prev_work],
          resultat:         data[:resultat],
          type_resultat:    type_resultat,
          item_id:          data[:item_id],
          exemples:         data[:exemples],
          pages_cours_ids:  data[:pages_cours_ids],
          points:           data[:points],
          updated_at:       NOW.to_i
        }
        if new_work?
          dts.merge!(created_at: NOW.to_i)
        else
          dts.merge!(id: data[:id].to_i_inn)
        end
        debug "\n\nDATA FINALES À SAUVER :\n#{dts.pretty_inspect}\n\n"
        debug "(On met ces data finales dans param(:work))"
        param(:work => dts)
        dts
      end
    end

    # Le type
    # Voir dans la définition de table
    # (./database/table_definition/db_unan/table_absolute_work) comment
    # est constituée cette donnée
    # Rappel : Les deux premiers "bits" étaient utilisés avant pour le
    # type de travail (type_w) mais maintenant ils ne servent plus
    def data_type
      "00#{data[:narrative_target]}#{data[:typeP].to_i.to_s}0"
    end

    # Le type_resultat est constitué de plusieurs valeurs
    # définies dans le formulaire
    # Les bits dans l'ordre sont :
    #   BIT 1   Le type de support
    #   BIT 2   Le destinataire
    #   BIT 3   Le niveau de développement
    # Note : on en profite pour le mettre aussi dans la donnée (objet)
    # et la donnée en paramètre (param(:<prefix>))
    def type_resultat
      "#{data[:support]}#{data[:destinataire]}#{data[:niveau_dev]}"
    end

    def new_work?
      @is_new_work ||= data[:id] == nil
    end

    # Pour DataChecker
    def definition_values
      {
        titre:        {hname:"titre",             type: :string,  defined:true},
        type_w:       {hname:"type travail",      type: :fixnum,  defined:true},
        duree:        {hname:"durée",             type: :fixnum,  defined:true, min: 1, max: 300},
        travail:      {hname:"travail",           type: :string,  defined:true},
        parent:       {hname:"travail-parent",    type: :fixnum},
        prev_work:    {hname:"previous travail",  type: :fixnum},
        resultat:     {hname:"résultat",          type: :string},
        item_id:      {hname:"ID de l'item",      type: :fixnum},
        points:       {hname:"points",            type: :fixnum, min:0, max:999}
      }
    end

    def check_data_abs_work
      retour = data.check_data( definition_values )
      retour.ok || begin
        raise( retour.errors.collect do |prop, derr|
          derr[:err_message].in_div
        end.join)
      end
      data = retour.objet

      # Si le parent est défini, il doit exister
      if data[:parent] != nil
        Unan::Program::AbsWork::exist?( data[:parent] ) || raise("Le travail-parent ##{data[:parent]} doit absolument exister.")
      end

      # Si l'item_id est défini, et qu'il concerne une page
      # de cours à lire/relire, il doit être unique
      item_id_defined   = data[:item_id] != nil
      data_typew = Unan::Program::AbsWork::TYPES[data[:type_w]]
      est_page_de_cours =
        if data_typew.nil?
          false
        else
          data_typew[:id_list] == :pages
        end

      if item_id_defined && est_page_de_cours
        request = {
          where: "item_id IS NOT NULL",
          colonnes:[:item_id]
        }
        Unan.table_absolute_works.select(request).each do |hw|
          hw[:item_id] == data[:item_id] || next
          # Si c'est le même travail que celui qu'on est en train
          # de traiter, on s'en retourne
          hw[:id].to_i == data[:id].to_i && next
          # Si on passe ici, c'est qu'un item_id identique a été trouvé
          # TODO Pour le lien ci-dessous, ça pourra poser des problèmes
          # lorsque item_id sera utilisé pour autre chose que des pages
          # de cours.
          linked_item = "##{data[:item_id]}".in_a(href: "page_cours/#{data[:item_id]}/edit?in=unan_admin", target: :new)
          linked_work = "##{hw[:id]}".in_a(href:"abs_work/#{hw[:id]}/edit?in=unan_admin", target: :new)
          raise "Problème avec le travail ##{data[:id]} : l'item_id ##{linked_item} est déjà employé par le travail #{linked_work}. Il ne peut pas être employé pour celui-ci."
        end
      end
    rescue Exception => e
      error e.message
      debug e.message
      debug e.backtrace.join("\n")
      return false
    else
      return true # pour poursuivre
    end

    def data
      @data ||= begin
        d = param(:work)
        # Quelques corrections
        if d[:points].empty?
          d[:points] = 0 # correspond à : prendre valeur par exemple du quiz
        end
        d
      end
    end

  end # << self

end #/AbsWork
end #/Program
end #/UnanAdmin

case param(:operation)
when "edit_abs_work"
  UnanAdmin::Program::AbsWork::edit_other
when "save_abs_work"
  UnanAdmin::Program::AbsWork::save
when "destroy_abs_work"
  UnanAdmin::Program::AbsWork::destroy
end
