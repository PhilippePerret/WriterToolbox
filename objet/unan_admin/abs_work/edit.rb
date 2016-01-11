# encoding: UTF-8
raise_unless_admin

site.require_objet 'unan'
(site.folder_deeper_module + 'data_checker.rb').require

class UnanAdmin
class Program
class AbsWork

  # Pour le check des données
  include DataChecker

  class << self

    def save

      # On vérifie la validité des données ou on s'en retourne
      check_data_abs_work || return

      save_data || return

      flash "Work ##{data[:id]} enregistré."
    end

    def save_data
      debug data_to_save.pretty_inspect
      if data_to_save[:id]
        Unan::table_absolute_works.set(data_to_save)
      else
        data[:id] = Unan::table_absolute_works.insert(data_to_save)
        param(:work => data)
      end
    rescue Exception => e
      error e.message
    else
      return true
    end

    def data_to_save
      @data_to_save ||= begin
        dts = {
          titre:            data[:titre],
          pday_start:       data[:pday_start],
          duree:            data[:duree],
          type:             data_type,
          travail:          data[:travail],
          prev_work:        data[:prev_work],
          resultat:         data[:resultat],
          type_resultat:    type_resultat,
          pages_cours:      data[:pages_cours],
          pages_optionnelles:  data[:pages_optionnelles],
          questionnaires:   data[:questionnaires],
          exemples:         data[:exemples],
          flying_qcms:      data[:flying_qcms],
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
    def data_type
      "0#{data[:typeW].to_s}#{data[:narrative_target]}#{data[:typeP].to_i.to_s}0"
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
        titre:        {hname:"titre",         type: :string, defined:true},
        pday_start:   {hname:"jour-départ",   type: :fixnum, defined:true, min: 1, max: 365},
        duree:        {hname:"durée",         type: :fixnum, defined:true, min: 1, max: 300},
        travail:      {hname:"travail",       type: :string, defined:true},
        prev_work:    {hname:"travail précédent", type: :fixnum},
        resultat:     {hname:"résultat",      type: :string},
        points:       {hname:"points",        type: :fixnum, defined:true, min:1, max:5000}
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

      # Les pages de cours doivent être définies si le typew est 3
      if data[:typeW] == "3"
        raise "Il faut indiquer les IDs ou HANDLERS des pages de cours à lire." if data[:pages_cours].nil?
      end
      # Les questionnaires doivent être définis si le typew est 4 ou 5
      if ["4","5"].include?(data[:typeW])
        raise "Il faut indiquer les IDs de questionnaires ou de checkpoints à accomplir." if data[:questionnaires].nil?
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
      @data ||= param(:work)
    end

  end # << self

end #/AbsWork
end #/Program
end #/UnanAdmin

UnanAdmin::Program::AbsWork::save if param(:operation) == "save_abs_work"
