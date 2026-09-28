<script setup>

import { ref, onMounted } from 'vue'
import request from '../../utils/request'
import * as echarts from 'echarts';
import 'echarts-wordcloud';

const ordersCount = ref(0)
const loadOrdersCount = ()=>{
  request.get('/orders').then(res=>{
    ordersCount.value = res.data.length
  })
}
loadOrdersCount()

const articleCount = ref(0)
const loadArticleCount = ()=>{
  request.get('/article').then(res=>{
    articleCount.value = res.data.length
  })
}
loadArticleCount()

onMounted(()=>{

  const chartDom = document.getElementById('main');
  const myChart = echarts.init(chartDom);

  const option = {
    title: {
      text: '不同分类闲置资源数量统计',
      subtext: '饼图',
      left: 'center'
    },
    tooltip: {
      trigger: 'item'
    },
    legend: {
      orient: 'vertical',
      left: 'left'
    },
    series: [
      {
        name: 'Access From',
        type: 'pie',
        radius: '50%',
        data: [],
        emphasis: {
          itemStyle: {
            shadowBlur: 10,
            shadowOffsetX: 0,
            shadowColor: 'rgba(0, 0, 0, 0.5)'
          }
        }
      }
    ]
  };

  request.get("/echarts/count").then(res=>{
    res.data.forEach(item=>{
      option.series[0].data.push(item)
    })
    option && myChart.setOption(option);
  })



  const chartDom2 = document.getElementById('main2');
  const myChart2 = echarts.init(chartDom2);

  const option2 = {
    title: {
      text: '闲置资源名称词云图',
      subtext: '统计维度：二手物品名称出现次数',
      left: 'center'
    },
    series: [
      {
        type: 'wordCloud',
        /**
         * 绘制词云的形状, 值为回调函数 或 关键字, 默认 circle
         *  关键字:
         *
         * circle（圆形）  词的数量不太多的时候，效果不明显，它会趋向于画一个椭圆
         * cardioid（苹果形或心形曲线）
         * diamond（菱形 正方形）
         * triangle-forward（三角形-向前）
         * triangle（三角形-直立）
         * pentagon（五边形）
         * star（星形）
         */
        shape: 'circle',
        // 保持 maskImage 的纵横比或形状的纵横比为 1：1
        keepAspect: false,
        /**
         * 词云轮廓图，支持为 HTMLImageElement, HTMLCanvasElement，不支持路径字符串, 不包含白色区域; 可选选项
         * shape选项将随着云的形状增长而继续应用
         * 有形状限制的时候，最好用背景图来实现，而且这个背景图一定要放base64的，不然词云画不出来
         */
        // maskImage: maskImage,

        // 词云整个图表放置的位置 和 尺寸大小
        left: 'center',
        top: 'center',
        width: '100%',
        height: '100%',
        right: null,
        bottom: null,
        // 词云文本大小范围,  默认为最小12像素，最大60像素
        sizeRange: [30, 40],
        // 词云文字旋转范围和步长。 文本将通过旋转在[-90，90]范围内随机旋转步骤45
        // 如果都设置为 0 , 则是水平显示
        rotationRange: [0, 0],
        rotationStep: 0,
        /**
         * 词间距, 距离越大，单词之间的间距越大, 单位像素
         * 这里间距太小的话，会出现大词把小词套住的情况，比如一个大的口字，中间会有比较大的空隙，这时候他会把一些很小的字放在口字里面，这样的话，鼠标就无法选中里面的那个小字
         */
        gridSize: 20,
        // 设置为true可以使单词部分在画布之外绘制, 允许绘制大于画布大小的单词
        drawOutOfBound: false,
        /**
         * 布局的时候是否有动画
         * 注意：禁用时，当单词较多时，将导致UI阻塞。
         */
        layoutAnimation: true,
        // 这是全局的文字样式，相对应的还可以对每个词设置字体样式
        textStyle: {
          fontFamily: 'sans-serif',
          fontWeight: 'bold',
          // 颜色可以用一个函数来返回字符串
          color: function () {
            // 随机颜色
            return (
                'rgb(' +
                [
                  Math.round(Math.random() * 160),
                  Math.round(Math.random() * 160),
                  Math.round(Math.random() * 160),
                ].join(',') +
                ')'
            )
          },
        },
        // 鼠标hover的特效样式
        emphasis: {
          focus: 'self',
          textStyle: {
            textShadowBlur: 10,
            textShadowColor: '#999'
          }
        },
        /**
         * 词云数据，必须是一个数组，每个数组项必须有name和value属性
         * 设置单个文本的样式：  textStyle
         *
         * 例：{
         name: '',
         value: 40,
         textStyle: {
         }
         },
         */
        data: []
      }
    ]
  };

  request.get('/echarts/countName').then(res => {
    res.data.forEach(item => {
      option2.series[0].data.push(item)
    })
    myChart2.setOption(option2);
  })

})


</script>

<template>
  <div style="padding: 10px">

    <el-row :gutter="24">

      <el-col :span="12">
        <el-card style="width: 100%;font-size: 20px">
          <span>交易订单数量:{{ordersCount}}</span>
        </el-card>
      </el-col>

      <el-col :span="12">
        <el-card style="width: 100%;font-size: 20px">
          <span>文章数量:{{articleCount}}</span>
        </el-card>
      </el-col>

    </el-row>

    <el-row :gutter="24" style="margin-top: 50px">

      <el-col :span="12">
        <div id="main" style="width: 100%; height: 600px"></div>
      </el-col>

      <el-col :span="12">
        <div id="main2" style="width: 100%; height: 600px;"></div>
      </el-col>

    </el-row>

  </div>
</template>

<style scoped>

</style>