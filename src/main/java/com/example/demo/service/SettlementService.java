package com.example.demo.service;

import com.example.demo.model.SettlementQueryVO;
import com.example.demo.model.SettlementVO;
import java.util.List;

public interface SettlementService {
    List<SettlementVO> querySettlements(SettlementQueryVO queryVO);
}