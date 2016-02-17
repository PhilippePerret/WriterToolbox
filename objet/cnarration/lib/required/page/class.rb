# encoding: UTF-8
class Cnarration
class Page
  class << self

    def get page_id
      page_id = page_id.to_i
      @instances ||= Hash::new
      @instances[page_id] ||= new(page_id)
    end
    
  end #/<< self
end #/Page
end #/Cnarration
