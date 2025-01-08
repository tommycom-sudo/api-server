package com.example.demo.model;

import lombok.Data;

@Data
public class SmsResponseVO {
    private String result;       // 结果
    private String description;  // 错误描述
    private String faillist;     // 失败号码列表
} 