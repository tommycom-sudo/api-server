package com.example.demo.service.impl;

import com.example.demo.mapper.SettlementMapper;
import com.example.demo.model.SettlementQueryVO;
import com.example.demo.model.SettlementVO;
import com.example.demo.service.SettlementService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

/**
 * 门诊结算查询服务实现类
 */
@Service
public class SettlementServiceImpl implements SettlementService {

    @Autowired
    private SettlementMapper settlementMapper;

    @Override
    public List<SettlementVO> querySettlements(SettlementQueryVO queryVO) {
        return settlementMapper.querySettlements(
            queryVO.getStartTime(),
            queryVO.getEndTime(),
            queryVO.getPatientName(),
            queryVO.getPatientId()
        );
    }
} 