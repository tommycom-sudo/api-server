package com.example.demo.model;

import lombok.Data;

@Data
public class SmsRequestVO {
    private String phoneNumbers; // 手机号码，多个用逗号分隔
    private String content;      // 短信内容
    private String scheduleTime; // 预约发送时间，可选
} 