# encoding: UTF-8
class SyncRestsite
class << self

  # Pour procéder à la synchro
  def output_form_synchronisation

    (@data_synchronisation.nil? || @data_synchronisation.empty?) && (return '')

    # debug "@data_synchronisation = #{@data_synchronisation.pretty_inspect}"
    # On construit trois parties : une pour les fichiers out-of-date, une
    # pour les fichiers :unknown de la destination et une pour les fichiers
    # unknown de la source
    listes = {
      :outofdate    => Array.new,
      :unknown_src  => Array.new,
      :unknown_dst  => Array.new
    }
    @data_synchronisation.each do |from_path, isync|
      div = isync.div_form
      case isync.raison
      when :outofdate then listes[:outofdate] << div
      when :unknown
        case isync.sens
        when :normal    then listes[:unknown_dst] << div
        when :inverse   then listes[:unknown_src] << div
        end
      end

    end

    'Synchronisations requises'.in_h3 +
    (
      'Désynchronisés'.in_h4 +
      listes[:outofdate].join.in_div +
      "Inexistants sur #{app_destination.name}".in_h4 +
      listes[:unknown_dst].join.in_div +
      "Inexistants sur la source #{app_source.name}".in_h4 +
      listes[:unknown_src].join.in_div +
      'Synchroniser les cochées'.in_submit(class: 'btn').in_div(class: 'buttons')
    ).in_form(id: 'form_synchronisation', action: 'admin/sync_restsite')
  end
  # Pour le suivi des opération
  def output
    @report != nil || (return '')
    'Résultat de l’opération'.in_h3 +
    @report.join("\n").force_encoding('utf-8').in_pre(class: 'small wrap')
  end
end #<< self
end # SyncRestsite
