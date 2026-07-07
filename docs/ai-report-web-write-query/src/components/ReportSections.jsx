import { useEffect } from "react";
import {
  ArrowRight,
  BookOpenCheck,
  Boxes,
  CheckCircle2,
  CircleGauge,
  Database,
  FileCheck2,
  FileCode2,
  FileText,
  Folder,
  GitBranch,
  Layers3,
  MessageSquareText,
  RefreshCcw,
  Route,
  SearchCheck,
  ShieldCheck,
  Sparkles,
  Target,
  Users,
} from "lucide-react";
import { reportContent } from "../data/reportContent.js";
import { CaseEvidenceChain } from "./CaseEvidenceChain.jsx";

const valueIcons = [Target, BookOpenCheck, Boxes];
const painIcons = [MessageSquareText, Route, Database, RefreshCcw];
const workflowIcons = [
  MessageSquareText,
  Route,
  SearchCheck,
  Layers3,
  FileCode2,
  ShieldCheck,
];
const assetIcons = [
  Database,
  CircleGauge,
  GitBranch,
  Layers3,
  ShieldCheck,
  SearchCheck,
  FileCheck2,
  BookOpenCheck,
];

const architectureDirectory = [
  { depth: 0, label: ".agents/skills/write-query/", type: "folder", note: "自然语言取数技能包" },
  { depth: 1, label: "SKILL.md", type: "file", note: "入口、路径判断与运行流程" },
  // ===== references/ 组 =====
  { depth: 1, label: "references/", type: "folder", group: "metrics", groupIndex: "1", note: "按需读取的知识资产" },
  { depth: 2, label: "METRIC_INDEX.md", type: "file", group: "metrics", note: "指标口径总入口" },
  { depth: 2, label: "metrics/", type: "folder", group: "metrics", note: "指标体系" },
  { depth: 3, label: "基本面/", type: "folder", group: "metrics", note: "基础指标" },
  { depth: 4, label: "M-BASIC-BB-001 主宽入网数.md", type: "file", group: "metrics" },
  { depth: 4, label: "M-BASIC-BB-002 主宽入网积分.md", type: "file", group: "metrics" },
  { depth: 3, label: "专题/", type: "folder", group: "metrics", note: "专项指标" },
  { depth: 4, label: "M-TOPIC-BB-001 宽带T+n有效率.md", type: "file", group: "metrics" },
  // ===== tables/ 组 =====
  { depth: 1, label: "tables/", type: "folder", group: "tables", groupIndex: "2", note: "表资产索引与文档" },
  { depth: 2, label: "TABLE_INDEX.md", type: "file", group: "tables", note: "表资产索引" },
  { depth: 2, label: "040_全业务号码订单表.md", type: "file", group: "tables", note: "订单类表" },
  { depth: 2, label: "041_优惠订单表.md", type: "file", group: "tables", note: "订单类表" },
  { depth: 2, label: "069_全业务资料表.md", type: "file", group: "tables", note: "客户资料类表" },
  { depth: 2, label: "...", type: "file", group: "tables", note: "更多表文档" },
  // ===== rules/ 组 =====
  { depth: 1, label: "rules/", type: "folder", group: "rules", groupIndex: "3", note: "规则与推理资源" },
  { depth: 2, label: "ROUTING.md", type: "file", group: "rules", note: "主表路由" },
  { depth: 2, label: "FIELD_BACKFILL.md", type: "file", group: "rules", note: "字段补表规则" },
  { depth: 2, label: "RULES.md", type: "file", group: "rules", note: "生成规范与校验规则" },
  // ===== verified-cases/ 组 =====
  { depth: 1, label: "verified-cases/", type: "folder", group: "cases", groupIndex: "4", note: "真实案例沉淀" },
  { depth: 2, label: "001_主宽入网统计.sql", type: "file", group: "cases", note: "主宽入网统计案例" },
  { depth: 2, label: "002_留存分析.sql", type: "file", group: "cases", note: "留存分析案例" },
  { depth: 2, label: "...", type: "file", group: "cases", note: "更多已验证案例" },
];

