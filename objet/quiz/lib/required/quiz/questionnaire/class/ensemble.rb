# encoding: UTF-8
class Quiz
  class << self

    # Tous les suffixes de bases de données dans toutes les
    # bases de données du site.
    #
    # Permet en quelque sorte de récupérer tous les quiz dans
    # toutes les bases où il y en a
    #
    # Noter que même les quiz hors liste sont retournés par
    # cette liste, contrairement à all_quiz qui ne retourne
    # que les quiz de la liste (hors quiz test).
    #
    def all_suffixes_quiz
      @all_suffixes_quiz ||= begin
        SiteHtml::DBM_TABLE.databases.collect do |dbname|
          dbname.start_with?("#{site.prefix_databases}_quiz_") || (next nil)
          dbname.sub(/#{Regexp.escape site.prefix_databases}_quiz_/o, '')
        end.compact
      end
    end

    # Array des instances Quiz de tous les quiz
    #
    # Noter que les quiz hors list ne sont pas retournés par cette liste
    # "hors liste" signifie que le 6e bit des options est à 1.
    #
    def allquiz
      @allquiz ||= begin
        arr = Array.new
        all_suffixes_quiz.each do |sufbase|
          arr += site.dbm_table("quiz_#{sufbase}", 'quiz').select(colonnes:[]).collect do |row|
            q = new(row[:id], sufbase)
            q.hors_liste? ? nil : q
          end.compact
        end
        arr
      end
    end
    #/allquiz

    def allquiz_hors_liste
      @allquiz_hors_liste ||= begin
        arr = Array.new
        all_suffixes_quiz.each do |sufbase|
          arr += site.dbm_table("quiz_#{sufbase}", 'quiz').select(colonnes:[]).collect do |row|
            q = new(row[:id], sufbase)
            q.hors_liste? ? q : nil
          end.compact
        end
        arr
      end
    end
    #/allquiz_hors_liste

  end #/ << self Quiz
end #/Quiz
