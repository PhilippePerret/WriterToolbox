# encoding: UTF-8
class Scenodico
class Mot

  def mot         ; @mot        ||= get(:mot)             end
  def definition  ; @definition ||= get(:definition)      end
  def liens       ; @liens      ||= get(:liens)           end
  def synonymes   ; @synonymes  ||= dejoint(:synonymes)   end
  def contraires  ; @contraires ||= dejoint(:contraires)  end
  def relatifs    ; @relatifs   ||= dejoint(:relatifs)    end
  def categories  ; @categories ||= dejoint(:categories)  end

  def dejoint key
    (get(key) || "").split(' ')
  end
  def get_all
    res = super
    [:synonymes, :contraires, :relatifs, :categories].each do |k|
      v = instance_variable_get("@#{k}")
      unless v.nil?
        v = v.split(' ')
        instance_variable_set("@#{k}", v)
        res[k] = v
      end
    end
    res
  end

  def table ; @table ||= Scenodico.table_mots end
end #/Mot
end #/Scenodico
