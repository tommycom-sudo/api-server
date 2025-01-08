/*
门诊结算查询SQL
主要用途：查询门诊病人的结算信息,包含以下主要信息:
- 病人基本信息(姓名、性别、出生日期等)
- 结算信息(结算金额、支付金额等) 
- 医保相关信息(医保类型、医保结算信息等)
- 就诊信息(就诊号、就诊时间等)

关联表说明:
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

SELECT s.ID_SPEDIS,                -- 收费项目ID
       s.idVismed,                 -- 就诊ID
       s.idMedstoe,               -- 结算ID
       s.sdMedstCd,               -- 结算类型代码
       s.naPi,                    -- 病人姓名
       s.cdPi,                    -- 病人编号
       s.sdSexCd,                 -- 性别代码
       s.bod,                     -- 出生日期
       s.idHiplMain,              -- 医保计划ID
       s.amtMedst,                -- 结算总金额
       s.amtMedstPi,              -- 医保结算金额
       s.amtPypm,                 -- 实际支付金额
       s.dtMedst,                 -- 结算时间
       s.cdPirecis,               -- 医保结算代码
       s.idMedpirecioe,           -- 医保结算ID
       s.cd_vismed,               -- 就诊号
       s.id_emp_medst,            -- 结算操作员
       s.fg_pireci_canc,          -- 医保结算取消标志
       s.id_emp_pireci_canc,      -- 医保结算取消操作员
       s.dt_pireci_canc,          -- 医保结算取消时间
       s.fg_medst_canc,           -- 结算取消标志
       s.id_emp_medst_canc,       -- 结算取消操作员
       s.dt_medst_canc,           -- 结算取消时间
       s.na_die_maj               -- 主要诊断名称
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
                --AND b.id_hipl_main = '669f826ac6dfe5001507807e'  -- 医保计划ID条件(已注释)
                --AND a.id_org = 'abc'                             -- 机构ID条件(已注释)
            GROUP BY 
                a.id_vismed, b.id_medstoe, b.sd_medst_cd, a.na_pi, e.cd_pi,
                a.sd_sex_cd, a.bod, b.id_hipl_main, b.amt_medst, b.amt_medst_pi, 
                b.dt_medst, a2.cd_vismed, b.id_emp_medst, t.sum, d.fg_pireci_canc,
                d.id_emp_pireci_canc, d.dt_pireci_canc, b.fg_medst_canc,
                b.id_emp_medst_canc, b.dt_medst_canc, die.na_die_maj
        ) oo 
        LEFT JOIN hi_bil_med_cg_oe k 
            ON k.id_medst_cg = oo.idMedstoe
    ) l
) s
WHERE s.group_idx = 1  -- 只取每组第一条记录
ORDER BY s.dtMedst DESC  -- 按结算时间倒序排序