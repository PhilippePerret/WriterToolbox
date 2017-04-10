# encoding: UTF-8

class UnanAdmin
class << self

  # Première ligne du listing avec les libellés
  def first_line_listing
    (
      'Pseudo'.in_span(class: 'pseudo') +
      'PDay'.in_span(class: 'cpday') +
      'Pauses'.in_span(class: 'pausedur')
    ).in_li(class: 'program libelles')
  end

  # Retourne la liste des programmes courant
  def programmes_en_cours &block
    if block_given?
      get_programmes("options LIKE '10%'").collect do |hprog|
        yield Unan::Program.new(hprog[:id])
      end.join
    else
      get_programmes("options LIKE '10%'")
    end
  end

  def programmes_en_pause &block
    if block_given?
      get_programmes("options LIKE '01%'").collect do |hprog|
        yield Unan::Program.new(hprog[:id])
      end.join
    else
      get_programmes("options LIKE '01%'")
    end
  end

  def get_programmes where
    Unan.table_programs.select(where: where, columns: [])
  end


end #/<< self
end #/UnanAdmin
