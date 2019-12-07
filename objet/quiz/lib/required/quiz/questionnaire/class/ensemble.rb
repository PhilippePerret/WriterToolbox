# encoding: UTF-8
class Quiz
  class << self

    # Array des instances Quiz de tous les quiz
    #
    # Noter que les quiz hors list ne sont pas retournés par cette liste
    # "hors liste" signifie que le 6e bit des options est à 1.
    #
    def allquiz
      @allquiz ||= begin
        arr = Array.new
        arr += site.dbm_table("quiz", 'quiz').select(colonnes:[]).collect do |row|
          # Si ce n'est pas l'administrateur, on ne prend que les
          # quiz à partir de l'identifiant 10
          row[:id] < 10 && !user.admin? && next
          q = new(row[:id])
          q.hors_liste? ? nil : q
        end.compact
        arr
      end
    end
    #/allquiz

    def allquiz_hors_liste
      @allquiz_hors_liste ||= begin
        arr = Array.new
        arr += site.dbm_table("quiz", 'quiz').select(colonnes:[]).collect do |row|
          # Si ce n'est pas l'administrateur, on ne prend que les
          # quiz à partir de l'identifiant 10
          row[:id] < 10 && !user.admin? && next
          q = new(row[:id])
          q.hors_liste? ? q : nil
        end.compact
        arr
      end
    end
    #/allquiz_hors_liste

  end #/ << self Quiz
end #/Quiz