const summaryCards = [
  {
    group: "metrics",
    title: "指标库",
    desc: "统一指标定义\n91 标准指标",
    badge: "数据字典",
    color: "#a78bfa",
  },
  {
    group: "tables",
    title: "表资产库",
    desc: "核心数据表文档\n100+ 核心表",
    color: "#60a5fa",
  },
  {
    group: "rules",
    title: "规则库",
    desc: "路由 + 补表 + 生成规范\n保障结果准确可靠",
    color: "#4ade80",
  },
  {
    group: "cases",
    title: "案例库",
    desc: "真实取数案例\n持续沉淀与验证",
    color: "#fbbf24",
  },
];

function SectionHeader({ label, title, desc, inverse = false, align = "center" }) {
  const centered = align === "center";
  return (
    <header
      className={`section-heading reveal ${centered ? "section-heading-center" : ""}`}
    >
      <span className={inverse ? "section-label section-label-inverse" : "section-label"}>
        {label}
      </span>
      <h2 className={inverse ? "text-white" : "text-slate-950"}>{title}</h2>
      {desc ? (
        <p className={inverse ? "text-slate-300" : "text-slate-600"}>{desc}</p>
      ) : null}
    </header>
  );
}

function SummaryLine({ children, inverse = false }) {
  return (
    <div className={`summary-line reveal ${inverse ? "summary-line-inverse" : ""}`}>
      <span />
      <strong>{children}</strong>
    </div>
  );
}

export function HeroSection() {
  const { positioning } = reportContent;
  return (
    <section id="hero" className="hero-section">
      <div className="hero-grid" aria-hidden="true" />
      <div className="hero-glow hero-glow-left" aria-hidden="true" />
      <div className="hero-glow hero-glow-right" aria-hidden="true" />

      <div className="report-container hero-content">
        <div className="hero-kicker">
          <Sparkles size={16} />
          CDAP 业务数据 · AI 能力建设
        </div>
        <p className="hero-index">01 / PROJECT POSITIONING</p>
        <h1>{positioning.title}</h1>
        <p className="hero-statement">{positioning.statement}</p>
        <p className="hero-insight">{positioning.insight}</p>

        <div className="hero-values">
          {positioning.values.map((item, index) => {
            const Icon = valueIcons[index];
            return (
              <article key={item.title} className="hero-value-card">
                <Icon size={20} />
                <div>
                  <h3>{item.title}</h3>
                  <p>{item.desc}</p>
                </div>
              </article>
            );
          })}
        </div>
      </div>
    </section>
  );
}

export function PainSection() {
  return (
    <section id="pain" className="report-section bg-white">
      <div className="report-container">
        <SectionHeader
          label="02 / Background"
          title="数据需求持续增长，传统取数高度依赖个人经验"
          desc="业务自然语言与数据库结构之间，仍需要支撑人员完成需求理解、口径转换、选表、字段匹配、SQL 编写和结果检查。"
        />

        <div className="pain-grid">
          {reportContent.painPoints.map((item, index) => {
            const Icon = painIcons[index];
            return (
              <article key={item.number} className="pain-card reveal">
                <div className="pain-card-top">
                  <span>{item.number}</span>
                  <Icon size={23} />
                </div>
                <h3>{item.title}</h3>
                <p>{item.desc}</p>
              </article>
            );
          })}
        </div>

        <div className="mode-shift reveal">
          <div>
            <span className="mode-label">传统方式</span>
            <p>业务描述需求，支撑人员依靠个人经验从零完成 SQL。</p>
          </div>
          <ArrowRight className="mode-arrow" />
          <div className="mode-target">
            <span className="mode-label">技能方式</span>
            <p>AI 按照沉淀的取数经验生成 SQL，支撑人员重点确认和审核。</p>
          </div>
        </div>

        <SummaryLine>
          从“个人经验驱动取数”，逐步转向“知识资产与 AI 协同取数”。
        </SummaryLine>
      </div>
    </section>
  );
}

