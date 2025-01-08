/*
门诊结算查询SQL
主要用途：查询门诊病人的结算信息,包含以下主要信息:
- 病人基本信息(姓名、性别、出生日期等)
- 结算信息(结算金额、支付金额等) 
- 医保相关信息(医保类型、医保结算信息等)
- 就诊信息(就诊号、就诊时间等)

关联表说明:
- bbp.hi_sys_org: 机构信息表,包含机构ID(id_org)和机构名称(na)
- hi_vis_med: 就诊记录主表
- hi_vis_med_op: 就诊记录扩展表 
- hi_bil_med_st_oe: 门诊结算表
- hi_bil_med_st_oe_pireci: 医疗收费_结算_门急诊_个人票据
- hi_bil_med_pireci_oe: 医疗收费_个人票据_门急诊
- hi_pi: 人信息表
- hi_bil_med_pipy_oe: 医疗收费_个人收退款_门急诊
- hi_bil_med_pipy_oe_pm: 医疗收费_个人收退款_门急诊_付款方式
- hi_vis_med_die: 诊断信息表
- hi_bil_med_cg_oe: 收费项目表
*/

SELECT s.ID_SPEDIS AS "收费项目ID_hi_bil_med_cg_oe_ID_SPEDIS",
       s.idVismed AS "就诊ID_hi_vis_med_id_vismed",
       s.idMedstoe AS "结算ID_hi_bil_med_st_oe_id_medstoe",
       s.sdMedstCd AS "结算类型代码_hi_bil_med_st_oe_sd_medst_cd",
       s.naPi AS "病人姓名_hi_vis_med_na_pi",
       s.cdPi AS "病人编号_hi_pi_cd_pi",
       s.idPi AS "病人ID_hi_pi_id_pi",
       s.sdSexCd AS "性别代码_hi_vis_med_sd_sex_cd",
       s.bod AS "出生日期_hi_vis_med_bod",
       s.idHiplMain AS "医保计划ID_hi_bil_med_st_oe_id_hipl_main",
       s.amtMedst AS "结算总金额_hi_bil_med_st_oe_amt_medst",
       s.amtMedstPi AS "医保结算金额_hi_bil_med_st_oe_amt_medst_pi",
       s.amtPypm AS "实际支付金额_hi_bil_med_pipy_oe_pm_amt_pypm",
       s.dtMedst AS "结算时间_hi_bil_med_st_oe_dt_medst",
       s.cdPirecis AS "结算代码_hi_bil_med_pireci_oe_cd_pireci",
       s.idMedpirecioe AS "结算ID_hi_bil_med_pireci_oe_id_medpirecioe",
       s.cd_vismed AS "就诊号_hi_vis_med_op_cd_vismed",
       s.id_emp_medst AS "结算操作员_hi_bil_med_st_oe_id_emp_medst",
       s.fg_pireci_canc AS "结算取消标志_hi_bil_med_pireci_oe_fg_pireci_canc",
       s.id_emp_pireci_canc AS "结算取消操作员_hi_bil_med_pireci_oe_id_emp_pireci_canc",
       s.dt_pireci_canc AS "结算取消时间_hi_bil_med_pireci_oe_dt_pireci_canc",
       s.fg_medst_canc AS "结算取消标志_hi_bil_med_st_oe_fg_medst_canc",
       s.id_emp_medst_canc AS "结算取消操作员_hi_bil_med_st_oe_id_emp_medst_canc",
       s.dt_medst_canc AS "结算取消时间_hi_bil_med_st_oe_dt_medst_canc",
       s.na_die_maj AS "主要诊断名称_hi_vis_med_die_na_die_maj",
       s.id_org AS "机构ID_hi_sys_org_id_org",
       s.na_org AS "机构名称_hi_sys_org_na"
