-- ============================================================================
-- UniResTrade 高校闲置资源交易平台 —— 数据库初始化脚本
--
-- 用法：
--   mysql -u root -p < sql/init.sql
--
-- 说明：
--   1. 表名与字段均以 Java 实体类上的 MyBatis-Plus 注解为准。
--   2. 实体类继承体系中带 @TableField(exist = false) 的字段（role/newPassword/token/
--      prefix/num/isCollected/addressId）不是数据库列，本脚本未建。
--   3. 所有跨表关联（goods.cate_id → category.id 等）仅以注释说明，未添加外键约束，
--      避免演示数据与业务写入受插入顺序限制。
--   4. 演示账号密码为明文，与 UserServiceImpl / AdminServiceImpl 中的明文等值比较
--      逻辑保持一致。
--   5. 字段长度沿用了项目实际使用的库结构（255 为主），以保证与既有数据兼容。
-- ============================================================================

CREATE DATABASE IF NOT EXISTS idle_resource DEFAULT CHARACTER SET utf8mb4;
USE idle_resource;

SET NAMES utf8mb4;

-- ----------------------------------------------------------------------------
-- 1. sys_admin：管理员表
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS `sys_admin`;
CREATE TABLE `sys_admin` (
    `id`         INT          NOT NULL AUTO_INCREMENT COMMENT 'id',
    `username`   VARCHAR(255) DEFAULT NULL            COMMENT '用户名',
    `password`   VARCHAR(255) DEFAULT NULL            COMMENT '密码（当前为明文存储，见 README 已知不足）',
    `nickname`   VARCHAR(255) DEFAULT NULL            COMMENT '昵称',
    `avatar_url` VARCHAR(255) DEFAULT NULL            COMMENT '头像',
    `email`      VARCHAR(255) DEFAULT NULL            COMMENT '邮箱',
    `phone`      VARCHAR(255) DEFAULT NULL            COMMENT '电话',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '管理员管理';

-- ----------------------------------------------------------------------------
-- 2. sys_user：普通用户（学生）表
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user` (
    `id`         INT          NOT NULL AUTO_INCREMENT COMMENT 'id',
    `username`   VARCHAR(255) DEFAULT NULL            COMMENT '用户名（学号）',
    `password`   VARCHAR(255) DEFAULT NULL            COMMENT '密码（当前为明文存储，见 README 已知不足）',
    `nickname`   VARCHAR(255) DEFAULT NULL            COMMENT '昵称',
    `avatar_url` VARCHAR(255) DEFAULT NULL            COMMENT '头像',
    `email`      VARCHAR(255) DEFAULT NULL            COMMENT '邮箱',
    `phone`      VARCHAR(255) DEFAULT NULL            COMMENT '电话',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '用户管理';

-- ----------------------------------------------------------------------------
-- 3. category：闲置资源分类表
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category` (
    `id`   INT          NOT NULL AUTO_INCREMENT COMMENT 'id',
    `name` VARCHAR(255) DEFAULT NULL            COMMENT '名称',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '资源分类管理';

-- ----------------------------------------------------------------------------
-- 4. goods：闲置资源（商品）表
--    关联：user_id → sys_user.id    发布者
--          cate_id → category.id    所属分类
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS `goods`;
CREATE TABLE `goods` (
    `id`       INT            NOT NULL AUTO_INCREMENT COMMENT 'id',
    `name`     VARCHAR(255)   DEFAULT NULL            COMMENT '标题',
    `img`      VARCHAR(255)   DEFAULT NULL            COMMENT '物品封面',
    `img_list` VARCHAR(255)   DEFAULT NULL            COMMENT '物品其他图片（多个地址以逗号拼接）',
    `info`     TEXT                                   COMMENT '物品详情',
    `quality`  VARCHAR(255)   DEFAULT NULL            COMMENT '成色',
    `price`    DECIMAL(10, 2) DEFAULT NULL            COMMENT '价格',
    `cate_id`  INT            DEFAULT NULL            COMMENT '分类id（关联 category.id）',
    `user_id`  INT            DEFAULT NULL            COMMENT '用户id（关联 sys_user.id）',
    `status`   VARCHAR(255)   DEFAULT NULL            COMMENT '物品状态：已上架 / 已售出',
    PRIMARY KEY (`id`),
    KEY `idx_goods_cate_id` (`cate_id`),
    KEY `idx_goods_user_id` (`user_id`),
    KEY `idx_goods_status` (`status`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '闲置资源管理';

-- ----------------------------------------------------------------------------
-- 5. orders：交易订单表
--    关联：item_id → goods.id      交易的商品
--          from_id → sys_user.id   卖家
--          to_id   → sys_user.id   买家
--    说明：address_name / address_img 为下单时从 address 表复制过来的快照字段，
--          因此 address 表本身没有外键列。
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders` (
    `id`           INT            NOT NULL AUTO_INCREMENT COMMENT 'id',
    `no`           VARCHAR(255)   DEFAULT NULL            COMMENT '订单号（时间戳 + 6 位随机数）',
    `name`         VARCHAR(255)   DEFAULT NULL            COMMENT '物品名称（下单时快照）',
    `img`          VARCHAR(255)   DEFAULT NULL            COMMENT '商品图（下单时快照）',
    `item_id`      INT            DEFAULT NULL            COMMENT '物品id（关联 goods.id）',
    `price`        DECIMAL(10, 2) DEFAULT NULL            COMMENT '价格',
    `from_id`      INT            DEFAULT NULL            COMMENT '卖家id（关联 sys_user.id）',
    `to_id`        INT            DEFAULT NULL            COMMENT '买家id（关联 sys_user.id）',
    `address_name` VARCHAR(255)   DEFAULT NULL            COMMENT '交易地点（快照）',
    `address_img`  VARCHAR(255)   DEFAULT NULL            COMMENT '地点图示（快照）',
    `status`       VARCHAR(255)   DEFAULT NULL            COMMENT '状态：待支付 / 待发货 / 待收货 / 交易完成 / 交易关闭',
    `time`         VARCHAR(255)   DEFAULT NULL            COMMENT '时间（字符串存储）',
    PRIMARY KEY (`id`),
    KEY `idx_orders_item_id` (`item_id`),
    KEY `idx_orders_from_id` (`from_id`),
    KEY `idx_orders_to_id` (`to_id`),
    KEY `idx_orders_no` (`no`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '交易订单管理';

-- ----------------------------------------------------------------------------
-- 6. chat：聊天消息表
--    关联：from_user_id → sys_user.id   发送方
--          to_user_id   → sys_user.id   接收方
--    说明：is_read 用于未读统计，仅表示「接收方是否已读」。
--          time 由前端 new Date().toLocaleString('zh-cn') 生成，格式形如
--          "2026/3/21 21:04:23"，因此按字符串存储。
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS `chat`;
CREATE TABLE `chat` (
    `id`           INT          NOT NULL AUTO_INCREMENT COMMENT 'id',
    `text`         VARCHAR(255) DEFAULT NULL            COMMENT '文本内容（文字正文或图片地址）',
    `type`         VARCHAR(255) DEFAULT NULL            COMMENT '文本类型：文字 / 图片',
    `time`         VARCHAR(255) DEFAULT NULL            COMMENT '创建时间（字符串存储）',
    `from_user_id` INT          DEFAULT NULL            COMMENT '来自用户id（关联 sys_user.id）',
    `to_user_id`   INT          DEFAULT NULL            COMMENT '发往用户id（关联 sys_user.id）',
    `is_read`      TINYINT      DEFAULT NULL            COMMENT '是否已读：0-未读，1-已读',
    PRIMARY KEY (`id`),
    KEY `idx_chat_from_user_id` (`from_user_id`),
    KEY `idx_chat_to_user_id` (`to_user_id`),
    KEY `idx_chat_is_read` (`is_read`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '聊天管理';

-- ----------------------------------------------------------------------------
-- 7. address：线下交易地点表
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS `address`;
CREATE TABLE `address` (
    `id`   INT          NOT NULL AUTO_INCREMENT COMMENT 'id',
    `name` VARCHAR(255) DEFAULT NULL            COMMENT '名称（如：校本部・北门广场）',
    `img`  VARCHAR(255) DEFAULT NULL            COMMENT '图示',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '交易区域管理';

-- ----------------------------------------------------------------------------
-- 8. collect：收藏表
--    关联：user_id → sys_user.id   收藏人
--          item_id → goods.id      被收藏的商品
--    (user_id, item_id) 唯一，防止同一用户重复收藏同一商品。
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS `collect`;
CREATE TABLE `collect` (
    `id`      INT NOT NULL AUTO_INCREMENT COMMENT 'id',
    `user_id` INT DEFAULT NULL            COMMENT '用户id（关联 sys_user.id）',
    `item_id` INT DEFAULT NULL            COMMENT '收藏id（关联 goods.id）',
    PRIMARY KEY (`id`),
    UNIQUE KEY `user_id` (`user_id`, `item_id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '收藏管理';

-- ----------------------------------------------------------------------------
-- 9. banner：首页轮播图表
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS `banner`;
CREATE TABLE `banner` (
    `id`   INT          NOT NULL AUTO_INCREMENT COMMENT 'id',
    `name` VARCHAR(255) DEFAULT NULL            COMMENT '说明',
    `img`  VARCHAR(255) DEFAULT NULL            COMMENT '封面',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '轮播图管理';

-- ----------------------------------------------------------------------------
-- 10. article：校园资讯 / 攻略文章表
--     content 由 wangEditor 富文本编辑器产生，内容为 HTML 片段，故用 LONGTEXT。
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS `article`;
CREATE TABLE `article` (
    `id`      INT          NOT NULL AUTO_INCREMENT COMMENT 'id',
    `name`    VARCHAR(255) DEFAULT NULL            COMMENT '标题',
    `time`    VARCHAR(255) DEFAULT NULL            COMMENT '时间',
    `img`     VARCHAR(255) DEFAULT NULL            COMMENT '封面',
    `content` LONGTEXT                             COMMENT '内容（富文本 HTML）',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '文章管理';

-- ----------------------------------------------------------------------------
-- 11. notice：系统公告表
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS `notice`;
CREATE TABLE `notice` (
    `id`   INT          NOT NULL AUTO_INCREMENT COMMENT 'id',
    `name` VARCHAR(255) DEFAULT NULL            COMMENT '标题',
    `info` VARCHAR(255) DEFAULT NULL            COMMENT '内容',
    `time` VARCHAR(255) DEFAULT NULL            COMMENT '时间',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '公告管理';


-- ============================================================================
-- 演示数据
--   演示账号密码均为明文，可直接用于登录（与 UserServiceImpl / AdminServiceImpl
--   中的明文等值比较逻辑一致，详见 README「已知不足」一节）。
--   账号一览：admin / 123456 ，2021001 / 123456 ，2021002 / 123456
-- ============================================================================

-- 管理员
INSERT INTO `sys_admin` (`id`, `username`, `password`, `nickname`, `avatar_url`, `email`, `phone`) VALUES
(1, 'admin', '123456', '平台管理员', NULL, 'admin@example.com', '13800000000');

-- 普通用户
INSERT INTO `sys_user` (`id`, `username`, `password`, `nickname`, `avatar_url`, `email`, `phone`) VALUES
(1, '2021001', '123456', '李同学', NULL, 'li@example.com', '13800000001'),
(2, '2021002', '123456', '王同学', NULL, 'wang@example.com', '13800000002');

-- 资源分类
INSERT INTO `category` (`id`, `name`) VALUES
(1, '教材书籍'),
(2, '数码电子'),
(3, '生活用品'),
(4, '运动器材'),
(5, '服饰鞋包');

-- 线下交易地点
INSERT INTO `address` (`id`, `name`, `img`) VALUES
(1, '校本部・北门广场', NULL),
(2, '图书馆正门', NULL),
(3, '东校区宿舍区中心花园', NULL);

-- 闲置资源
INSERT INTO `goods` (`id`, `name`, `img`, `img_list`, `info`, `quality`, `price`, `cate_id`, `user_id`, `status`) VALUES
(1, '《数据结构与算法分析》C语言版 第二版', NULL, NULL, '大三上学期课程用书，仅翻阅过前四章，书页干净无笔记，扉页有姓名已用胶带覆盖。', '9成新', 18.00, 1, 1, '已上架'),
(2, '罗技 G102 有线游戏鼠标', NULL, NULL, '大一买的，用了半年，滚轮和左右键一切正常，因换无线鼠标出手，附带原装包装盒。', '8成新', 55.00, 2, 1, '已上架'),
(3, '宿舍小台灯（可调光 USB 接口）', NULL, NULL, '毕业清仓，三档亮度可调，USB 供电，灯管无损坏。', '9成新', 15.00, 3, 2, '已上架'),
(4, '迪卡侬羽毛球拍 双拍套装', NULL, NULL, '含拍套与三只羽毛球，仅打过四五次，拍线张力良好。', '9成新', 70.00, 4, 2, '已上架'),
(5, '小米移动电源 20000mAh', NULL, NULL, '容量大适合出差，电芯健康，支持 18W 快充，外观有轻微使用痕迹。', '8成新', 60.00, 2, 1, '已上架'),
(6, '《计算机网络：自顶向下方法》第七版', NULL, NULL, '考研复习用书，书内有大量铅笔笔记，可擦拭，介意者慎拍。', '7成新', 25.00, 1, 2, '已上架');

-- 商品收藏
INSERT INTO `collect` (`id`, `user_id`, `item_id`) VALUES
(1, 2, 2),
(2, 1, 4);

-- 交易订单
INSERT INTO `orders` (`id`, `no`, `name`, `img`, `item_id`, `price`, `from_id`, `to_id`, `address_name`, `address_img`, `status`, `time`) VALUES
(1, '20260310120100123456', '小米移动电源 20000mAh', NULL, 5, 60.00, 1, 2, '图书馆正门', NULL, '交易完成', '2026-03-10 12:01:00'),
(2, '20260405143000123457', '宿舍小台灯（可调光 USB 接口）', NULL, 3, 15.00, 2, 1, '校本部・北门广场', NULL, '待发货', '2026-04-05 14:30:00');

-- 聊天记录
INSERT INTO `chat` (`id`, `text`, `type`, `time`, `from_user_id`, `to_user_id`, `is_read`) VALUES
(1, '同学你好，请问这本《数据结构》还有吗？', '文字', '2026/3/10 11:50:12', 2, 1, 1),
(2, '有的，书况和描述一致，需要的话可以约个时间当面看。', '文字', '2026/3/10 11:52:30', 1, 2, 1),
(3, '好的，那明天下午三点在图书馆正门方便吗？', '文字', '2026/3/10 11:53:05', 2, 1, 0);

-- 首页轮播图
INSERT INTO `banner` (`id`, `name`, `img`) VALUES
(1, '闲置不浪费，好物遇知音，校园二手更温暖。', NULL),
(2, '以闲置为媒，以共享为桥，让互助充满校园。', NULL),
(3, '欢迎新同学！闲置焕新，好物相遇，校园生活更省心。', NULL);

-- 校园资讯文章
INSERT INTO `article` (`id`, `name`, `time`, `img`, `content`) VALUES
(1, '校园二手交易避坑指南', '2026-03-21 20:00:09', NULL, '<p>在校园二手交易中，既能淘到高性价比好物、处理闲置物品，也可能遇到一些小麻烦。</p><p>首先，交易渠道要选对，务必通过本校二手交易平台发布和查看商品，拒绝私下加入陌生群聊、添加不明好友交易，避免脱离平台监管。</p><p>其次，商品核验要细致，优先选择校内公共场所当面交易，比如图书馆门口、教学楼大厅等人员密集区域，当面检查商品的成色、功能是否与描述一致。</p><p>最后，遇到违规行为要及时通过平台举报通道反馈，平台会第一时间处理，下架违规商品、限制违规账号，共同维护良好的交易环境。</p>'),
(2, '绿色校园倡议书——让闲置赋能环保', '2026-03-21 20:01:27', NULL, '<p>亲爱的同学们：当我们的书桌被闲置的教材堆满，衣柜里躺着穿不上的衣物，宿舍角落摆放着用不上的生活用品，你是否想过，这些看似无用的闲置，其实是未被发掘的资源？</p><p>我们倡议，树立“闲置不浪费，循环更环保”的理念，主动整理宿舍内的闲置物品，将自己用不上但仍有使用价值的物品，通过校园二手交易平台发布，让资源得到合理利用。</p><p>闲置不是浪费，循环方显价值。让我们携手同行，从整理一件闲置物品开始，让绿色理念扎根校园的每一个角落。</p>'),
(3, '诚信交易倡议书——让善意温暖校园', '2026-03-21 20:02:47', NULL, '<p>亲爱的同学们：校园二手交易平台，是连接同校学子、传递善意与便利的桥梁，而诚信，是这座桥梁的基石。</p><p>我们倡议，每一位卖家都能坚守诚信原则，如实描述商品的成色、使用情况、存在瑕疵等关键信息，不夸大优点、不隐瞒缺点，上传真实的商品实拍图；合理定价，参考同类商品的市场行情，不恶意抬价。</p><p>我们倡议，每一位买家都能友善沟通、理性议价，尊重他人的劳动与时间，共同营造温暖的校园交易氛围。</p>');

-- 系统公告
INSERT INTO `notice` (`id`, `name`, `info`, `time`) VALUES
(1, '交易须知', '校内二手交易，禁止违规物品，文明沟通，诚信交易。', '2026-03-21 19:41:37'),
(2, '安全提醒', '建议校内当面交易，注意财产安全，不随意转账。', '2026-03-21 19:42:36'),
(3, '欢迎使用', '欢迎发布闲置，好物循环，方便你我，节约实用。', '2026-03-21 19:42:58');
