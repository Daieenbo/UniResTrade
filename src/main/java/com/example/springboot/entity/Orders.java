package com.example.springboot.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;


/**
 * <p>
 * 实体类
 * </p>
 */

@Data
@TableName(value = "orders")
public class Orders {

    @TableId(value = "id", type = IdType.AUTO)
    private Integer id;

    private String no;

    private String name;

    private String img;

    private Integer itemId;

    private BigDecimal price;

    private Integer fromId;

    private Integer toId;

    private String addressName;

    private String addressImg;

    private String status;

    private String time;

    @TableField(exist = false)
    private Integer addressId;
}