export function ArchitectureSection() {
  useEffect(() => {
    const calcConnectors = () => {
      const svg = document.querySelector(".directory-connector-svg");
      if (!svg) return;

      const svgRect = svg.getBoundingClientRect();

      summaryCards.forEach((card) => {
        const groupRows = document.querySelectorAll(`.directory-group-${card.group}`);
        const path = svg.querySelector(`.connector-${card.group}`);
        const cardEl = document.querySelector(`.summary-card-${card.group}`);
        if (!groupRows.length || !path || !cardEl) return;

        const firstRow = groupRows[0].getBoundingClientRect();
        const lastRow = groupRows[groupRows.length - 1].getBoundingClientRect();
        const topY = firstRow.top + 3 - svgRect.top;
        const bottomY = lastRow.bottom - 3 - svgRect.top;
        const midY = (firstRow.top + lastRow.bottom) / 2 - svgRect.top;

        cardEl.style.setProperty("--card-top", `${Math.max(8, midY - cardEl.offsetHeight / 2)}px`);

        const cardRect = cardEl.getBoundingClientRect();
        const cardCenterY = cardRect.top + cardRect.height / 2 - svgRect.top;

        const contentRight = Array.from(groupRows).reduce((right, row) => {
          const note = row.querySelector(".directory-note");
          const code = row.querySelector("code");
          const target = note || code;
          if (!target) return right;
          return Math.max(right, target.getBoundingClientRect().right - svgRect.left);
        }, 0);
        const cardLeft = cardRect.left - svgRect.left - 4;

        const bracketLeft = Math.min(cardLeft - 52, contentRight + 22);
        const bracketRight = Math.min(cardLeft - 18, bracketLeft + 46);
        const linkStartY = Math.min(Math.max(cardCenterY, topY + 14), bottomY - 14);

        path.setAttribute(
          "d",
          `M ${bracketLeft} ${topY} H ${bracketRight} V ${bottomY} H ${bracketLeft} M ${bracketRight} ${linkStartY} H ${cardLeft}`
        );
      });
    };

    calcConnectors();
    const timer = setTimeout(calcConnectors, 100);
    window.addEventListener("resize", calcConnectors);
    return () => {
      clearTimeout(timer);
      window.removeEventListener("resize", calcConnectors);
    };
  }, []);

  return (
    <section id="architecture" className="report-section architecture-section">
      <div className="report-container">
        <SectionHeader
          label="03 / Workflow & Architecture"
          title="不是让 AI 直接猜 SQL，而是按真实取数经验逐步生成"
          desc="上层是一套标准化流程，下层是一组能够按需读取、持续维护的业务知识资产。"
          inverse
        />

        <div className="workflow-grid">
          {reportContent.workflow.map((item, index) => {
            const Icon = workflowIcons[index];
            return (
              <article key={item.number} className="workflow-card reveal">
                <div className="workflow-number">{item.number}</div>
                <Icon size={22} />
                <h3>{item.title}</h3>
                <p>{item.desc}</p>
                <code>{item.source}</code>
              </article>
            );
          })}
        </div>

        <div className="architecture-panel reveal">
          <div className="architecture-tree">
            <div className="architecture-window-head">
              <span />
              <span />
              <span />
              <strong>write-query / capability assets</strong>
            </div>
            <div className="architecture-tree-body">
              <div className="architecture-directory" aria-label="write-query 技能资产目录">
                {architectureDirectory.map((item) => (
                  <div
                    key={`${item.depth}-${item.label}`}
                    className={`directory-row directory-depth-${item.depth}${item.group ? ` directory-group-${item.group}` : ""}${item.groupIndex ? " is-group-start" : ""}`}
                  >
                    {item.groupIndex ? <span className="directory-index">{item.groupIndex}</span> : null}
                    <span className="directory-branch" aria-hidden="true" />
                    {item.type === "folder" ? (
                      <Folder className="directory-icon" size={13} aria-hidden="true" />
                    ) : (
                      <FileText className="directory-icon" size={13} aria-hidden="true" />
                    )}
                    <code className={item.type === "folder" ? "is-folder" : ""}>
                      {item.label}
                    </code>
                    {item.note ? <span className="directory-note">{item.note}</span> : null}
                  </div>
                ))}
              </div>

              <svg className="directory-connector-svg" aria-hidden="true">
                {summaryCards.map((card) => (
                  <path
                    key={card.group}
                    className={`connector-line connector-${card.group}`}
                    data-group={card.group}
                    markerEnd={`url(#arrow-${card.group})`}
                  />
                ))}
                <defs>
                  {summaryCards.map((card) => (
                    <marker
                      key={card.group}
                      id={`arrow-${card.group}`}
                      viewBox="0 0 10 10"
                      refX="8"
                      refY="5"
                      markerWidth="5"
                      markerHeight="5"
                      orient="auto-start-reverse"
                    >
                      <path d="M 0 0 L 10 5 L 0 10 z" fill={card.color} opacity="0.72" />
                    </marker>
                  ))}
                </defs>
              </svg>

              <div className="directory-summary-cards" aria-label="资产汇总卡片">
                {summaryCards.map((card) => (
                  <div
                    key={card.group}
                    className={`summary-card summary-card-${card.group}`}
                    style={{ "--card-color": card.color }}
                  >
                    {card.badge ? <span className="summary-card-badge">{card.badge}</span> : null}
                    <strong>{card.title}</strong>
                    <span>{card.desc}</span>
                  </div>
                ))}
              </div>
            </div>
          </div>

          <div className="architecture-side">
            <div className="directory-callout">
              <span>Directory map</span>
              <h3>从目录就能看出技能如何工作</h3>
              <p>
                入口、脚本、表索引、指标口径、补表规则和真实案例分层维护，AI 按任务阶段读取对应资产。
              </p>
            </div>

            <div className="directory-metrics" aria-label="目录资产概览">
              <div>
                <strong>主入口</strong>
                <span>SKILL.md</span>
              </div>
              <div>
                <strong>规则层</strong>
                <span>ROUTING · FIELD_BACKFILL · RULES</span>
              </div>
              <div>
                <strong>知识层</strong>
                <span>tables · metrics · verified-cases</span>
              </div>
            </div>

            <div className="on-demand-panel">
              <span className="section-label section-label-inverse">On-demand loading</span>
              <h3>技能不会一次加载全部资料</h3>
              <p>每个步骤只读取当前决策所需的知识，让上下文更聚焦，也让生成路径更可解释。</p>
              <ol>
                {reportContent.onDemandReads.map((item, index) => (
                  <li key={item}>
                    <span>{String(index + 1).padStart(2, "0")}</span>
                    {item}
                  </li>
                ))}
              </ol>
            </div>
          </div>
        </div>

        <SummaryLine inverse>
          上层是标准化取数流程，下层是支撑流程运行的业务知识资产。
        </SummaryLine>
      </div>
    </section>
  );
}

