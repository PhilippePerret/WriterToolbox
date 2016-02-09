# encoding: UTF-8
=begin
Appelé pour générer un fichier YAML permettant d'entrer des questions
rapidement sans se servir de l'interface
=end
raise_unless_admin
require 'yaml'
class UnanAdmin
class Quiz
class Question

  class << self

    # Pour lire le résultat d'une opération
    attr_reader :resultat

    # Génération d'un fichier YAML
    def generate_yaml_file
      yaml_name = "questions_quiz_#{NOW}.yaml"
      yaml_path = site.folder_tmp + yaml_name
      yaml_path.write code_type_yaml_file
      flash "Le fichier `#{yaml_path.expanded_path}` a été généré."
    end

    # Récupération des questions définies
    def get_questions
      file = param(:questions_yaml_file)

      # On va fabriquer un autre fichier pour pouvoir
      # utiliser la méthode load_file de YAML.
      yaml_original_name = file.original_filename
      yaml_name = "tmp_#{yaml_original_name}"
      yaml_tmp_path = site.folder_tmp + "#{yaml_name}"

      # On écrit le code dans le fichier
      yaml_tmp_path.write file.read


      # On parse le code du fichier
      # ----------------------------
      begin
        # code_yaml = YAML.parse(code)
        code_yaml = YAML.load_file(yaml_tmp_path.to_s).to_sym
      rescue Exception => e
        error "Impossible de parser le code YAML : #{e.message}."
        debug e
        return
      end


      # On finalise les hash de données
      # -------------------------------
      # Après le parsing, les questions se trouvent dans un array
      # de hash contenant leurs données, mais en version minimale (avec
      # des valeurs par défaut sous-entendues). Il faut donc préparer
      # chaque Hash pour son enregistrement
      final_questions = code_yaml.collect do |hquestion|


        # On corrige la question, la raison et l'indication si elles
        # sont données
        [:question, :indication, :raison].each do |key|
          hquestion[key] ||= nil
          next if hquestion[key].nil?
          hquestion[key] = hquestion[key].purified.nil_if_empty
        end

        raise "Il faut obligatoirement fournir une question !" if hquestion[:question].nil?

        # Traitement des réponses pour en faire des maps correctes
        ireponse = 0
        hquestion[:reponses] = hquestion[:reponses].collect do |linerep|
          libelle, points = if linerep.match(/::/)
            rep, pts = linerep.split('::')
            [ rep.purified.nil_if_empty, pts.to_i ]
          else
            [ linerep, nil ]
          end
          ireponse += 1
          raise "Une réponse ne peut être vide !" if libelle.nil?
          { libelle:libelle, points:points, id:ireponse }
        end

        raise "Il faut obligatoirement fournir des réponses !" if hquestion[:reponses].nil? || hquestion[:reponses].empty?

        in_select   = hquestion.delete(:select) == true
        en_colonne  = hquestion.delete(:dispo) != 'line'

        type_c = hquestion.delete(:multi) ? 'c' : 'r' # 'r' ou 'c'
        type_a = in_select ? 'm' : (en_colonne ? 'c' : 'l') # 'c', 'l', 'm'
        type_f = hquestion.delete(:type) || 0
        hquestion.merge!( type: "#{type_c}#{type_a}#{type_f}")
        hquestion[:created_at] = hquestion[:updated_at] = NOW
        hquestion
      end

      # On enregistre les question en prenant les identifiants pour
      # les donner à l'administrateur, avec les questions.
      resultat = Array::new
      final_questions = final_questions.collect do |hquestion|
        id = Unan::table_questions.insert( hquestion )
        resultat << "La question “#{hquestion[:question]}” porte l'identifiant ##{id}"
        hquestion.merge!(id: id)
      end

      debug "QUESTIONS ENREGISTRÉES : " + final_questions.collect{|h|h.pretty_inspect}.join("\n")

      # Le résultat à afficher
      @resultat = resultat.collect{|l| l.in_div}.join

      flash "Questions enregistrées avec succès"

    ensure
      yaml_tmp_path.remove if yaml_tmp_path.exist?
    end

    # Le code type
    def code_type_yaml_file
      <<-YAML
# Code type pour entrer des questions rapidement à l'aide d'un
# fichier YAML
# -
#   question: "La question à poser à l'utilisateur"
#   reponses:
#     - La réponse 1::nombre de points # il peut ne pas y avoir de points
#     - La réponse 2::nombre de points
#   # Données optionnelles
#   type:   0       # 0 est la valeur par défaut, c'est le questionnaire qui
#                   # définit la valeur. Cf ci-dessous les valeurs
#   unique: true    # mettre false si on peut choisir plusieurs réponses. Noter que
#                   # par défaut la donnée est true
#   dispo:  col     # 'col' ou 'line' pour la disposition. Noter que par défaut
#                   # la dispotion est en colonne
#   select: false   # mettre à true si c'est un menu select. Noter que si
#                   # cette donnée est absente, elle sera considérée comme false
#   indication: >
#     Texte pour donner une indication sous la question posée.
#   raison: >
#     La raison pour laquelle la bonne réponse (la plus importante en points)
#     est la bonne réponse.
# Valeurs pour `type`:
# 0:indéfini, 1:simple renseignement, 2:validation acquis, 3:quiz, 7:sondage,
# 9:autre type
-
  question: ""
  reponses:
    - REPONSE_UN::POINTS
    - REPONSE_DEUX::POINTS
    - REPONSE_TROIS::POINTS
# Puisque 'unique' n'est pas précisé, sera true, puisque 'dispo' n'est pas
# précisé, sera 'col' puisque 'select' n'est pas précisé sera false.

# Question avec CHOIX MULTIPLE
-
  question: ""
  reponses:
    - REPONSE_UN::POINTS
    - REPONSE_DEUX::POINTS
    - REPONSE_TROIS::POINTS
  unique: false

# Question avec DISPOSITION HORIZONTALE
-
  question: ""
  reponses:
    - REPONSE_UN::POINTS
    - REPONSE_DEUX::POINTS
    - REPONSE_TROIS::POINTS
  dispo: line

      YAML
    end
  end # / << self

end #/Question
end #/QUiz
end #/UnanAdmin


case param(:operation)
when NilClass
  debug "--- Pas d'opération ---"
when 'generate_yaml_file'
  UnanAdmin::Quiz::Question::generate_yaml_file
when 'get_data_questions'
  UnanAdmin::Quiz::Question::get_questions
else
  flash "Je ne connais pas l'opération #{param(:operation)}"
end
