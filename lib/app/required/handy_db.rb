# encoding: UTF-8
def dbtable_connexions
  @dbtable_connexions ||= User.table_connexions
end
