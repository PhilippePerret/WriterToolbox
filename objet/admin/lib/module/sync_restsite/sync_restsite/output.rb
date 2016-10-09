# encoding: UTF-8
class SyncRestsite
class << self

  # Pour procéder à la synchro
  def output_form_synchronisation
    (@data_synchronisation.nil? || @data_synchronisation.empty?) && (return '')
    'Synchronisations requises'.in_h3 +
    (
      @data_synchronisation.collect do |from_path, isync|
        isync.div_form
      end.join +
      'Synchroniser les cochées'.in_submit(class: 'btn').in_div(class: 'buttons')
    ).in_form(form: 'form_synchronisation')
  end
  # Pour le suivi des opération
  def output
    @report != nil || (return '')
    'Résultat de l’opération'.in_h3 +
    @report.join("\n").in_pre(class: 'small wrap')
  end
end #<< self
end # SyncRestsite
