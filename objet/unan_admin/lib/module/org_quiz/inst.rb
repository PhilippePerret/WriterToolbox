# encoding: UTF-8
class OrgQuiz

  attr_reader :filepath
  
  # +filepath+ Le path du fichier contenant le fichier de format
  # org-mode fait sous emacs.
  # 
  def initialize filepath
    @filepath = filepath
    @qdata = {
      title:            nil,
      id:               nil,
      type:             nil,
      note:             nil,
      description:      nil,
      show_description: nil,
      questions_ids:    nil,
      points:           nil,
      question:         []
    }
  end


  # Les lignes du fichier, sans aucun traitement en particulier
  def lines
    @lines ||= path.read.split("\n")
  end

  # Le path du fichier org-mode, mais en SuperFile
  def path
    @path ||= SuperFile.new(@filepath)
  end
end
