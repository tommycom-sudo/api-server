package com.example.demo.controller;

import com.example.demo.model.SettlementQueryVO;
import com.example.demo.model.SettlementVO;
import com.example.demo.service.SettlementService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;

@RestController
@RequestMapping("/api/settlements")
public class SettlementController {

    @Autowired
    private SettlementService settlementService;

    @GetMapping
    public List<SettlementVO> querySettlements(SettlementQueryVO queryVO) {
        return settlementService.querySettlements(queryVO);
    }
}