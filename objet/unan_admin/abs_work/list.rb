# encoding: UTF-8
raise_unless_admin

UnanAdmin::require_module 'abs_work'

class Unan
class Program
class AbsWork
  class << self

    def list
      data_request = Hash::new
      data_request.merge!(colonnes: [])
      data_request.merge!(where: where_clause) unless where_clause.nil?
      Unan::table_absolute_works.select(data_request).keys.collect do |wid|
        get(wid)
      end
    end

    def where_clause
      @where_clause ||= begin
        where_clause = Array::new
        if filter.has_key?(:titre_contents)
          where_clause << "titre LIKE '%#{filter[:titre_contents]}%'"
        end
        if filter.has_key?(:travail_contents)
          where_clause << "travail LIKE '%#{filter[:travail_contents]}%'"
        end
        if filter[:type_w].to_i != 0
          where_clause << "type_w == #{filter[:type_w]}"
        end
        if filter[:narrative_target] != "0-"
          where_clause << "type LIKE '__#{filter[:narrative_target]}%'"
        end

        unless where_clause.empty?
          where_clause = where_clause.join(' AND ')
          where_clause += " COLLATE NOCASE" if true # filter[:nocase] == 'on'
        else
          nil
        end
      end
    end

    # Le filtre
    # Seulement défini si on utilise le filtre de la page list
    def filter
      @filter ||= begin
        param(:abs_work_filter) || Hash::new
      end
    end
  end # << self

  def as_li
    ("[##{id}] #{titre}").in_li
  end
end #/AbsWork
end #/Program
end #/Unan
