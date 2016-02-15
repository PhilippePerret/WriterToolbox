# encoding: UTF-8
class Scenodico
class Mot

  def mot         ; @mot        ||= get(:mot)         end
  def definition  ; @definition ||= get(:definition)  end
  def synonymes   ; @synonymes  ||= get(:synonymes)   end
  def contraires  ; @contraires ||= get(:contraires)  end
  def relatifs    ; @relatifs   ||= get(:relatifs)    end
  def categories  ; @categories ||= get(:categories)  end
  def liens       ; @liens      ||= get(:liens)       end



  def table ; @table ||= Scenodico::table_mots end
end #/Mot
end #/Scenodico