export function CaseSection() {
  const { caseStudy } = reportContent;
  return (
    <section id="case" className="report-section case-section">
      <div className="report-container">
        <SectionHeader
          label="04 / Real Case"
          title="从一句业务需求，到一套可确认的取数 SQL"
          desc="用“近三个月 65 岁以上机主所有订单”真实案例，验证需求收口、选表补表、风险识别和自检交付的完整路径。"
        />

        <blockquote className="case-query reveal">
          <MessageSquareText size={28} />
          <div>
            <span>用户原始需求</span>
            <p>“{caseStudy.query}”</p>
          </div>
        </blockquote>

        <div className="case-clarification-grid">
          <div className="case-subheading reveal">
            <span>STEP 01</span>
            <h3>只澄清三个会改变 SQL 结果的问题</h3>
          </div>
          <div className="clarification-list">
            {caseStudy.clarifications.map((item, index) => (
              <article key={item.question} className="clarification-card reveal">
                <span>{String(index + 1).padStart(2, "0")}</span>
                <div>
                  <h4>{item.question}</h4>
                  <p>{item.answer}</p>
                </div>
              </article>
            ))}
          </div>
        </div>

        <div className="case-solution">
          <div className="case-subheading reveal">
            <span>STEP 02</span>
            <h3>形成可确认的取数方案</h3>
          </div>
          <div className="solution-grid">
            {caseStudy.solution.map((item) => (
              <article key={item.label} className="solution-card reveal">
                <span>{item.label}</span>
                <h4>{item.value}</h4>
                <p>{item.detail}</p>
              </article>
            ))}
          </div>
        </div>

        <div className="risk-panel reveal">
          <div className="risk-heading">
            <ShieldCheck size={27} />
            <div>
              <span>STEP 03</span>
              <h3>AI 主动识别三项风险</h3>
            </div>
          </div>
          <div className="risk-grid">
            {caseStudy.risks.map((item, index) => (
              <article key={item.title}>
                <span>0{index + 1}</span>
                <h4>{item.title}</h4>
                <p>{item.desc}</p>
              </article>
            ))}
          </div>
        </div>

        <div className="delivery-panel reveal">
          <div className="delivery-copy">
            <span className="section-label">Step 04 / Deliverable</span>
            <h3>生成完整 SQL 与自检方案</h3>
            <p>
              四段 CTAS 将数据准备、去重、年龄快照和最终输出拆开，七类自检让结果能够被快速验收。
            </p>
            <div className="ctas-list">
              {caseStudy.ctas.map((item, index) => (
                <div key={item}>
                  <span>{index + 1}</span>
                  {item}
                </div>
              ))}
            </div>
          </div>
          <div className="check-list">
            <strong>7 类自检</strong>
            {caseStudy.checks.map((item) => (
              <div key={item}>
                <CheckCircle2 size={16} />
                {item}
              </div>
            ))}
          </div>
        </div>

        <div className="delivery-stats">
          {caseStudy.deliveryStats.map(([value, label]) => (
            <div key={label} className="reveal">
              <strong>{value}</strong>
              <span>{label}</span>
            </div>
          ))}
        </div>
        <p className="delivery-summary reveal">{caseStudy.deliverySummary}</p>

        <div className="evidence-heading reveal">
          <span className="section-label">Evidence chain</span>
          <h3>三段真实对话，完整保留决策过程</h3>
          <p>截图不是装饰，而是证明技能如何逐步收口需求、确认方案并完成交付。</p>
        </div>
        <CaseEvidenceChain />

        <SummaryLine>
          AI 不只是输出 SQL，更完成需求收口、选表、口径、补表、风险识别和结果自检。
        </SummaryLine>
      </div>
    </section>
  );
}

