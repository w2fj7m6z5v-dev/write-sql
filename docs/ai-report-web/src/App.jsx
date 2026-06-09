import { useMemo, useState } from "react";
import { Bot, BrainCircuit, DatabaseZap, LayoutDashboard, MessageCircle, Network } from "lucide-react";
import heroImage from "./assets/hero-ai-command.png";

const navItems = [
  ["pain", "项目痛点"],
  ["flow", "生成流程"],
  ["knowledge", "知识库资产"],
  ["case", "真实示例"],
  ["apps", "应用扩展"],
  ["value", "价值成效"],
];

const painPoints = [
  {
    label: "需求收口难",
    value: "多轮澄清",
    detail: "自然语言表达不统一，查什么、查谁、按什么时间经常需要反复确认。",
  },
  {
    label: "口径判断难",
    value: "状态歧义",
    detail: "入网、到达、在网、出账、拆机等业务词会影响主表、字段与过滤。",
  },
  {
    label: "表字段选择难",
    value: "104+ 表",
    detail: "CDAP 表多字段多，主表选择、字段映射和补表路径依赖熟手经验。",
  },
  {
    label: "重复工作重",
    value: "经验依赖",
    detail: "常规需求相似，但每次仍需人工理解、编写、检查和解释 SQL。",
  },
];

const flowSteps = [
  ["01", "自然语言需求拆解", "识别对象、时间、维度、限制与结果形式"],
  ["02", "关键条件自动澄清", "只追问会改变 SQL 结果的关键缺口"],
  ["03", "主表路由判断", "以业务事实定位 CDAP 主表和备选表"],
  ["04", "指标口径识别", "匹配标准指标、动作状态与时间口径"],
  ["05", "字段映射与补表", "按字段缺口规划维表或事实表 JOIN"],
  ["06", "Hive SQL 自动生成", "输出结构化、可审计、可复用 SQL"],
  ["07", "规则校验与自检", "同步输出风险提示、字段来源和自检 SQL"],
];

const knowledgeAssets = [
  ["TABLE_INDEX", "104 张表索引", "表名、Hive 名、粒度、分区与适用场景入口"],
  ["ROUTING", "主表路由", "业务术语到主表的判断规则，避免因字段相似误选表"],
  ["METRIC_INDEX", "指标索引", "标准指标到技术口径和单指标文件的统一入口"],
  ["FIELD_BACKFILL", "字段补表", "主表缺字段时的补表、JOIN 键、粒度与风险规则"],
  ["RULES", "SQL 规则", "CTAS、分区、JOIN、审计和自检 SQL 的生成规范"],
  ["verified-cases", "验证案例", "沉淀已验证的表选择、字段映射和编排模板"],
];

const appScenarios = [
  {
    title: "企业微信机器人",
    desc: "业务人员在企微中直接提问，实时返回 SQL 与口径说明。",
    icon: MessageCircle,
    position: "top-left",
  },
  {
    title: "业务门户",
    desc: "嵌入统一业务门户，形成自然语言取数入口。",
    icon: LayoutDashboard,
    position: "top-right",
  },
  {
    title: "自助取数平台",
    desc: "面向常规取数需求，提供可追溯、可复核的查询生成。",
    icon: DatabaseZap,
    position: "bottom-left",
  },
  {
    title: "智能指标问答",
    desc: "围绕指标解释、字段来源和趋势口径提供问答能力。",
    icon: Bot,
    position: "bottom-right",
  },
];

const valueCards = [
  ["SQL 初稿效率", "50%+", "常规 SQL 初稿从小时级压缩到分钟级"],
  ["需求澄清时间", "30%+", "自动收口关键条件，减少低效往返沟通"],
  ["新人上手周期", "明显缩短", "把熟手经验沉淀成可执行技能流程"],
  ["口径偏差", "持续减少", "统一主表、口径、字段和审计规则"],
];

