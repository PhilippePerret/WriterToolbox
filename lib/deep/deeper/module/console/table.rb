# encoding: UTF-8
class SiteHtml
class Admin
class Console

  # Sort dans la sortie spéciale, i.e. en dessous du champ de
  # console.
  # +table+ Instance {BdD::Table} de la table
  def show_table table
    data = table.select

    return "Cette table ne contient aucune valeur." if data.empty?

    # Format
    # ID handler titre path
    datacolumns = nil
    data.each do |rowid, rowdata|
      if datacolumns.nil?
        datacolumns = Hash::new
        rowdata.keys.each { |col| datacolumns.merge! col => { max_len: 0, name: col.to_s.freeze } }
      end
      rowdata.each do |col, valcol|

        if valcol.instance_of?(String)
          valcol = rowdata[col] = valcol.gsub(/<(.*?)>/,'').gsub(/[\r\t]/,'').gsub(/  +/,' ').gsub(/\n/,'[RC]')
        end

        if valcol.to_s.length > datacolumns[col][:max_len]
          datacolumns[col][:max_len] = valcol.to_s.length
        end
      end
    end

    # Lignes de titre + séparateur
    lentot = 0
    separateur = Array::new
    code = '| ' + datacolumns.collect do |col, datacol|
      max_len = [datacol[:max_len], datacol[:name].length].max
      datacol[:max_len] = max_len
      lentot += max_len + 3
      separateur << "-" * (max_len+2)
      datacol[:name].ljust(max_len)
    end.join(' | ') + ' |' + "\n"

    separateur = '|' + separateur.join('|') + '|' + "\n"
    code += separateur

    # Les données
    code += data.collect do |rowid, rowdata|

      '| ' + rowdata.collect do |col, value|
        value.to_s.ljust(datacolumns[col][:max_len])
      end.join(' | ') + " |\n"

    end.join("")

    # La ligne de fin
    code += separateur

    special_output '<pre style="font-size:13pt;">' + code + '</pre>'
    "Cf. le code ci-dessous"
  end

end #/Console
end #/Admin
end #/SiteHtml
