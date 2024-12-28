package com.example.demo.controller;

import lombok.Data;
import java.util.List;

@Data
public class DepartmentVO {
    private String id;
    private String code;
    private String name;
    private String parentId;
    private List<DepartmentVO> children;

    public DepartmentVO(String id, String code, String name, String parentId) {
        this.id = id;
        this.code = code;
        this.name = name;
        this.parentId = parentId;
    }
} 