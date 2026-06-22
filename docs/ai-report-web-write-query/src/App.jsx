import {
  ArrowRight,
  CheckCircle2,
  Database,
  FileCheck2,
  FileCode2,
  FolderTree,
  GitBranch,
  MessageSquare,
  ShieldCheck,
  Sparkles,
} from "lucide-react";
import { FlowCaseMatrix } from "./components/FlowCaseMatrix.jsx";
import { caseAge65Demo } from "./data/caseAge65Demo.js";

const navSections = [
  { id: "hero", label: "封面" },
  { id: "assets", label: "目录" },
  { id: "flow", label: "流程" },
  { id: "case", label: "案例" },
  { id: "plan", label: "交付" },
  { id: "summary", label: "总结" },
];

const assetIconMap = {
  entry: FileCode2,
  metric: CheckCircle2,
  table: Database,
  route: GitBranch,
  rule: ShieldCheck,
  case: FileCheck2,
};

/**
 * @param {{ label: string, title: string, desc?: string, inverse?: boolean }} props
 */
function SectionHeader({ label, title, desc, inverse = false }) {
  return (
    <div className="text-center mb-12 md:mb-16">
      <span
        className={
          inverse
            ? "text-brand-400 font-semibold tracking-wider text-sm uppercase"
            : "section-label"
        }
      >
        {label}
      </span>
      <h2
        className={`text-3xl md:text-4xl font-bold mt-2 mb-4 ${
          inverse ? "text-white" : "text-slate-800"
        }`}
      >
        {title}
      </h2>
      {desc ? (
        <p
          className={`text-lg max-w-3xl mx-auto ${
            inverse ? "text-slate-300" : "text-slate-600"
          }`}
        >
          {desc}
        </p>
      ) : null}
      <div className="section-divider" />
    </div>
  );
}

