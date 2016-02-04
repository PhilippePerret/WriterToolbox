# encoding: UTF-8
class Unan
class Program
class Exemple


  # ---------------------------------------------------------------------
  #   Data enregistrées
  # ---------------------------------------------------------------------

  def titre       ; @titre        ||= get(:titre)       end
  def content     ; @content      ||= get(:content)     end
  def source      ; @source       ||= get(:source)      end
  def source_type ; @source_type  ||= get(:source_type) end
  def work_id     ; @work_id      ||= get(:work_id)     end

  # ---------------------------------------------------------------------
  #   Data volatiles
  # ---------------------------------------------------------------------

  def source_src
    @source_src ||= source_type[0].to_i
  end
  def source_year
    @source_year ||= source_type[1..4].to_i
  end
  def source_pays
    @source_pays ||= source_type[5..6]
  end

end #/Exemple
end #/Program
end #/Unan
