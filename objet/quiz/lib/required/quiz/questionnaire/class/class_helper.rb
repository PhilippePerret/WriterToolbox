# encoding: UTF-8
class ::Quiz
  class << self

    def titre
      @titre ||= "Quizzzz !"
    end

    # Les onglets
    #
    # TODO Peut-être les régler plus tard
    def data_onglets
      @data_onglets ||= begin
        dongs = Hash.new
        if user.manitou?
          dongs.merge!(
            'Nouveau quiz'      => 'quiz/new',
            'Edit quiz courant' => "quiz/#{current.id}/edit?qdbr=#{current.suffix_base}"
            )
        end
        unless current.id == site.route.objet_id && current.suffix_base == suffix_base
          dongs.merge!('Quiz courant' => "quiz/#{current.id}/show")
        end
        dongs.merge!('Tous les quizzzz' => 'quiz/list')
      end
    end

  end #/<< self
end #/Quiz