const sqlExample = `SELECT
    a.subst_name              AS 分局,
    a.branch_name             AS 营服,
    a.sales_name              AS 揽装人,
    addr_dim.addr             AS 装机地址,
    xx.xx_salestaff_name1     AS 协销人,
    a.cell_name               AS 网格单元,
    COUNT(a.serv_id)          AS 主宽入网量
FROM dwm_yz_tb_comm_cm_all_final a
LEFT JOIN zone_gz_yz.dwd_yz_addr_final addr_dim
    ON a.serv_addr_id = CAST(addr_dim.id AS STRING)
LEFT JOIN zone_gz_yz.dwd_yz_cm_obj_xx_final xx
    ON a.serv_id = xx.serv_id
LEFT JOIN dws_crm_cfguse.dws_staff staff
    ON xx.xx_salestaff_code1 = staff.staff_code
LEFT JOIN zone_gz_yz.dwd_yz_dim_org xx_org
    ON staff.org_id = xx_org.org_id
WHERE a.par_month_id = '202605'
  AND a.is_new_user = 1
  AND DATE_FORMAT(a.open_date, 'yyyyMM') = '202605'
  AND a.prod_type = 40
  AND a.kd_desc = '普通宽带'
GROUP BY
    a.subst_name, a.branch_name, a.sales_name,
    addr_dim.addr, xx.xx_salestaff_name1, a.cell_name;`;

function scrollToSection(id) {
  document.getElementById(id)?.scrollIntoView({ behavior: "smooth", block: "start" });
}

function Stat({ label, value, sub }) {
  return (
    <div className="stat">
      <span>{label}</span>
      <strong>{value}</strong>
      <small>{sub}</small>
    </div>
  );
}

