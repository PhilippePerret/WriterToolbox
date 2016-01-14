# encoding: UTF-8
class Unan
class Bureau
  
  def save_projet
    flash "Je sauve les données projet"
  end

end #/Bureau
end #/Unan

case param(:operation)
when 'bureau_save_projet'
  bureau.save_projet
end
