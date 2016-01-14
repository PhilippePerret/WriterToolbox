# encoding: UTF-8
class Unan
class Bureau

  def save_travail
    flash "Je sauve les données travail"
  end

end # /Bureau
end # /Unan

case param :operation
when 'bureau_save_travail'
  bureau.save_travail
end
