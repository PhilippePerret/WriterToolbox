# encoding: UTF-8
class Unan
class Quiz
  class << self
    attr_reader :instances

    def get quiz_id
      quiz_id = quiz_id.to_i
      @instances ||= Hash::new
      @instances[quiz_id] ||= new(quiz_id)
    end

  end # << self
end #/Quiz
end #Unan
