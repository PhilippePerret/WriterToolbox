# encoding: UTF-8
class Analyse
class Depot
class << self


  # Sortie affichée si le visiteur est un administrateur ou un
  # analyste
  def output_as_analyste
    <<-HTML
    <p>
      Déposez tous vos fichiers d'analyses, puis <b>rejoignez l'accueil pour les traiter</b>.
    </p>
    #{formulaire_depot_fichier}
    HTML
  end
  # /output_as_analyste



  # Sortie affichée si le visiteur est un simple user
  def output_as_common_user
    <<-HTML
<p>Cette section permet aux analystes de déposer leurs fichiers d'analyse.</p>
<p>Si vous voulez participer aux analyses, rejoignez l'onglet “Participer”.</p>
<p>Si vous voulez savoir en quoi consiste le travail d'analyste, rejoignez l'onglet “Aide”</p>
    HTML
  end
  # /output_as_common_user

end #/<< self
end#Depot
end#Analyse