export function AssetsSection() {
  return (
    <section id="assets" className="report-section bg-white">
      <div className="report-container">
        <SectionHeader
          label="05 / Capability Assets"
          title="将个人经验沉淀为可持续积累的 AI 技能资产"
          desc="自然语言取数的准确性，不只依赖大模型，更依赖模型背后能够被按需调用、持续完善的业务知识。"
        />

        <div className="asset-grid">
          {reportContent.assets.map(({ title, desc, count, unit, sub }, index) => {
            const Icon = assetIcons[index];
            return (
              <article key={title} className="asset-card reveal">
                <Icon size={21} />
                <div className="asset-count">{count}</div>
                <span className="asset-unit">
                  {unit}
                  {sub ? <sub>{sub}</sub> : null}
                </span>
                <h3>{title}</h3>
                <p>{desc}</p>
              </article>
            );
          })}
        </div>

        <div className="capability-panel reveal">
          <div>
            <span className="section-label section-label-inverse">From files to capability</span>
            <h3>资产不仅回答“有什么”，更要回答“怎么做”</h3>
            <p>
              标准化数据字典提供指标口径和维度字段基础，技能进一步融合主表路由、字段补表、SQL 规则、码值字典与真实案例。
            </p>
          </div>
          <div className="capability-questions">
            {reportContent.capabilityQuestions.map((item) => (
              <div key={item}>
                <ArrowRight size={15} />
                {item}
              </div>
            ))}
          </div>
        </div>

        <div className="learning-loop reveal">
          {[
            "真实取数需求",
            "发现新规则或风险",
            "通过 SQL 结果验证",
            "回填知识资产",
            "后续需求直接复用",
          ].map((item, index, all) => (
            <div key={item} className="learning-step">
              <span>{String(index + 1).padStart(2, "0")}</span>
              <strong>{item}</strong>
              {index < all.length - 1 ? <ArrowRight size={18} /> : null}
            </div>
          ))}
        </div>

        <SummaryLine>
          每完成一次真实需求，不只是生成一条 SQL，也是在持续丰富自然语言取数能力底座。
        </SummaryLine>
      </div>
    </section>
  );
}

