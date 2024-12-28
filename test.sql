SELECT id_dep, cd, na, id_par,* FROM bbp.hi_sys_dep WHERE id_org = '6672a56ef88a25000102d4db'

id_par = NULL 表示一级科室，否则是对应上级科室的id_dep
