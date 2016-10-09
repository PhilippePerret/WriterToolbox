# encoding: UTF-8
class SyncRestsite
class Sync

  def div_form
    (
      checkbox_with_rel_path      +
      human_sens  +
      boutons
    ).in_div(class: 'divsync')
  end

  def checkbox_with_rel_path
    span_relpath.in_checkbox(name: "sync[#{id}]", checked: true)
  end
  def span_relpath
    "./#{rel_path}".in_span(class: 'relp')
  end

  def boutons
    raison == :outofdate || (return '')
    (
      'diff'.in_a(href:"admin/#{id}/sync_restsite?app_source=#{app_source.id}&app_destination=#{app_destination.id}&operation=diff_files", target: :new)
    ).in_div(class: 'boutons')

  end
  def human_sens
    case sens
    when :normal  then "source vers destinat°"
    when :inverse then "destinat° vers source"
    end
  end

  def human_raison
    case raison
    when :outofdate then 'out of date'
    when :unknown   then 'inexistant'
    else 'raison inconnue'
    end
  end
end #/Sync
end #/SyncRestsite
