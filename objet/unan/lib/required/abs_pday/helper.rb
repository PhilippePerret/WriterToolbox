# encoding: UTF-8
class Unan
class Program
class AbsPDay

  def lien_show atitre = nil, options = nil
    atitre ||= "Visualiser le jour-programme #{id}"
    options ||= Hash::new
    options.merge!(href:"abs_pday/#{id}/show?in=unan")
    atitre.in_a(options)
  end

end #/AbsPDay
end #/Program
end #/Unan
