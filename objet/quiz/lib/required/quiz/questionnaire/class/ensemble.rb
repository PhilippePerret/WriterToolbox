# encoding: UTF-8
class ::Quiz
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
          dbname.start_with?("#{SiteHtml::DBBASE_PREFIX}quiz_") || (next nil)
          dbname.sub(/#{Regexp.escape SiteHtml::DBBASE_PREFIX}quiz_/o, '')
        end.compact
      end
    end

    # Array des instances Quiz de tous les quiz
    #
    # Noter que les quiz hors list ne sont pas retournés par cette liste
    def allquiz
      @allquiz ||= begin
        arr = Array.new
        all_suffixes_quiz.each do |sufbase|
          arr += site.dbm_table("quiz_#{sufbase}", 'quiz').select(colonnes:[]).collect do |row|
            q = new(row[:id], sufbase)
            if q.hors_liste?
              nil
            else
              q
            end
          end.compact
        end
        arr
      end
    end
  end #/ << self Quiz
end #/Quiz