FROM (
    SELECT l.*,
           -- 按结算号和医保代码分组,取每组第一条
           ROW_NUMBER() OVER (PARTITION BY l.str ORDER BY l.id_spedis) AS group_idx 
    FROM (
        SELECT k.ID_SPEDIS, oo.*
        FROM (
            SELECT 
                a.id_vismed AS idVismed,
                b.id_medstoe AS idMedstoe, 
                b.sd_medst_cd AS sdMedstCd,
                a.na_pi AS naPi,
                e.cd_pi AS cdPi,
                e.id_pi AS idPi,
                a.sd_sex_cd AS sdSexCd,
                a.bod AS bod,
                b.id_hipl_main AS idHiplMain,
                -- 格式化金额,去除多余小数点
                RTRIM(TO_CHAR(b.amt_medst,'fm9999999990.99'),'.') AS amtMedst,
                RTRIM(TO_CHAR(b.amt_medst_pi,'fm9999999990.99'),'.') AS amtMedstPi,
                NVL(t.sum,0) amtPypm,
                b.dt_medst AS dtMedst,
                -- 合并多个医保结算代码
                LISTAGG(d.cd_pireci, ',') WITHIN GROUP (ORDER BY d.cd_pireci) AS cdPirecis,
                LISTAGG(d.id_medpirecioe, ',') WITHIN GROUP (ORDER BY d.cd_pireci) AS idMedpirecioe,
                a2.cd_vismed,
                b.id_emp_medst,
                d.fg_pireci_canc,
                d.id_emp_pireci_canc, 
                d.dt_pireci_canc,
                b.fg_medst_canc,
                b.id_emp_medst_canc,
                b.dt_medst_canc,
                die.na_die_maj,
                org.id_org,                     -- 机构ID
                org.na AS na_org,               -- 机构名称
                -- 用于分组的字符串
                CONCAT(b.id_medstoe,LISTAGG(d.cd_pireci, ',') WITHIN GROUP (ORDER BY d.cd_pireci)) AS str
            FROM hi_vis_med a
            JOIN hi_vis_med_op a2 
                ON a.id_vismed = a2.id_vismed
            JOIN hi_bil_med_st_oe b 
                ON a.id_vismed = b.id_vismed 
                AND (b.sd_medst_cd = '111' OR b.sd_medst_cd = '112' OR b.sd_medst_cd = '311')
            LEFT JOIN hi_bil_med_st_oe_pireci c 
                ON b.id_medstoe = c.id_medstoe
            LEFT JOIN hi_bil_med_pireci_oe d 
                ON c.id_medpirecioe = d.id_medpirecioe
            LEFT JOIN hi_pi e 
                ON a.id_pi = e.id_pi
            LEFT JOIN bbp.hi_sys_org org       -- 关联机构信息表
                ON org.id_org = a.id_org
            -- 计算实际支付金额的子查询
            LEFT JOIN (
                SELECT SUM(f.EU_DIRECT * g.AMT_PYPM) sum,
                       f.ID_MEDSTOE idMedstoe
                FROM HI_BIL_MED_PIPY_OE f
                RIGHT JOIN HI_BIL_MED_PIPY_OE_PM g 
                    ON g.ID_MEDPIPYOE = f.ID_MEDPIPYOE
                    AND SD_PIPYPM_CD = '1'
                GROUP BY f.ID_MEDSTOE
            ) t ON t.idMedstoe = c.ID_MEDSTOE
            LEFT JOIN HI_VIS_MED_DIE die 
                ON a.ID_VISMED = die.ID_VISMED
                AND die.delete_flag != '1'
            WHERE 1 = 1
                -- 查询时间范围
                AND b.dt_medst >= TO_DATE('2024-11-25 00:00:00', 'yyyy-MM-dd HH24:mi:ss') 
                AND b.dt_medst <= TO_DATE('2024-12-02 23:59:59', 'yyyy-MM-dd HH24:mi:ss')
                
                --AND a.na_pi = :na_pi                            -- 按姓名查询条件(需要传入参数)
                --AND e.id_pi = :id_pi                            -- 按病人ID查询条件(需要传入参数)
            GROUP BY 
                a.id_vismed, b.id_medstoe, b.sd_medst_cd, a.na_pi, e.cd_pi, e.id_pi,
                a.sd_sex_cd, a.bod, b.id_hipl_main, b.amt_medst, b.amt_medst_pi, 
                b.dt_medst, a2.cd_vismed, b.id_emp_medst, t.sum, d.fg_pireci_canc,
                d.id_emp_pireci_canc, d.dt_pireci_canc, b.fg_medst_canc,
                b.id_emp_medst_canc, b.dt_medst_canc, die.na_die_maj, org.id_org, org.na
        ) oo 
        LEFT JOIN hi_bil_med_cg_oe k 
            ON k.id_medst_cg = oo.idMedstoe
    ) l
) s
WHERE s.group_idx = 1  -- 只取每组第一条记录
ORDER BY s.dtMedst DESC  -- 按结算时间倒序排序