# encoding: UTF-8
raise_unless_admin
class SiteHtml
class Admin
class Console

  def init_unan
    site.require_objet 'unan'
  end

  def detruire_table_pages_cours
    if OFFLINE
      init_unan
      Unan::database.execute("DROP TABLE IF EXISTS 'pages_cours';")
      "Table des pages de cours détruite avec succès."
    else
      "Impossible de détruire la table des pages de cours en ONLINE (trop dangereux)."
    end
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

    special_output '<pre>' + code + '</pre>'
    "Cf. le code ci-dessous"
  end

end #/Console
end #/Admin
end #/SiteHtml
