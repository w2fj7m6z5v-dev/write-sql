/**
 * @file 老年客群订单案例演示数据
 */

export const caseAge65Demo = {
  userQuery:
    "请教下，能帮忙取一下近三个月，机主年龄大于等于65岁的所有订单不？",

  assetDirectory: [
    {
      name: "SKILL.md",
      kind: "entry",
      title: "运行流程入口",
      desc: "规定自然语言取数的基本节奏：先澄清需求，再做方案确认，最后生成 SQL。",
    },
    {
      name: "METRIC_INDEX.md / metrics/",
      kind: "metric",
      title: "标准指标资产",
      desc: "沉淀指标 ID、指标名称、技术口径和来源表，例如 [M-BASIC-BB-001] 主宽入网数。",
    },
    {
      name: "TABLE_INDEX.md / tables/",
      kind: "table",
      title: "表资产与字段说明",
      desc: "整理主表、补表、字段、分区、粒度和注意事项，支撑 AI 找对表、用对字段。",
    },
    {
      name: "ROUTING.md",
      kind: "route",
      title: "主表路由规则",
      desc: "把业务口语映射到取数路径，例如订单明细走 040，客户年龄补 069。",
    },
    {
      name: "FIELD_BACKFILL.md",
      kind: "route",
      title: "字段补表规则",
      desc: "当主表缺字段时，说明该补哪张表、用什么关联键、有哪些粒度风险。",
    },
    {
      name: "RULES.md",
      kind: "rule",
      title: "SQL 审计规则",
      desc: "约束时间口径、隐私字段、多步 CTAS、自检 SQL 等交付要求。",
    },
    {
      name: "verified-cases/",
      kind: "case",
      title: "真实案例沉淀",
      desc: "把已验证的典型场景沉淀下来，后续遇到相似需求可复用路径和口径。",
    },
  ],

  generalFlow: [
    {
      title: "自然语言需求输入",
      source: "业务原话",
      desc: "接收业务人员的一句话需求，先识别业务对象、时间范围、输出结果和限制条件。",
    },
    {
      title: "识别指标 / 维度 / 对象",
      source: "METRIC_INDEX + 高频字段",
      desc: "判断是否命中标准指标，或是否涉及常见维度、客户对象、订单对象等业务要素。",
    },
    {
      title: "路由到主表",
      source: "TABLE_INDEX + ROUTING",
      desc: "根据业务术语确定主表和取数路径，避免 AI 直接猜表名、猜字段。",
    },
    {
      title: "锁定字段与时间口径",
      source: "tables/",
      desc: "从表文档确认字段含义、分区、粒度和时间字段，明确统计窗口与业务时间。",
    },
    {
      title: "缺字段时补表",
      source: "FIELD_BACKFILL",
      desc: "主表缺少年龄、组织、销售品、收入等字段时，按补表规则补齐并说明关联键。",
    },
    {
      title: "生成 SQL 并自检交付",
      source: "RULES.md",
      desc: "输出可执行 SQL，同时附带数量、去重、月份分布等自检语句，方便验收。",
    },
  ],

  summary:
    "我们围绕 CDAP 自然语言取数开展能力建设，已沉淀指标口径、高频维度、表资产、主表路由、字段补表、审计规则和真实案例流程。当前能力可将业务口语需求转成可确认、可执行、可校验的 SQL，初步形成支撑人员取数经验复用的技能化雏形。",

  planRows: [
    { item: "查什么", value: "订单明细（号码订单 040 + 优惠订单 041）" },
    {
      item: "年龄",
      value:
        "069 最新资料月，按身份证 social_id 推算，≥65 岁（当前年份减出生年）",
    },
    {
      item: "时间",
      value: "受理时间 act_date，近三个月 202604–202606",
    },
    {
      item: "订单范围",
      value: "040 + 041 全部状态，不排除撤单/作废/未竣工",
    },
    {
      item: "默认假设",
      value:
        "机主信息取自 069 资料；非身份证证件无法算年龄会被排除",
    },
  ],

  knowledgeHits: [
    {
      name: "ROUTING.md",
      role: "命中「年龄客群 + 订单明细」路由",
      desc: "069 圈 serv_id → 040/041 订单池，年龄与订单时间两套口径",
    },
    {
      name: "FIELD_BACKFILL.md",
      role: "补表规则",
      desc: "当前年龄客群订单明细：先 069 再关联 040/041，月表+当前表合并",
    },
    {
      name: "069_全业务资料表.md",
      role: "年龄计算主表",
      desc: "social_id + social_id_type 推算 age，取最新资料月快照",
    },
    {
      name: "040 / 041 订单表文档",
      role: "订单事实来源",
      desc: "par_month_id 是归档月；按 act_date 过滤业务时间",
    },
    {
      name: "RULES.md",
      role: "SQL 审计规则",
      desc: "多步 CTAS 落盘、禁止 WITH、不输出身份证原文",
    },
  ],

  sqlSteps: [
    {
      step: 1,
      table: "tmp_age65_serv_202606",
      title: "圈老年客群 serv_id",
      desc: "069 最新资料月，身份证推算 age ≥ 65",
    },
    {
      step: 2,
      table: "tmp_age65_order_pool_202606",
      title: "合并 040/041 订单池",
      desc: "归档月表 UNION 当前表，按 subs_id 去重",
    },
    {
      step: 3,
      table: "ads_age65_order_3m_202606",
      title: "关联输出最终结果",
      desc: "serv_id 关联 + act_date 近三个月过滤",
    },
  ],

  sqlSnippet: `-- Step1: 069 最新资料月圈 age >= 65
create table tmp_age65_serv_202606 as
select serv_id, acc_nbr, ...
from dwm_yz_tb_comm_cm_all_final a
where par_month_id = (select max(par_month_id) from dwm_yz_tb_comm_cm_all_final)
  and case when length(social_id)=18 and social_id_type='1'
       then year(current_date)-cast(substr(social_id,7,4) as int)
       ... end >= 65;

-- Step2: 040/041 月表 + 当前表合并去重
-- Step3: inner join + act_date 202604-202606`,

  selfCheck: [
    "select count(*), count(distinct serv_id) from tmp_age65_serv_202606",
    "select count(*), count(distinct subs_id) from ads_age65_order_3m_202606",
    "按 order_type、受理月 group by 检查分布是否合理",
  ],

  /**
   * 标注点坐标（百分比，相对截图容器）
   */
  annotations: [
    {
      id: 1,
      label: "业务同事用自然语言提需求",
      target: { x: 78, y: 8 },
      labelPos: { x: 52, y: 2 },
    },
    {
      id: 2,
      label: "技能按流程检索知识库",
      target: { x: 12, y: 42 },
      labelPos: { x: 2, y: 18 },
    },
    {
      id: 3,
      label: "锁定字段、分区与口径来源",
      target: { x: 42, y: 38 },
      labelPos: { x: 28, y: 22 },
    },
    {
      id: 4,
      label: "先对齐主表与时间口径",
      target: { x: 76, y: 32 },
      labelPos: { x: 55, y: 26 },
    },
    {
      id: 5,
      label: "输出可落盘、可验收的 Hive SQL",
      target: { x: 78, y: 72 },
      labelPos: { x: 50, y: 88 },
    },
  ],

  flowSteps: [
    {
      title: "拆需求",
      source: "用户输入",
      desc: "抽出业务对象、时间口径、输出粒度和限制条件。",
    },
    {
      title: "读技能入口",
      source: "SKILL.md",
      desc: "判断走标准指标、主表路由还是补表路径。",
    },
    {
      title: "定主表路由",
      source: "ROUTING.md",
      desc: "命中「年龄客群+订单明细」：069 → 040/041。",
    },
    {
      title: "锁字段与补表",
      source: "tables/ + FIELD_BACKFILL",
      desc: "069 算年龄；040/041 合并订单池。",
    },
    {
      title: "方案确认",
      source: "一次对齐",
      desc: "主表、年龄快照、时间字段、订单范围一次说清。",
    },
    {
      title: "审计交付",
      source: "RULES.md",
      desc: "多步 CTAS、分区裁剪、自检 SQL 与风险提示。",
    },
  ],

  /**
   * 左真实截图 + 右技能资产目录。流程/规则资产讲用途；表资产只列命中的主表/补表。
   */
  matrixRows: {
    callouts: [
      {
        id: 1,
        label: "业务原话",
        target: { x: 60, y: 6 },
        assetId: "skill",
      },
      {
        id: 2,
        label: "需求澄清",
        target: { x: 54, y: 20 },
        assetId: "skill",
      },
      {
        id: 3,
        label: "方案确认",
        target: { x: 28, y: 38 },
        assetId: "routing",
      },
      {
        id: 4,
        label: "主表/补表",
        target: { x: 42, y: 43 },
        assetId: "table040",
      },
      {
        id: 5,
        label: "年龄口径",
        target: { x: 55, y: 52 },
        assetId: "table069",
      },
      {
        id: 6,
        label: "SQL 与自检",
        target: { x: 56, y: 80 },
        assetId: "rules",
      },
    ],
    processAssets: [
      {
        id: "skill",
        kind: "flow",
        name: "SKILL.md",
        position: "write-query 的运行流程入口。",
        use: "指导 AI 先做需求澄清，再方案确认，最后生成 SQL。",
        solves: "避免业务一句话进来就直接猜表、猜字段、漏问关键口径。",
        anchorY: 16,
      },
      {
        id: "routing",
        kind: "flow",
        name: "ROUTING.md",
        position: "业务术语到取数链路的路由规则。",
        use: "识别“年龄客群 + 订单明细”应走 069 补年龄、040 取订单。",
        solves: "把口语需求转成稳定的主表/补表路径。",
        anchorY: 34,
      },
      {
        id: "backfill",
        kind: "flow",
        name: "FIELD_BACKFILL.md",
        position: "主表缺字段时的补表规则。",
        use: "订单表没有年龄字段，因此需要补 069 当前资料月后再关联订单。",
        solves: "让跨表需求有固定补字段链路，不靠临场经验拼表。",
        anchorY: 52,
      },
      {
        id: "rules",
        kind: "rule",
        name: "RULES.md",
        position: "SQL 生成后的审计与交付规则。",
        use: "约束多步 CTAS、不输出身份证原文，并附带自检 SQL。",
        solves: "保证 SQL 可执行、可验收、隐私风险可控。",
        anchorY: 70,
      },
    ],
    tableAssets: [
      {
        id: "table040",
        name: "040_全业务号码订单表.md",
        role: "订单主表",
        keyFields: "取所有订单明细；按 act_date 过滤 202604-202606。",
        anchorY: 84,
      },
      {
        id: "table069",
        name: "069_全业务资料表.md",
        role: "年龄补表",
        keyFields: "取当前资料月；用 social_id/social_id_type 推算机主年龄。",
        anchorY: 93,
      },
    ],
  },
};
