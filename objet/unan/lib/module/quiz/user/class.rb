# encoding: UTF-8
class User
class UQuiz
  class << self

    attr_reader :instances

    def get qid, quser = nil
      quser ||= user
      qid = qid.to_i
      @instances ||= Hash::new
      @instances[quser.id] ||= Hash::new
      @instances[quser.id][qid] ||= new(quser, qid)
    end

  end # << self
end #/UQuiz
end #/User
