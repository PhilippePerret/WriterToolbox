# encoding: UTF-8
raise_unless_admin
class SiteHtml
class Admin
class Console

  def init_unan
    site.require_objet 'unan'
  end

  def afficher_table_pages_cours
    init_unan

    data = Unan::Program::PageCours::table_pages_cours.select

    if data.empty?
      return "Cette table ne contient aucune valeur."
    end

    data.inspect

    # Format
    # ID handler titre path
    datacolumns = nil
    data.each do |rowid, rowdata|
      if datacolumns.nil?
        datacolumns = Hash::new
        rowdata.keys.each { |col| datacolumns.merge! col => {max_len: 0, name: col.to_s.freeze}}
      end

      rowdata.each do |col, valcol|
        if valcol.length > datacolumns[col][:max_len]
          datacolumns[col][:max_len] = valcol.length
        end
      end
    end

    lentot = 0
    code = datacolumns.collect do |col, datacol|
      lentot += datacol[:max_len] + 2
      datacol[:name].rjust(datacol[:max_len])
    end.join(' ')
    code += "\n" + ("-" * lentot)

  end

end #/Console
end #/Admin
end #/SiteHtml
