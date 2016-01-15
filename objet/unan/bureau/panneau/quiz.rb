# encoding: UTF-8
class Unan
class Bureau

  def save_quiz
    flash "Je sauve les questionnaires"
  end

  def missing_data
    @missing_data ||= begin
      nil # pour le moment
    end
  end
  
end #/Bureau
end #/Unan

case param(:operation)
when 'bureau_save_quiz'
  bureau.save_quiz
end
