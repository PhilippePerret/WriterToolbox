# encoding: UTF-8
raise_unless_admin

site.require_objet 'unan'

class UnanAdmin
class Program
class AbsWork
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
          type:             "#{data[:typeW].to_s.rjust(2,'0')}#{data[:narrative_target]}",
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
          updated_at: NOW.to_i
        }
        if new_work?
          dts.merge!(created_at: NOW.to_i)
        else
          dts.merge!(id: data[:id])
        end
      end
    end

    # Le type_resultat est constitué de plusieurs valeurs
    # définies dans le formulaire
    # Les bits dans l'ordre sont :
    #   BIT 1   Le type de support
    #   BIT 2   Le destinataire
    #   BIT 3   Le niveau de développement
    def type_resultat
      @type_resultat ||= begin
        "#{data[:support]}#{data[:destinataire]}#{data[:niveau_dev]}"
      end
    end

    def new_work?
      @is_new_work ||= data[:id] == nil
    end

    def check_data_abs_work
      [:id, :titre, :pday_start, :duree, :travail, :prev_work, :resultat, :pages_cours, :pages_optionnelles, :questionnaires, :exemples, :flying_qcms, :points].each do |key|
        data[key] = data[key].nil_if_empty
      end

      # Les valeurs liste exprimées en string séparés par des espaces
      # Mais on ne les traite plus, on les enregistre telles quelles, elles
      # seront traitées seulement au moment voulu
      [:pages_cours, :pages_optionnelles, :questionnaires, :exemples, :flying_qcms].each do |key|
        data[key] = data[key].split(' ') unless data[key].nil?
      end

      hcond = {
        titre:        {hname:"Le titre",        type: :string, defined:true},
        pday_start:   {hname:"Le jour-départ",  type: :fixnum, defined:true, min: 1, max: 365},
        duree:        {hname:"La durée",        type: :fixnum, defined:true, min: 1, max: 300},
        travail:      {hname:"Le travail",      type: :string, defined:true},
        prev_work:    {hname:"Le travail précédent", type: :fixnum},
        resultat:     {hname:"Le résultat",     type: :string},
        points:       {hname:"Les points",      type: :fixnum, defined:true, min:1, max:5000}
      }
      hcond.each do |key, dcheck|
        designation = dcheck[:hname] || "La propriété #{key.inspect}"
        checked = data[key]
        checked = checked.to_i_inn if dcheck[:type] == :fixnum
        raise "La valeur de #{designation.downcase} devrait être définie." if dcheck[:defined] && checked.nil?
        if dcheck[:type] == :fixnum
          raise "#{designation} devrait être supérieur à #{dcheck[:min]}." if dcheck[:min] && checked < dcheck[:min]
          raise "#{designation} devrait être inférieur à #{dcheck[:max]}." if dcheck[:max] && checked > dcheck[:max]
        end
        data[key] = checked
      end

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
