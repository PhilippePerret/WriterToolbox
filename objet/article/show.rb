# encoding: UTF-8

def article
  @article ||= begin
    require _('current.rb')
    Article.new CURRENT_ARTICLE_ID
  end
end
