# encoding: UTF-8
class SyncRestsite
class Sync

  # ID pour retrouver les informations dans le formulaire ou
  # dans le fichier marshal
  def id

  end

  def div_form
    (
      checkbox_with_rel_path      +
      # span_relpath  +
      "#{human_sens} (#{human_raison})"
    ).in_div(class: 'divsync')
  end

  def checkbox_with_rel_path
    span_relpath.in_checkbox(name: "sync_#{id}")
  end
  def span_relpath
    "./#{rel_path}".in_span(class: 'relp')
  end
  def human_sens
    case sens
    when :normal  then "source vers destinat°"
    when :inverse then "destinat° vers source"
    end
  end
end #/Sync
end #/SyncRestsite
