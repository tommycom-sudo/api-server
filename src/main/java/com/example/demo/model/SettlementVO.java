package com.example.demo.model;

import lombok.Data;
import java.math.BigDecimal;
import java.util.Date;

@Data
public class SettlementVO {
    private String vismedId;
    private String medstoeId;
    private String medstCd;
    private String patientName;
    private String patientCode;
    private String patientId;
    private String gender;
    private Date birthDate;
    private String insurancePlanId;
    private BigDecimal totalAmount;
    private BigDecimal insuranceAmount;
    private BigDecimal actualPayment;
    private Date settlementTime;
    private String visitNumber;
    private String mainDiagnosis;
    private String orgId;
    private String orgName;
} 