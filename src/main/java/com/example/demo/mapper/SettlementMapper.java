package com.example.demo.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.demo.model.SettlementVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.Date;
import java.util.List;

/**
 * 门诊结算查询Mapper
 */
@Mapper
public interface SettlementMapper extends BaseMapper<SettlementVO> {
    
    /**
     * 查询门诊结算信息
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @param patientName 病人姓名
     * @param patientId 病人ID
     * @return 结算信息列表
     */
    List<SettlementVO> querySettlements(
        @Param("startTime") Date startTime,
        @Param("endTime") Date endTime,
        @Param("patientName") String patientName,
        @Param("patientId") String patientId
    );
} 