export function App() {
  const [caseMode, setCaseMode] = useState("sql");
  const [copied, setCopied] = useState(false);

  const casePanels = useMemo(
    () => ({
      sql: {
        title: "生成的 Hive SQL",
        body: sqlExample,
      },
      audit: {
        title: "字段来源与审计说明",
        body: [
          "主表：069 全业务资料表日表 / dwm_yz_tb_comm_cm_all_final",
          "口径：M-BASIC-BB-001 主宽入网数；本例按用户确认使用 prod_type=40。",
          "过滤：par_month_id='202605'、is_new_user=1、open_date 归属 202605、kd_desc='普通宽带'。",
          "补表：079 地址维表补装机地址；042 号码协销表补协销人；115 员工信息表补组织 ID；018 机构维表补机构名称。",
          "输出：分局、营服、揽装人、装机地址、协销人、网格单元、主宽入网量。",
        ].join("\n"),
      },
      risk: {
        title: "风险提示与自检",
        body: [
          "校验分区：确认 202605 分区存在且主表有数据。",
          "校验口径：prod_type=40 为用户确认口径，应在交付时标注与指标文件默认值差异。",
          "校验 JOIN：地址维表按 grade=10 去重；员工表需按 staff_code 取最新记录，避免一对多放大。",
          "校验质量：抽样检查 serv_id、地址、协销人、机构字段空值率。",
        ].join("\n"),
      },
    }),
    [],
  );

  async function handleCopySql() {
    await navigator.clipboard.writeText(sqlExample);
    setCopied(true);
    window.setTimeout(() => setCopied(false), 1600);
  }

  return (
    <main className="page-shell">
      <header className="site-header">
        <button className="brand" onClick={() => scrollToSection("top")} aria-label="回到顶部">
          <span className="brand-mark">AI</span>
          <span>自然语言取数能力底座</span>
        </button>
        <nav aria-label="页面章节">
          {navItems.map(([id, label]) => (
            <button key={id} onClick={() => scrollToSection(id)}>
              {label}
            </button>
          ))}
        </nav>
      </header>

      <section className="hero" id="top">
        <img className="hero-bg" src={heroImage} alt="AI 数据中枢背景" />
        <div className="hero-overlay" />
        <div className="hero-inner">
          <div className="hero-copy">
            <span className="eyebrow">Intelligent SQL Flow Hub</span>
            <h1>AI自然语言取数能力底座</h1>
            <p className="hero-subtitle">面向CDAP业务数据的智能SQL生成能力建设</p>
            <p className="hero-thesis">
              本项目不是单点取数工具，而是把业务取数流程、主表路由、指标口径、字段映射和 SQL 校验机制沉淀为可复用、可解释、可审计的 AI 能力底座。
            </p>
            <div className="hero-actions">
              <button onClick={() => scrollToSection("case")}>查看真实案例</button>
              <button className="ghost" onClick={() => scrollToSection("flow")}>生成流程</button>
            </div>
          </div>

          <div className="hero-workflow" aria-label="业务需求到SQL输出示意">
            <div className="demand-card">
              <span>业务自然语言需求</span>
              <strong>202605 主宽入网量按维汇总</strong>
              <small>分局、营服、揽装人、装机地址、协销人、网格单元</small>
            </div>
            <div className="engine-card">
              <span>AI理解引擎</span>
              <strong>需求拆解 · 口径识别 · 主表定位</strong>
              <div className="engine-rings" aria-hidden="true">
                <i />
                <i />
                <i />
              </div>
            </div>
            <div className="sql-card">
              <div className="code-top">
                <span />
                <span />
                <span />
                <small>Hive</small>
              </div>
              <pre>{`SELECT 分局, 营服, 揽装人,
       装机地址, 协销人,
       COUNT(serv_id) AS 主宽入网量
FROM 069 全业务资料表
WHERE par_month_id='202605'
  AND kd_desc='普通宽带';`}</pre>
              <b>已生成可审计SQL</b>
            </div>
          </div>
        </div>
        <div className="hero-stats" aria-label="预期成效">
          <Stat label="SQL 初稿效率" value="50%+" sub="从小时级到分钟级" />
          <Stat label="需求澄清时间" value="30%+" sub="自动收口关键条件" />
          <Stat label="新人上手周期" value="缩短" sub="沉淀熟手经验" />
          <Stat label="口径偏差" value="减少" sub="统一规则和审计" />
        </div>
      </section>

      <section className="section dark-band" id="pain">
        <div className="section-head">
          <span>01</span>
          <div>
            <h2>项目痛点：“三难一重”</h2>
            <p>数据需求增长快，传统人工取数模式难以稳定支撑业务敏捷决策。</p>
          </div>
        </div>
        <div className="pain-grid">
          {painPoints.map((item) => (
            <article className="pain-card" key={item.label}>
              <small>{item.value}</small>
              <h3>{item.label}</h3>
              <p>{item.detail}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="section" id="flow">
        <div className="section-head">
          <span>02</span>
          <div>
            <h2>智能生成流程：七步闭环</h2>
            <p>让 AI 按支撑人员真实取数逻辑完成从需求理解到 SQL 审计的全过程辅助。</p>
          </div>
        </div>
        <div className="flow-line">
          {flowSteps.map(([num, title, desc]) => (
            <article className="flow-step" key={num}>
              <b>{num}</b>
              <h3>{title}</h3>
              <p>{desc}</p>
            </article>
          ))}
        </div>
        <div className="architecture">
          <div>
            <span>AI技能流程</span>
            <strong>需求拆解与分步确认</strong>
          </div>
          <div>
            <span>业务知识库</span>
            <strong>表路由、指标口径、字段补表</strong>
          </div>
          <div>
            <span>SQL规则体系</span>
            <strong>生成规范、风险提示、自检机制</strong>
          </div>
        </div>
      </section>

      <section className="section" id="knowledge">
        <div className="section-head">
          <span>03</span>
          <div>
            <h2>知识库资产：把经验变成规则</h2>
            <p>真实技能资产围绕表索引、指标口径、字段补表、SQL 审计和验证案例组织。</p>
          </div>
        </div>
        <div className="asset-grid">
          {knowledgeAssets.map(([name, metric, desc]) => (
            <article className="asset-card" key={name}>
              <span>{name}</span>
              <strong>{metric}</strong>
              <p>{desc}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="section case-section" id="case">
        <div className="section-head">
          <span>04</span>
          <div>
            <h2>真实示例：主宽入网量（按维汇总）</h2>
            <p>来自仓库真实 SQL 输出，展示自然语言需求如何被收口为可审计 Hive SQL。</p>
          </div>
        </div>

        <div className="case-grid">
          <aside className="case-brief">
            <span>业务需求</span>
            <h3>202605 主宽入网量按维汇总</h3>
            <dl>
              <div>
                <dt>主表</dt>
                <dd>069 全业务资料表日表</dd>
              </div>
              <div>
                <dt>口径</dt>
                <dd>M-BASIC-BB-001 主宽入网数</dd>
              </div>
              <div>
                <dt>输出维度</dt>
                <dd>分局、营服、揽装人、装机地址、协销人、网格单元</dd>
              </div>
            </dl>
          </aside>

          <section className="code-console">
            <div className="console-head">
              <div className="console-dots">
                <span />
                <span />
                <span />
              </div>
              <div className="case-tabs" role="tablist" aria-label="案例信息">
                {Object.entries({ sql: "SQL", audit: "审计", risk: "自检" }).map(([key, label]) => (
                  <button
                    className={caseMode === key ? "active" : ""}
                    key={key}
                    onClick={() => setCaseMode(key)}
                    role="tab"
                    aria-selected={caseMode === key}
                  >
                    {label}
                  </button>
                ))}
              </div>
              <button className="copy-btn" onClick={handleCopySql}>
                {copied ? "已复制" : "复制SQL"}
              </button>
            </div>
            <h3>{casePanels[caseMode].title}</h3>
            <pre>{casePanels[caseMode].body}</pre>
          </section>
        </div>

        <div className="lineage-grid">
          {["079 地址维表 → 装机地址", "042 号码协销表 → 协销人", "115 员工信息表 → 组织ID", "018 机构维表 → 机构名称"].map((item) => (
            <div key={item}>{item}</div>
          ))}
        </div>
      </section>

      <section className="section" id="apps">
        <div className="section-head">
          <span>05</span>
          <div>
            <h2>应用扩展：连接业务全场景</h2>
            <p>能力底座先行，先在内部支撑场景验证，再开放为统一的自然语言取数组件。</p>
          </div>
        </div>
        <div className="app-orbit">
          <div className="orbit-lines" aria-hidden="true">
            <i />
            <i />
            <i />
          </div>
          <div className="hub-core">
            <div className="hub-icon">
              <BrainCircuit aria-hidden="true" size={42} strokeWidth={1.8} />
            </div>
            <span>NL2SQL</span>
            <strong>AI自然语言取数能力底座</strong>
            <small>统一能力服务 · 统一口径规则 · 统一审计输出</small>
          </div>
          {appScenarios.map(({ title, desc, icon: Icon, position }) => (
            <article className={`app-node ${position}`} key={title}>
              <div className="app-icon">
                <Icon aria-hidden="true" size={30} strokeWidth={1.8} />
              </div>
              <span>应用入口</span>
              <h3>{title}</h3>
              <p>{desc}</p>
            </article>
          ))}
          <div className="service-caption">
            <Network aria-hidden="true" size={18} />
            <span>通过统一 API / 技能服务接入多类业务入口</span>
          </div>
        </div>
      </section>

      <section className="section value-section" id="value">
        <div className="section-head">
          <span>06</span>
          <div>
            <h2>价值成效：赋能数据生产力</h2>
            <p>从人工经验取数走向“知识库 + AI 协同驱动”的标准化支撑模式。</p>
          </div>
        </div>
        <div className="value-grid">
          {valueCards.map(([title, value, desc]) => (
            <article className="value-card" key={title}>
              <span>{title}</span>
              <strong>{value}</strong>
              <p>{desc}</p>
            </article>
          ))}
        </div>
        <div className="vision">
          <strong>我们的愿景</strong>
          <p>让业务用自然语言即可获取可信数据，让数据真正服务业务，让决策更智能、更可靠、更高效。</p>
        </div>
      </section>
    </main>
  );
}
