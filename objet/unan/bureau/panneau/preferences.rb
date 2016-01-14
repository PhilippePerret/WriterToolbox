# encoding: UTF-8
class Unan
class Bureau

  def save_preferences
    flash "Je sauve les préférences"
  end

end #/Bureau
end #/Unan


case param(:operation)
when 'bureau_save_preferences'
  bureau.save_preferences
end
