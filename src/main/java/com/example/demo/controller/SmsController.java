package com.example.demo.controller;

import com.example.demo.config.SmsConfig;
import com.example.demo.model.SmsRequestVO;
import com.example.demo.model.SmsResponseVO;
import com.example.demo.common.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;

import java.util.Random;

@RestController
@RequestMapping("/api/sms")
public class SmsController {
    
    @Autowired
    private SmsConfig smsConfig;
    
    @PostMapping("/send")
    public Result<SmsResponseVO> sendSms(@RequestBody SmsRequestVO request) {
        try {
            // 生成20位流水号（当前时间戳+6位随机数）
            String serialNumber = System.currentTimeMillis() + 
                String.format("%06d", new Random().nextInt(999999));
            
            // 准备请求参数
            MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
            params.add("SpCode", smsConfig.getSpCode());
            params.add("LoginName", smsConfig.getLoginName());
            params.add("Password", smsConfig.getPassword());
            params.add("MessageContent", request.getContent());
            params.add("UserNumber", request.getPhoneNumbers());
            params.add("SerialNumber", serialNumber);
            params.add("ScheduleTime", request.getScheduleTime());
            params.add("f", "1");
            
            // 发送请求
            RestTemplate restTemplate = new RestTemplate();
            ResponseEntity<String> response = restTemplate.postForEntity(
                smsConfig.getUrl() + "/Send.do", 
                params, 
                String.class
            );
            
            // 解析响应
            String[] result = response.getBody().split("&");
            SmsResponseVO smsResponse = new SmsResponseVO();
            for (String item : result) {
                String[] keyValue = item.split("=");
                if (keyValue.length == 2) {
                    switch (keyValue[0]) {
                        case "result":
                            smsResponse.setResult(keyValue[1]);
                            break;
                        case "description":
                            smsResponse.setDescription(new String(keyValue[1].getBytes("ISO-8859-1"), "GBK"));
                            break;
                        case "faillist":
                            smsResponse.setFaillist(keyValue[1]);
                            break;
                    }
                }
            }
            
            return Result.success(smsResponse);
        } catch (Exception e) {
            return Result.error("500", e.getMessage());
        }
    }
} 