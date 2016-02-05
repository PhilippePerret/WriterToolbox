# encoding: UTF-8
class Unan
class Program
class AbsWork

  # Pour l'affichage du work sous forme de carte. Pour le moment,
  # ne sert que pour l'affichage du p-day par show.erb
  def as_card params = nil
    (
      (
        human_type_w.in_span(class:'type') +
        titre.in_span(class:'titre')
      ).in_div(class:'div_titre') +
      travail.in_div(class:'travail')

    ).in_div(class:'work')
  end

end #/AbsWork
end #/Program
end #/Unan