export function RoadmapSection() {
  return (
    <section id="roadmap" className="report-section roadmap-section">
      <div className="report-container">
        <SectionHeader
          label="06 / Next Step"
          title="持续丰富能力底座，提升生成准确性和场景覆盖"
          desc="先在真实使用中验证，再把新的经验回填到知识资产，形成可度量、可持续的迭代机制。"
          inverse
        />

        <div className="roadmap-grid">
          {reportContent.roadmap.map((item) => (
            <article key={item.number} className="roadmap-card reveal">
              <span>{item.number}</span>
              <h3>{item.title}</h3>
              <p>{item.desc}</p>
            </article>
          ))}
        </div>

        <div className="roadmap-detail-grid">
          <div className="metric-panel reveal">
            <span className="section-label section-label-inverse">Measurement</span>
            <h3>建议重点跟踪四类指标</h3>
            <div>
              {reportContent.metrics.map(([title, desc]) => (
                <article key={title}>
                  <strong>{title}</strong>
                  <p>{desc}</p>
                </article>
              ))}
            </div>
          </div>

          <div className="feedback-panel reveal">
            <span className="section-label">Knowledge feedback</span>
            <h3>统一知识回填规则</h3>
            <div className="feedback-table">
              {reportContent.feedbackMap.map(([source, target]) => (
                <div key={source}>
                  <span>{source}</span>
                  <ArrowRight size={15} />
                  <strong>{target}</strong>
                </div>
              ))}
            </div>
          </div>
        </div>

        <div className="stage-grid">
          {reportContent.stages.map(([phase, title, desc], index) => (
            <article key={phase} className="stage-card reveal">
              <span>{phase}</span>
              <strong>{title}</strong>
              <p>{desc}</p>
              <div className="stage-progress">
                {[0, 1, 2].map((step) => (
                  <i key={step} className={step <= index ? "is-active" : ""} />
                ))}
              </div>
            </article>
          ))}
        </div>

        <div className="closing-statement reveal">
          <Users size={28} />
          <p>
            目前，自然语言生成 SQL 能力已封装为可运行的 Agent Skill，形成了能力雏形，并已在真实取数场景中开展试用。该 Skill
            吸收《标准化数据字典》项目沉淀的指标口径与维度字段成果，融合主表路由、字段补表、SQL
            生成与校验规则及验证案例。下一步将坚持边使用、边验证、边沉淀，持续提升生成准确性、稳定性和场景覆盖能力。
          </p>
        </div>
      </div>
    </section>
  );
}
