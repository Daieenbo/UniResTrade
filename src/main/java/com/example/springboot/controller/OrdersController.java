package com.example.springboot.controller;

import cn.hutool.core.date.DateUtil;
import cn.hutool.core.util.RandomUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.springboot.common.Result;
import com.example.springboot.entity.Account;
import com.example.springboot.entity.Address;
import com.example.springboot.entity.Goods;
import com.example.springboot.entity.Orders;
import com.example.springboot.service.IAddressService;
import com.example.springboot.service.IGoodsService;
import com.example.springboot.service.IOrdersService;
import com.example.springboot.utils.TokenUtils;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.*;

import java.util.Date;
import java.util.List;

/**
 * <p>
 * 前端控制器
 * </p>
 */
@RestController
@RequestMapping("/orders")
public class OrdersController {

    @Resource
    private IOrdersService ordersService;
    @Resource
    private IGoodsService goodsService;
    @Resource
    private IAddressService addressService;

    @PostMapping
    public Result save(@RequestBody Orders orders) {
        if (orders.getId() == null) {
            Goods goods = goodsService.getById(orders.getItemId());
            orders.setNo(DateUtil.format(new Date(), "yyyyMMddHHmmss") + RandomUtil.randomNumbers(6));
            orders.setFromId(goods.getUserId());
            orders.setToId(TokenUtils.getCurrentUser().getId());
            orders.setName(goods.getName());
            orders.setImg(goods.getImg());
            orders.setPrice(goods.getPrice());
            orders.setStatus("待支付");
            orders.setTime(DateUtil.now());
            Address address = addressService.getById(orders.getAddressId());
            orders.setAddressName(address.getName());
            orders.setAddressImg(address.getImg());
            goods.setStatus("已售出");
            goodsService.updateById(goods);
        }
        return Result.success(ordersService.saveOrUpdate(orders));
    }

    @DeleteMapping("/{id}")
    public Result delete(@PathVariable Integer id) {
        return Result.success(ordersService.removeById(id));
    }

    @PostMapping("/del/batch")
    public Result deleteBatch(@RequestBody List<Integer> ids) {
        return Result.success(ordersService.removeByIds(ids));
    }

    @GetMapping
    public Result findAll() {
        return Result.success(ordersService.list());
    }

    @GetMapping("/cancel/{id}")
    public Result cancel(@PathVariable Integer id) {
        Orders orders = ordersService.getById(id);
        orders.setStatus("交易关闭");
        Goods goods = goodsService.getById(orders.getItemId());
        goods.setStatus("已上架");
        goodsService.updateById(goods);
        ordersService.updateById(orders);
        return Result.success();
    }


    @GetMapping("/pay/{id}")
    public Result pay(@PathVariable Integer id) {
        Orders orders = ordersService.getById(id);
        orders.setStatus("待发货");
        ordersService.updateById(orders);
        return Result.success();
    }

    @GetMapping("/shipment/{id}")
    public Result shipment(@PathVariable Integer id) {
        Orders orders = ordersService.getById(id);
        orders.setStatus("待收货");
        ordersService.updateById(orders);
        return Result.success();
    }

    @GetMapping("/receipt/{id}")
    public Result receipt(@PathVariable Integer id) {
        Orders orders = ordersService.getById(id);
        orders.setStatus("交易完成");
        ordersService.updateById(orders);
        return Result.success();
    }



    @GetMapping("/{id}")
    public Result findOne(@PathVariable Integer id) {
        return Result.success(ordersService.getById(id));
    }

    @GetMapping("/page")
    public Result findPage(@RequestParam Integer pageNum,
                           @RequestParam Integer pageSize,
                           @RequestParam(defaultValue = "") String keyword) {

        LambdaQueryWrapper<Orders> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.orderByDesc(Orders::getId);

        if (StrUtil.isNotBlank(keyword)) {
            queryWrapper.like(Orders::getNo, keyword);
        }

        return Result.success(ordersService.page(new Page<>(pageNum, pageSize), queryWrapper));
    }

    @GetMapping("/front/page")
    public Result findFrontPage(@RequestParam Integer pageNum,
                                @RequestParam Integer pageSize,
                                @RequestParam(defaultValue = "") String keyword,
                                @RequestParam(defaultValue = "全部") String status,
                                @RequestParam(defaultValue = "我卖出的") String flag) {
        LambdaQueryWrapper<Orders> wrapper = new LambdaQueryWrapper<>();
        Account account = TokenUtils.getCurrentUser();
        wrapper.orderByDesc(Orders::getTime);

        if (StrUtil.isNotBlank(keyword)) {
            wrapper.like(Orders::getNo, keyword);
        }
        if (!StrUtil.equals(status, "全部")) {
            wrapper.eq(Orders::getStatus, status);
        }
        if (StrUtil.equals(flag, "我卖出的")) {
            wrapper.eq(Orders::getFromId, account.getId());
        }
        if (StrUtil.equals(flag, "我买到的")) {
            wrapper.eq(Orders::getToId, account.getId());
        }

        return Result.success(ordersService.page(new Page<>(pageNum, pageSize), wrapper));
    }

}

