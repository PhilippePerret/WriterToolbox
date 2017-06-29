#!/usr/bin/env ruby
# encoding: UTF-8
# Pour le benchmarking, on inscrit le temps courant dans un
# fichier
def w texte
  STDOUT.write "<p>#{texte}</p>"
end
begin
  STDOUT.write "Content-type: text/html; charset: utf-8;\n\n"
  STDOUT.write '<html>'
  STDOUT.write '<head><meta charset="utf-8">'
  STDOUT.write '</head>'
  STDOUT.write '<body>'
  w "Nouvelle version."
  begin
    # ENV.each do |k,v|
    #   w "#{k} = #{v}"
    # end
    w "Version ruby : #{RUBY_VERSION}"
    w `gem env`
    w "Gem list: " + `gem list`
    require 'json'
    w 'JSON a pu être chargé'
    w 'Un hash jsonné : ' + {cle: "valeur"}.to_json
    require 'docile'
    w 'Docile a pu être chargé'
    require 'mysql2'
    w 'MYSQL2 a pu être chargé'
  rescue Exception => e
    STDOUT.write "<p>ERREUR</p>"
    STDOUT.write "<div style='margin-bottom:2em'>#{e.message}</div>"
    STDOUT.write e.backtrace.collect{|m| "<div>#{m}</div>"}.join('')
  end
  STDOUT.write '</body></html>'
rescue Exception => e
  STDOUT.write "Content-type: text/html; charset: utf-8;\n\n"
  STDOUT.write "<div style='padding:3em;font-size:15.2pt;color:red;'>"
  STDOUT.write "<div style='margin-bottom:2em'>#{e.message}</div>"
  STDOUT.write e.backtrace.collect{|m| "<div>#{m}</div>"}.join('')
  STDOUT.write '</div>'
end
