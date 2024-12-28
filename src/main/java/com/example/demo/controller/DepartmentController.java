package com.example.demo.controller;

import com.example.demo.common.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/departments")
public class DepartmentController {
    
    @Autowired
    private JdbcTemplate jdbcTemplate;

    @GetMapping("/tree")
    public Result<List<DepartmentVO>> getDepartmentTree(@RequestParam String orgId) {
        try {
            // 获取所有科室数据
            String sql = "SELECT id_dep, cd, na, id_par FROM bbp.hi_sys_dep WHERE id_org = ? and fg_active = '1' order by sn,DT_CREATE";
            List<DepartmentVO> allDepts = jdbcTemplate.query(sql, 
                (rs, rowNum) -> new DepartmentVO(
                    rs.getString("id_dep"),
                    rs.getString("cd"),
                    rs.getString("na"),
                    rs.getString("id_par")
                ), 
                orgId
            );

            // 构建树形结构
            List<DepartmentVO> tree = new ArrayList<>();
            Map<String, List<DepartmentVO>> deptMap = new HashMap<>();

            // 按父ID分组
            allDepts.forEach(dept -> {
                deptMap.computeIfAbsent(dept.getParentId(), k -> new ArrayList<>()).add(dept);
            });

            // 获取顶级科室（parentId为null的）并递归构建树
            deptMap.getOrDefault(null, new ArrayList<>()).forEach(dept -> {
                buildDepartmentTree(dept, deptMap);
                tree.add(dept);
            });

            return Result.success(tree);
        } catch (Exception e) {
            return Result.error("500", e.getMessage());
        }
    }

    private void buildDepartmentTree(DepartmentVO parent, Map<String, List<DepartmentVO>> deptMap) {
        List<DepartmentVO> children = deptMap.getOrDefault(parent.getId(), new ArrayList<>());
        parent.setChildren(children);
        children.forEach(child -> buildDepartmentTree(child, deptMap));
    }

    @GetMapping
    public Result<List<DepartmentVO>> getAllDepartments(
            @RequestParam String orgId,
            @RequestParam(required = false) String id,
            @RequestParam(required = false) String code,
            @RequestParam(required = false) String name) {
        try {
            StringBuilder sql = new StringBuilder(
                "SELECT id_dep, cd, na, id_par FROM bbp.hi_sys_dep WHERE id_org = ? AND fg_active = '1'");
            List<Object> params = new ArrayList<>();
            params.add(orgId);

            // 添加 OR 条件的模糊查询
            boolean hasCondition = false;
            if (id != null && !id.trim().isEmpty() || 
                code != null && !code.trim().isEmpty() || 
                name != null && !name.trim().isEmpty()) {
                
                sql.append(" AND (");
                
                if (id != null && !id.trim().isEmpty()) {
                    sql.append("id_dep LIKE ?");
                    params.add("%" + id + "%");
                    hasCondition = true;
                }
                
                if (code != null && !code.trim().isEmpty()) {
                    if (hasCondition) sql.append(" OR ");
                    sql.append("cd LIKE ?");
                    params.add("%" + code + "%");
                    hasCondition = true;
                }
                
                if (name != null && !name.trim().isEmpty()) {
                    if (hasCondition) sql.append(" OR ");
                    sql.append("na LIKE ?");
                    params.add("%" + name + "%");
                }
                
                sql.append(")");
            }

            sql.append(" ORDER BY sn, dt_create");

            List<DepartmentVO> departments = jdbcTemplate.query(
                sql.toString(), 
                (rs, rowNum) -> new DepartmentVO(
                    rs.getString("id_dep"),
                    rs.getString("cd"),
                    rs.getString("na"),
                    rs.getString("id_par")
                ), 
                params.toArray()
            );
            return Result.success(departments);
        } catch (Exception e) {
            return Result.error("500", e.getMessage());
        }
    }
} 