# encoding: UTF-8
=begin
Méthodes qui permettent de procéder au rapport
au site
=end
defined?(THIS_FOLDER) || THIS_FOLDER = File.expand_path('./CRON2') + '/'

class Connexions
class Connexion
class << self


  # {String} Le rapport final, au format HTML
  attr_reader :report

  # {Fixnum} Le début du rapport. Les connexions précédant
  # ce temps seront détruites après la production d'un rapport
  # valide.
  attr_reader :start_time

  # = main =
  #
  # Méthode principale procédant à la création du rapport
  # de connexion qui sera enregistré dans le fichier et
  # envoyé à l'administrateur.
  #
  def generate_report
    @start_time = Time.now.to_i # pour supprimer les connexions
    analyse
    build_report
    finalise_report
    save_resultats
    save_report
    if ONLINE
      # Si l'on se trouve en ONLINE, on envoie le rapport et
      # on détruit les connexions qui ont été analysées
      send_report
      remove_connexions
    end
  end

  # = main =
  #
  # Méthode principale de construction du rapport de connexions
  def build_report
    @report = String.new
    report_statistiques_generales
    report_statistiques_ensembles
    report_multi_connexions # connexions > 1, hors search engine
    report_statistiques_routes
  end

  # Finalisation du rapport, i.e. entête complet HTML
  def finalise_report
    @report = <<-HTML
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>RAPPORT CONNEXIONS - #{Time.now}</title>
    <style type="text/css">#{styles_css}</style>
  </head>
  <body>#{@report}</body>
</html>
    HTML
  end

  # Enregistre les résultats dans un fichier Marshal
  def save_resultats
    resultat_path.write Marshal.dump(resultats)
  end

  # Enregistre le rapport dans un fichier
  def save_report
    report_path.write report
  end

  # Envoi le rapport à l'administration
  #
  # Note : cette méthode n'est appelée qu'en ONLINE
  def send_report
    res = site.send_mail(
      to:           site.mail,
      from:         site.mail,
      subject:      'Rapport de connexions',
      message:      report,
      no_citation:  true,
      formated:     true
    )
    if res === true
        CRON2::Histo.add(code: '20101')
    else
      mess_err = ['# ERREUR EN TRANSMETTANT LE RAPPORT :']
      mess_err << res.message
      mess_err += res.backtrace
      mess_err = "    " + mess_err.join("\n    ")
    end
  end

  def remove_connexions
    table.delete(where: "time <= #{start_time}")
  end

  # Path du fichier du rapport de connexions
  def report_path
    @report_path ||= SuperFile.new(THIS_FOLDER + 'rapport_connexions.html')
  end

  def resultat_path
    @resultat_path ||= folder_resultats_marshal+"#{Time.now.strftime('%Y-%m-%d')}.msh"
  end
  def folder_resultats_marshal
    @folder_resultats_marshal ||= begin
      d = SuperFile.new(THIS_FOLDER + 'rapports_connexions')
      d.exist? || d.build
      d
    end
  end

  def styles_css
    if OFFLINE
      require 'sass'
      data_compilation = { line_comments: false, syntax: :sass, style: :compressed }
      return Sass.compile( styles_sass, data_compilation )
    else
      # COPIER-COLLER EN OFFLINE LE CODE TRADUIT
      <<-CSS
body{font-size:15.1pt;width:640px}.fright{float:right}.small{font-size:.82em}.italic{font-style:italic}.explication{font-size:.92em;font-style:italic;margin-bottom:2em;margin-left:2em;color:#777;width:420px}.duree{font-family:courier;font-size:.8em}fieldset{width:540px;margin:0 0 2em 0}div.dataline{min-width:600px}div.dataline.mleft{margin-left:2em}div.dataline span.libelle{display:inline-block;width:400px}div.dataline span.value{display:inline-block;width:200px}div.user_div span.ip_user,div.user_div span.nombre_routes_user,div.user_div span.duree_connexion{display:inline-block}div.user_div span.ip_user{font-weight:bold;width:200px}div.user_div span.nombre_routes_user{width:100px}div.user_div span.duree_connexion{width:180px}div.user_div ul.user_routes_list li.user_route{margin-left:4em;font-size:1em;width:420px;clear:both}div.user_div ul.user_routes_list li.user_route span.duree{float:right}ul#statistiques_route{width:420px}div.statistiques_ensemble div.data_ensemble{width:420px}div.statistiques_ensemble div.data_ensemble span.ensemble_name{font-weight:bold;display:inline-block;width:200px}div.statistiques_ensemble div.data_ensemble span.ensemble_nombre_routes{display:inline-block;width:120px}
      CSS
    end
  end
  def styles_sass
    <<-SASS
body
  font-size     : 15.1pt
  width         : 640px
.fright
  float         : right
.small
  font-size     : 0.82em
.italic
  font-style    : italic
.explication
  font-size     : 0.92em
  font-style    : italic
  margin-bottom : 2em
  margin-left   : 2em
  color         : #777
  width         : 420px
.duree
  font-family   : courier
  font-size     : 0.8em
fieldset
  width         : 540px
  margin        : 0 0 2em 0
div.dataline
  min-width     : 600px
  &.mleft
    margin-left   : 2em
  span.libelle
    display       : inline-block
    width         : 400px
  span.value
    display       : inline-block
    width         : 200px
div.user_div
  span.ip_user, span.nombre_routes_user, span.duree_connexion
    display           : inline-block
  span.ip_user
    font-weight       : bold
    width             : 200px
  span.nombre_routes_user
    width             : 100px
  span.duree_connexion
    width             : 180px

  ul.user_routes_list
    li.user_route
      margin-left     : 4em
      font-size       : 1em
      width           : 420px
      clear           : both
      span.duree
        float       : right
ul#statistiques_route
  width     : 420px

div.statistiques_ensemble
  div.data_ensemble
    width       : 420px
    span.ensemble_name
      font-weight     : bold
      display         : inline-block
      width           : 200px
    span.ensemble_nombre_routes
      display         : inline-block
      width           : 120px
    SASS
  end

end #/<< self
end #/Connexion
end #/Connexions