function AssetDirectory() {
  return (
    <section id="assets" className="py-20 md:py-24 bg-white">
      <div className="container mx-auto px-6">
        <div className="max-w-6xl mx-auto">
          <SectionHeader
            label="Asset Directory"
            title="技能目录结构：把支撑人员经验沉淀成可调用资产"
            desc="这里不是单纯的数据字典，而是把指标口径、高频维度、表文档、路由、补表、审计规则和案例经验放进同一套取数流程。"
          />

          <div className="grid gap-8 lg:grid-cols-[0.9fr_1.1fr]">
            <div className="rounded-2xl border border-slate-200 bg-slate-950 p-6 text-white shadow-sm">
              <div className="mb-5 flex items-center gap-3">
                <FolderTree className="text-brand-400" size={24} />
                <div>
                  <p className="text-xs font-bold uppercase tracking-wider text-brand-300">
                    write-query
                  </p>
                  <h3 className="text-xl font-black">技能资产目录</h3>
                </div>
              </div>
              <div className="relative">
                <pre className="overflow-x-auto rounded-xl border border-slate-800 bg-slate-900 p-5 text-sm leading-7 text-slate-200">
{`.agents/skills/write-query/
├── SKILL.md
└── references/
    ├── METRIC_INDEX.md
    ├── metrics/
    │   ├── 基本面/
    │   │   ├── M-BASIC-BB-001_主宽入网数.md
    │   │   ├── M-BASIC-BB-002_主宽入网积分.md
    │   │   └── M-BASIC-MV-006_移动月入网.md
    │   ├── 战新/
    │   │   └── M-NEW-SMB-001_量子密话月入网.md
    │   └── 专题/
    │       ├── M-TOPIC-BB-001_宽带T+n有效率.md
    │       └── M-TOPIC-PTS-001_净增积分.md
    ├── TABLE_INDEX.md
    ├── tables/
    ├── ROUTING.md
    ├── FIELD_BACKFILL.md
    ├── RULES.md
    └── verified-cases/`}
                </pre>
                <svg
                  className="pointer-events-none absolute inset-0 hidden h-full w-full sm:block"
                  viewBox="0 0 100 100"
                  preserveAspectRatio="none"
                  aria-hidden="true"
                >
                  <defs>
                    <marker
                      id="metric-dict-arrow"
                      markerWidth="6"
                      markerHeight="6"
                      refX="5"
                      refY="3"
                      orient="auto"
                    >
                      <polygon points="0 0, 6 3, 0 6" fill="#fb7185" />
                    </marker>
                  </defs>
                  <path
                    d="M 58 32 C 64 27, 68 24, 72 23"
                    stroke="#f43f5e"
                    strokeWidth="0.9"
                    fill="none"
                    strokeDasharray="1.6 1.1"
                    markerEnd="url(#metric-dict-arrow)"
                  />
                </svg>
                <div className="absolute right-5 top-[3.85rem] hidden rounded-2xl border-2 border-brand-300 bg-white/95 px-6 py-3 text-base font-black text-brand-700 shadow-xl shadow-brand-950/20 sm:block">
                  数据字典
                </div>
              </div>
              <div className="mt-5 rounded-xl border border-brand-500/30 bg-brand-500/10 p-4 text-sm leading-relaxed text-brand-100">
                底层技能名保留为 write-query，页面对外表达为“自然语言取数能力建设”。
              </div>
            </div>

            <div className="grid gap-4 sm:grid-cols-2">
              {caseAge65Demo.assetDirectory.map((asset) => {
                const Icon = assetIconMap[asset.kind] || FileCode2;

                return (
                  <article
                    key={asset.name}
                    className="rounded-2xl border border-slate-200 bg-slate-50 p-5 hover-lift"
                  >
                    <div className="mb-3 flex items-center gap-3">
                      <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-brand-50 text-brand-600">
                        <Icon size={20} strokeWidth={1.8} />
                      </div>
                      <code className="text-sm font-black text-brand-700">
                        {asset.name}
                      </code>
                    </div>
                    <h3 className="mb-2 font-bold text-slate-900">
                      {asset.title}
                    </h3>
                    <p className="text-sm leading-relaxed text-slate-600">
                      {asset.desc}
                    </p>
                  </article>
                );
              })}
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

function GeneralWorkflow() {
  return (
    <section id="flow" className="py-20 md:py-24 bg-slate-50">
      <div className="container mx-auto px-6">
        <div className="max-w-6xl mx-auto">
          <SectionHeader
            label="General Workflow"
            title="通用取数流程：先按经验判断，再生成 SQL"
            desc="自然语言需求进入后，AI 不是直接写 SQL，而是按支撑人员的取数路径逐步完成识别、路由、补表、确认和自检。"
          />

          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
            {caseAge65Demo.generalFlow.map((step, index) => (
              <article
                key={step.title}
                className="relative rounded-2xl border border-slate-200 bg-white p-6 shadow-sm hover-lift"
              >
                <span className="absolute right-5 top-5 text-4xl font-black text-brand-100">
                  {String(index + 1).padStart(2, "0")}
                </span>
                <code className="text-xs font-bold text-brand-600">
                  {step.source}
                </code>
                <h3 className="mt-3 mb-2 pr-12 text-lg font-black text-slate-900">
                  {step.title}
                </h3>
                <p className="text-sm leading-relaxed text-slate-600">
                  {step.desc}
                </p>
              </article>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}

function CaseIntro() {
  return (
    <section id="case" className="py-20 md:py-24 bg-white">
      <div className="container mx-auto px-6">
        <div className="max-w-6xl mx-auto">
          <SectionHeader
            label="Real Case"
            title="真实案例演示：65 岁以上机主近三个月订单"
            desc="用真实对话记录展示：业务口语如何经过需求澄清、方案确认、资产调用、SQL 生成和自检交付。"
          />

          <div className="mb-8 rounded-2xl border border-slate-200 bg-slate-50 p-6 shadow-sm">
            <div className="flex items-start gap-4">
              <div className="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-full bg-white text-brand-600">
                <MessageSquare size={20} />
              </div>
              <div>
                <p className="mb-2 text-xs font-semibold uppercase tracking-wider text-slate-400">
                  用户原话
                </p>
                <p className="text-lg font-bold leading-relaxed text-slate-900 md:text-xl">
                  「{caseAge65Demo.userQuery}」
                </p>
              </div>
            </div>
          </div>

          <FlowCaseMatrix rows={caseAge65Demo.matrixRows} />
        </div>
      </div>
    </section>
  );
}

function DeliverySection() {
  return (
    <section id="plan" className="py-20 md:py-24 bg-slate-800">
      <div className="container mx-auto px-6">
        <div className="max-w-5xl mx-auto">
          <SectionHeader
            label="SQL Delivery"
            title="方案确认与 SQL 交付"
            desc="先把主表、补表、时间字段、年龄口径和订单范围一次说清，再输出关键 SQL 步骤和自检 SQL。"
            inverse
          />

          <div className="overflow-x-auto rounded-2xl border border-slate-700">
            <table className="w-full text-left">
              <thead>
                <tr className="bg-slate-900 text-sm text-slate-300">
                  <th className="w-32 px-6 py-4 font-semibold">项</th>
                  <th className="px-6 py-4 font-semibold">口径</th>
                </tr>
              </thead>
              <tbody>
                {caseAge65Demo.planRows.map((row, i) => (
                  <tr
                    key={row.item}
                    className={
                      i % 2 === 0
                        ? "bg-slate-900/50 text-slate-200"
                        : "bg-slate-900 text-slate-200"
                    }
                  >
                    <td className="whitespace-nowrap px-6 py-4 font-bold text-brand-400">
                      {row.item}
                    </td>
                    <td className="px-6 py-4 text-sm leading-relaxed">
                      {row.value}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <div className="mt-12 grid gap-6 md:grid-cols-3">
            {caseAge65Demo.sqlSteps.map((s) => (
              <article
                key={s.step}
                className="rounded-2xl border border-slate-700 bg-slate-900 p-6 hover-lift"
              >
                <div className="mb-4 flex h-8 w-8 items-center justify-center rounded-full bg-brand-600 text-sm font-bold text-white">
                  {s.step}
                </div>
                <code className="mb-2 block text-xs font-mono text-brand-400">
                  {s.table}
                </code>
                <h3 className="mb-2 font-bold text-white">{s.title}</h3>
                <p className="text-sm text-slate-400">{s.desc}</p>
              </article>
            ))}
          </div>

          <div className="mt-10 mac-window hover-lift">
            <div className="mac-header">
              <div className="mac-dot" style={{ background: "#ff5f56" }} />
              <div className="mac-dot" style={{ background: "#ffbd2e" }} />
              <div className="mac-dot" style={{ background: "#27c93f" }} />
              <span className="ml-2 text-xs text-slate-400">
                Hive SQL · 关键步骤摘要
              </span>
            </div>
            <pre className="mac-body">{caseAge65Demo.sqlSnippet}</pre>
          </div>

          <div className="mt-8 rounded-2xl border border-brand-500/30 bg-brand-500/10 p-6">
            <div className="mb-4 flex items-center gap-3">
              <ShieldCheck className="text-brand-400" size={22} />
              <h3 className="text-lg font-black text-white">
                交付附带自检 SQL
              </h3>
            </div>
            <ul className="space-y-3">
              {caseAge65Demo.selfCheck.map((sql) => (
                <li
                  key={sql}
                  className="flex items-start gap-3 text-sm text-slate-200"
                >
                  <ArrowRight
                    size={16}
                    className="mt-1 flex-shrink-0 text-brand-400"
                  />
                  <code className="flex-1 rounded-lg border border-slate-700 bg-slate-900 px-3 py-1.5 font-mono">
                    {sql}
                  </code>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </div>
    </section>
  );
}

function SummarySection() {
  return (
    <section id="summary" className="py-20 md:py-24 bg-white">
      <div className="container mx-auto px-6">
        <div className="mx-auto max-w-4xl text-center">
          <span className="section-label">Summary</span>
          <h2 className="mt-2 mb-6 text-3xl font-bold text-slate-800 md:text-4xl">
            阶段总结
          </h2>
          <div className="rounded-2xl border border-brand-200 bg-brand-50 p-8 text-left shadow-sm">
            <p className="text-lg font-semibold leading-relaxed text-slate-800">
              {caseAge65Demo.summary}
            </p>
          </div>
        </div>
      </div>
    </section>
  );
}

export function App() {
  return (
    <div className="bg-slate-50 text-slate-800 font-sans antialiased">
      <nav
        className="fixed right-4 top-1/2 z-40 hidden -translate-y-1/2 flex-col gap-3 md:right-6 lg:flex"
        aria-label="页面章节导航"
      >
        {navSections.map((s, i) => (
          <a
            key={s.id}
            href={`#${s.id}`}
            title={s.label}
            className={`h-3 w-3 rounded-full transition-colors ${
              i === 0
                ? "scale-125 bg-brand-600"
                : "bg-slate-300 hover:bg-brand-600"
            }`}
          />
        ))}
      </nav>

      <section
        id="hero"
        className="relative flex min-h-screen items-center justify-center overflow-hidden"
      >
        <div className="absolute inset-0 bg-gradient-to-br from-slate-50 via-white to-brand-50 opacity-70" />
        <div className="absolute left-10 top-20 h-72 w-72 rounded-full bg-brand-200 opacity-20 mix-blend-multiply blur-3xl animate-pulse-slow" />
        <div
          className="absolute bottom-20 right-10 h-96 w-96 rounded-full bg-brand-300 opacity-20 mix-blend-multiply blur-3xl animate-pulse-slow"
          style={{ animationDelay: "1s" }}
        />

        <div className="container relative z-10 mx-auto px-6 py-20 text-center">
          <div className="mb-8 inline-flex animate-fade-in items-center gap-2 rounded-full border border-brand-200 bg-brand-50 px-4 py-2 text-sm font-medium text-brand-700">
            <Sparkles size={16} aria-hidden="true" />
            <span>CDAP 业务数据 · 自然语言取数</span>
          </div>
          <h1 className="mb-6 animate-slide-up text-4xl font-bold tracking-tight md:text-6xl lg:text-7xl">
            <span className="gradient-text">自然语言取数能力建设</span>
          </h1>
          <p
            className="mx-auto mb-5 max-w-3xl animate-slide-up text-xl font-bold text-slate-700 md:text-2xl"
            style={{ animationDelay: "0.15s" }}
          >
            打造面向 CDAP 业务数据的自然语言取数能力
          </p>
          <p
            className="mx-auto mb-10 max-w-3xl animate-slide-up text-lg font-medium text-slate-500 md:text-xl"
            style={{ animationDelay: "0.25s" }}
          >
            让业务人员通过自然语言描述需求，自动生成可执行、可校验的取数 SQL。
          </p>
          <div
            className="flex animate-slide-up flex-wrap justify-center gap-4"
            style={{ animationDelay: "0.4s" }}
          >
            <a
              href="#assets"
              className="rounded-xl bg-brand-600 px-8 py-4 font-semibold text-white transition-all hover:bg-brand-700 hover:shadow-lg hover:shadow-brand-200"
            >
              查看技能资产
            </a>
            <a
              href="#case"
              className="rounded-xl border-2 border-brand-200 bg-white px-8 py-4 font-semibold text-brand-600 transition-all hover:border-brand-400 hover:bg-brand-50"
            >
              看真实案例
            </a>
          </div>
        </div>
      </section>

      <AssetDirectory />
      <GeneralWorkflow />
      <CaseIntro />
      <DeliverySection />
      <SummarySection />

      <footer className="bg-slate-900 py-12 text-center">
        <div className="container mx-auto px-6">
          <p className="mb-4 text-sm text-slate-400">
            write-query 技能 · CDAP 自然语言取数能力底座
          </p>
          <div className="inline-flex flex-wrap items-center justify-center gap-2 rounded-full bg-slate-800 px-6 py-3 text-sm font-bold text-white md:gap-4">
            <span>懂需求</span>
            <ArrowRight size={14} className="text-slate-500" />
            <span>找对表</span>
            <ArrowRight size={14} className="text-slate-500" />
            <span>补字段</span>
            <ArrowRight size={14} className="text-slate-500" />
            <span>自检</span>
            <ArrowRight size={14} className="text-brand-500" />
            <span className="text-brand-400">交付 SQL</span>
          </div>
        </div>
      </footer>
    </div>
  );
}
