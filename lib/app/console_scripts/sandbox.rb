# encoding: UTF-8


site.require_module('quiz')

class Quiz
  def suffix_base; 'biblio' end
end

Quiz.new(1).database_create;
