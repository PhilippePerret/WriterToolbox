# encoding: UTF-8
class Forum
  class << self

    def table_posts
      @table_posts ||= site.db.create_table_if_needed('forum', 'posts')
    end

    def table_sujets
      @table_sujets ||= site.db.create_table_if_needed('forum', 'sujets')
    end

    def table_categories
      @table_categories ||= site.db.create_table_if_needed('forum', 'categories')
    end

  end # << self
end #/Forum
