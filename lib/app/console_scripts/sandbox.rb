# encoding: UTF-8


site.require_module('quiz')

class Quiz
  def prefix_base; 'biblio' end
end

Quiz.new(1).database_create;
