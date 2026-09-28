package com.example.springboot.controller;

import cn.hutool.json.JSONArray;
import cn.hutool.json.JSONObject;
import com.example.springboot.common.Result;

import com.example.springboot.entity.Category;
import com.example.springboot.entity.Goods;
import com.example.springboot.service.ICategoryService;
import com.example.springboot.service.IGoodsService;

import jakarta.annotation.Resource;
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.TokenStream;
import org.apache.lucene.analysis.tokenattributes.CharTermAttribute;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/echarts")
public class EchartsController {

    @Resource
    private ICategoryService categoryService;
    @Resource
    private IGoodsService goodsService;

    @Resource
    private Analyzer analyzer;

    /**
     * 停用词词典：
     *   - 中文助词、虚词、语气词
     *   - 常见无意义单字会被长度规则直接拦截，无需列举
     */
    private static final Set<String> STOP_WORDS = new HashSet<>(Arrays.asList(
            // 助词
            "的", "地", "得", "着", "了", "过", "们",
            // 虚词 / 连词
            "和", "与", "或", "及", "而", "但", "却", "虽", "因", "以", "将",
            "被", "把", "让", "使", "向", "对", "从", "到", "在", "为", "是",
            "有", "无", "不", "非", "也", "都", "还", "再", "就", "才", "更",
            "很", "最", "太", "比", "于", "之", "其", "这", "那", "何", "哪",
            "谁", "么", "啊", "吧", "呢", "哦", "哈", "嗯",
            // 常见无意义词
            "一个", "一种", "一些", "什么", "如何", "可以", "进行", "通过",
            "已经", "非常", "比较", "相关", "包括", "使用", "提供", "实现"
    ));

    @GetMapping("/count")
    public Result count(){

        List<Category> list = categoryService.list();

        Map<Integer, Long> map = goodsService.list().stream().collect(Collectors.groupingBy(Goods::getCateId,Collectors.counting()));

        JSONArray array = new JSONArray();

        for (Category category : list) {
            JSONObject object = new JSONObject();
            object.set("name",category.getName());
            object.set("value",map.getOrDefault(category.getId(),0L));
            array.add(object);
        }

        return Result.success(array);
    }


    /**
     * 判断一个分词是否为有效词，过滤规则：
     *   1. 单个字符（单汉字、单字母、单数字）
     *   2. 纯数字（含小数、负数，如 3、2、10.4）
     *   3. 字母+数字混合（型号规格类，如 g102、20000mah）
     *   4. 命中停用词词典
     */
    private boolean isValidWord(String word) {
        if (word == null || word.trim().isEmpty()) return false;

        String w = word.trim();

        // 规则1：单个字符直接过滤
        if (w.length() <= 1) return false;

        // 规则2：纯数字（含小数点、负号）
        if (w.matches("^-?\\d+(\\.\\d+)?$")) return false;

        // 规则3：字母与数字混合（如 g102、20000mah、10.4inch）
        if (w.matches("^[a-zA-Z0-9]+$") && w.matches(".*[a-zA-Z].*") && w.matches(".*[0-9].*")) return false;

        // 规则4：命中停用词
        if (STOP_WORDS.contains(w)) return false;

        return true;
    }

    public List<String> textHandler(String text) {

        //输出分词结果
        List<String> wordList = new ArrayList<>();

        // 将文本转换为Reader对象
        StringReader reader = new StringReader(text);

        try {

            // 获取TokenStream对象
            TokenStream tokenStream = analyzer.tokenStream("content", reader);

            // 获取CharTermAttribute对象，用于获取分词结果
            CharTermAttribute charTermAttr = tokenStream.addAttribute(CharTermAttribute.class);

            // 重置TokenStream，准备读取分词结果
            tokenStream.reset();

            // 循环读取分词结果
            while (tokenStream.incrementToken()) {
                String word = charTermAttr.toString();
                if (isValidWord(word)) {
                    wordList.add(word);
                }
            }

            tokenStream.close();
        } catch (IOException e) {
            System.err.println("分词错误");
        }

        return wordList;
    }

    @GetMapping("/countName")
    public Result countName() {
        Map<String, Integer> map = new HashMap<>();

        for (Goods goods : goodsService.list()) {
            List<String> wordList = textHandler(goods.getName());
            for (String word : wordList) {
                map.merge(word, 1, Integer::sum);
            }
        }

        // 将 map 转换为 List 以便排序
        List<Map.Entry<String, Integer>> sortedEntries = new ArrayList<>(map.entrySet());

        // 按照 value 值降序排序
        sortedEntries.sort((entry1, entry2) -> entry2.getValue().compareTo(entry1.getValue()));

        JSONArray array = new JSONArray();

        // 只保留前 20 个
        for (int i = 0; i < Math.min(sortedEntries.size(), 40); i++) {
            Map.Entry<String, Integer> entry = sortedEntries.get(i);
            JSONObject object = new JSONObject();
            object.set("name", entry.getKey());
            object.set("value", entry.getValue());
            array.add(object);
        }

        return Result.success(array);
    }


}
