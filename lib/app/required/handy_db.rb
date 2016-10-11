# encoding: UTF-8
def dbtable_connexions
  @dbtable_connexions ||= User.table_connexions
end
def dbtable_checkform
  @dbtable_checkform ||= site.dbm_table(:hot, 'checkform')
end
