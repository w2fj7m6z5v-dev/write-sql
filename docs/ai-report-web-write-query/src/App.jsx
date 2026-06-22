import {
  ArrowRight,
  BookOpen,
  CheckCircle2,
  MessageSquare,
  ShieldCheck,
  Sparkles,
} from "lucide-react";
import { AnnotatedCaseShot } from "./components/AnnotatedCaseShot.jsx";
import { FlowCaseMatrix } from "./components/FlowCaseMatrix.jsx";
import { caseAge65Demo } from "./data/caseAge65Demo.js";

const navSections = [
  { id: "hero", label: "封面" },
  { id: "what", label: "能力" },
  { id: "case", label: "案例" },
  { id: "annotated", label: "标注图" },
  { id: "matrix", label: "走查" },
  { id: "plan", label: "方案" },
  { id: "knowledge", label: "知识库" },
  { id: "flow", label: "流程" },
];

/**
 * @param {{ label: string, title: string, desc?: string }} props
 */
function SectionHeader({ label, title, desc }) {
  return (
    <div className="text-center mb-12 md:mb-16">
      <span className="section-label">{label}</span>
      <h2 className="text-3xl md:text-4xl font-bold text-slate-800 mt-2 mb-4">
        {title}
      </h2>
      {desc ? (
        <p className="text-slate-600 text-lg max-w-2xl mx-auto">{desc}</p>
      ) : null}
      <div className="section-divider" />
    </div>
  );
}

export function App() {
  return (
    <div className="bg-slate-50 text-slate-800 font-sans antialiased">
      {/* 右侧锚点导航 */}
      <nav
        className="fixed right-4 md:right-6 top-1/2 -translate-y-1/2 z-40 hidden lg:flex flex-col gap-3"
        aria-label="页面章节导航"
      >
        {navSections.map((s, i) => (
          <a
            key={s.id}
            href={`#${s.id}`}
            title={s.label}
            className={`w-3 h-3 rounded-full transition-colors ${
              i === 0
                ? "bg-brand-600 scale-125"
                : "bg-slate-300 hover:bg-brand-600"
            }`}
          />
        ))}
      </nav>

      {/* Hero */}
      <section
        id="hero"
        className="min-h-screen flex items-center justify-center relative overflow-hidden"
      >
        <div className="absolute inset-0 bg-gradient-to-br from-slate-50 via-white to-brand-50 opacity-60" />
        <div className="absolute top-20 left-10 w-72 h-72 bg-brand-200 rounded-full mix-blend-multiply filter blur-3xl opacity-20 animate-pulse-slow" />
        <div
          className="absolute bottom-20 right-10 w-96 h-96 bg-brand-300 rounded-full mix-blend-multiply filter blur-3xl opacity-20 animate-pulse-slow"
          style={{ animationDelay: "1s" }}
        />

        <div className="container mx-auto px-6 relative z-10 text-center py-20">
          <div className="inline-flex items-center gap-2 px-4 py-2 bg-brand-50 border border-brand-200 rounded-full text-brand-700 text-sm font-medium mb-8 animate-fade-in">
            <Sparkles size={16} aria-hidden="true" />
            <span>CDAP 自然语言取数 · write-query 技能演示</span>
          </div>
          <h1 className="text-4xl md:text-6xl lg:text-7xl font-bold mb-6 tracking-tight animate-slide-up">
            <span className="gradient-text">write-query</span>
            <br />
            <span className="text-slate-800 text-3xl md:text-5xl mt-4 block font-bold">
              让 AI 从「会写 SQL」到「按口径写对 SQL」
            </span>
          </h1>
          <p
            className="text-lg md:text-xl text-slate-500 mb-10 max-w-3xl mx-auto animate-slide-up font-medium"
            style={{ animationDelay: "0.2s" }}
          >
            把支撑人员的主表路由、指标口径、字段补表和 SQL 审计经验，
            封装成一句话就能调用的标准化取数能力
          </p>
          <div
            className="flex flex-wrap justify-center gap-4 animate-slide-up"
            style={{ animationDelay: "0.4s" }}
          >
            <a
              href="#case"
              className="px-8 py-4 bg-brand-600 text-white rounded-xl font-semibold hover:bg-brand-700 transition-all hover:shadow-lg hover:shadow-brand-200"
            >
              看实战案例
            </a>
            <a
              href="#annotated"
              className="px-8 py-4 bg-white text-brand-600 border-2 border-brand-200 rounded-xl font-semibold hover:border-brand-400 hover:bg-brand-50 transition-all"
            >
              标注截图演示
            </a>
          </div>
        </div>
      </section>

      {/* 能力对比 */}
      <section id="what" className="py-20 md:py-24 bg-white">
        <div className="container mx-auto px-6">
          <div className="max-w-5xl mx-auto">
            <SectionHeader
              label="Concept"
              title="为什么需要 write-query 技能？"
              desc="Skill = 取数场景的「专业工具包」"
            />
            <div className="grid md:grid-cols-2 gap-8">
              <div className="bg-slate-50 p-8 rounded-2xl border border-slate-200 hover-lift">
                <div className="w-14 h-14 bg-slate-200 rounded-xl flex items-center justify-center mb-6 text-slate-500">
                  <MessageSquare size={28} strokeWidth={1.8} />
                </div>
                <h3 className="text-xl font-bold text-slate-800 mb-3">
                  没有技能
                </h3>
                <p className="text-slate-600 leading-relaxed mb-4">
                  业务一句「老年客户近三个月订单」，支撑人员需自行判断主表、年龄口径、订单池合并方式，反复沟通易出错。
                </p>
                <div className="bg-white p-4 rounded-lg border border-slate-200 text-sm text-slate-500">
                  每次从零选表、猜字段、手写 SQL，质量依赖个人经验。
                </div>
              </div>
              <div className="bg-brand-50 p-8 rounded-2xl border border-brand-200 hover-lift relative overflow-hidden">
                <div className="w-14 h-14 bg-brand-200 rounded-xl flex items-center justify-center mb-6 text-brand-600">
                  <CheckCircle2 size={28} strokeWidth={1.8} />
                </div>
                <h3 className="text-xl font-bold text-slate-800 mb-3">
                  有 write-query 技能
                </h3>
                <p className="text-slate-600 leading-relaxed mb-4">
                  同一句话，AI 按 SKILL → ROUTING → 表文档 → RULES 流程走，先方案确认再出 SQL。
                </p>
                <div className="bg-white p-4 rounded-lg border border-brand-200 text-brand-700 font-bold shadow-sm text-sm">
                  「近三个月，机主年龄≥65岁的所有订单」→ 可执行多步 CTAS
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* 案例需求 */}
      <section id="case" className="py-20 md:py-24 bg-slate-50">
        <div className="container mx-auto px-6">
          <div className="max-w-4xl mx-auto">
            <SectionHeader
              label="Live Case"
              title="实战案例：老年客群订单明细"
              desc="真实业务对话，展示从自然语言到可交付 SQL 的完整链路"
            />
            <div className="bg-white rounded-2xl border border-slate-200 shadow-sm p-8 hover-lift">
              <div className="flex items-start gap-4">
                <div className="w-10 h-10 rounded-full bg-slate-100 flex items-center justify-center flex-shrink-0 text-slate-500">
                  <MessageSquare size={20} />
                </div>
                <div>
                  <p className="text-xs font-semibold text-slate-400 uppercase tracking-wider mb-2">
                    用户原话
                  </p>
                  <p className="text-lg md:text-xl text-slate-800 font-medium leading-relaxed">
                    「{caseAge65Demo.userQuery}」
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* 静态标注截图 */}
      <section id="annotated" className="py-20 md:py-24 bg-white">
        <div className="container mx-auto px-6">
          <div className="max-w-6xl mx-auto">
            <SectionHeader
              label="Annotated Screenshot"
              title="一屏看懂：技能如何跑起来"
              desc="基于 Cursor 真实对话截图，箭头标注五个关键环节"
            />
            <AnnotatedCaseShot annotations={caseAge65Demo.annotations} />
          </div>
        </div>
      </section>

      {/* 案例推进台：真实流程 + 调用资产 */}
      <section id="matrix" className="py-20 md:py-24 bg-slate-50">
        <div className="container mx-auto px-6">
          <div className="max-w-6xl mx-auto">
            <SectionHeader
              label="Case Walkthrough"
              title="真实案例截图：标出背后调用了哪些资产"
              desc="左侧保留真实案例现场，右侧讲清楚流程资产的作用，并只列出本次命中的主表和补表。"
            />
            <FlowCaseMatrix rows={caseAge65Demo.matrixRows} />
          </div>
        </div>
      </section>

      {/* 方案确认 */}
      <section id="plan" className="py-20 md:py-24 bg-slate-800">
        <div className="container mx-auto px-6">
          <div className="max-w-5xl mx-auto">
            <div className="text-center mb-12">
              <span className="text-brand-400 font-semibold tracking-wider text-sm uppercase">
                Plan Confirm
              </span>
              <h2 className="text-3xl md:text-4xl font-bold text-white mt-2 mb-4">
                方案确认：写 SQL 前先对齐口径
              </h2>
              <div className="w-20 h-1 bg-brand-500 mx-auto rounded-full mt-4" />
            </div>

            <div className="overflow-x-auto rounded-2xl border border-slate-700">
              <table className="w-full text-left">
                <thead>
                  <tr className="bg-slate-900 text-slate-300 text-sm">
                    <th className="px-6 py-4 font-semibold w-32">项</th>
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
                      <td className="px-6 py-4 font-bold text-brand-400 whitespace-nowrap">
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

            {/* SQL 三步 */}
            <div className="mt-12 grid md:grid-cols-3 gap-6">
              {caseAge65Demo.sqlSteps.map((s) => (
                <div
                  key={s.step}
                  className="bg-slate-900 rounded-2xl p-6 border border-slate-700 hover-lift"
                >
                  <div className="w-8 h-8 rounded-full bg-brand-600 text-white flex items-center justify-center font-bold text-sm mb-4">
                    {s.step}
                  </div>
                  <code className="text-brand-400 text-xs font-mono block mb-2">
                    {s.table}
                  </code>
                  <h3 className="text-white font-bold mb-2">{s.title}</h3>
                  <p className="text-slate-400 text-sm">{s.desc}</p>
                </div>
              ))}
            </div>

            <div className="mt-10 mac-window hover-lift">
              <div className="mac-header">
                <div className="mac-dot" style={{ background: "#ff5f56" }} />
                <div className="mac-dot" style={{ background: "#ffbd2e" }} />
                <div className="mac-dot" style={{ background: "#27c93f" }} />
                <span className="text-slate-400 text-xs ml-2 font-sans">
                  Hive SQL · 多步 CTAS 摘要
                </span>
              </div>
              <pre className="mac-body">{caseAge65Demo.sqlSnippet}</pre>
            </div>
          </div>
        </div>
      </section>

      {/* 知识库命中 */}
      <section id="knowledge" className="py-20 md:py-24 bg-slate-50">
        <div className="container mx-auto px-6">
          <div className="max-w-5xl mx-auto">
            <SectionHeader
              label="Knowledge Base"
              title="命中了哪些知识库资产？"
              desc="不是让 AI 盲猜表名，而是按文档路由到正确口径"
            />
            <div className="grid md:grid-cols-2 gap-6">
              {caseAge65Demo.knowledgeHits.map((hit) => (
                <article
                  key={hit.name}
                  className="bg-white p-6 rounded-2xl border border-slate-200 hover-lift"
                >
                  <div className="flex items-center gap-3 mb-3">
                    <BookOpen
                      size={20}
                      className="text-brand-600"
                      strokeWidth={1.8}
                    />
                    <code className="text-brand-700 font-bold text-sm">
                      {hit.name}
                    </code>
                  </div>
                  <h3 className="font-bold text-slate-800 mb-2">{hit.role}</h3>
                  <p className="text-slate-600 text-sm leading-relaxed">
                    {hit.desc}
                  </p>
                </article>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* 通用流程 */}
      <section id="flow" className="py-20 md:py-24 bg-white">
        <div className="container mx-auto px-6">
          <div className="max-w-5xl mx-auto">
            <SectionHeader
              label="Workflow"
              title="write-query 通用运行流程"
              desc="本案例走的正是这条路径：非标准指标 → 主表路由 → 补表 → 审计交付"
            />
            <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
              {caseAge65Demo.flowSteps.map((step, index) => (
                <div
                  key={step.title}
                  className="relative bg-slate-50 rounded-2xl p-6 border border-slate-200 hover-lift"
                >
                  <span className="text-4xl font-black text-brand-100 absolute top-4 right-4">
                    {String(index + 1).padStart(2, "0")}
                  </span>
                  <code className="text-xs text-brand-600 font-semibold">
                    {step.source}
                  </code>
                  <h3 className="text-lg font-bold text-slate-800 mt-2 mb-2">
                    {step.title}
                  </h3>
                  <p className="text-slate-600 text-sm leading-relaxed">
                    {step.desc}
                  </p>
                </div>
              ))}
            </div>

            {/* 自检 */}
            <div className="mt-12 bg-brand-50 rounded-2xl border border-brand-200 p-8">
              <div className="flex items-center gap-3 mb-6">
                <ShieldCheck className="text-brand-600" size={24} />
                <h3 className="text-xl font-bold text-slate-800">
                  交付附带自检 SQL
                </h3>
              </div>
              <ul className="space-y-3">
                {caseAge65Demo.selfCheck.map((sql) => (
                  <li
                    key={sql}
                    className="flex gap-3 items-start text-sm text-slate-700"
                  >
                    <ArrowRight
                      size={16}
                      className="text-brand-500 mt-0.5 flex-shrink-0"
                    />
                    <code className="font-mono bg-white px-3 py-1.5 rounded-lg border border-brand-100 flex-1">
                      {sql}
                    </code>
                  </li>
                ))}
              </ul>
            </div>
          </div>
        </div>
      </section>

      {/* 页脚 */}
      <footer className="py-12 bg-slate-900 text-center">
        <div className="container mx-auto px-6">
          <p className="text-slate-400 text-sm mb-4">
            write-query 技能 · CDAP 自然语言取数能力底座
          </p>
          <div className="inline-flex flex-wrap justify-center items-center gap-2 md:gap-4 bg-slate-800 text-white font-bold px-6 py-3 rounded-full text-sm">
            <span>懂需求</span>
            <ArrowRight size={14} className="text-slate-500" />
            <span>找对表</span>
            <ArrowRight size={14} className="text-slate-500" />
            <span>对齐口径</span>
            <ArrowRight size={14} className="text-brand-500" />
            <span className="text-brand-400">交付 SQL</span>
          </div>
        </div>
      </footer>
    </div>
  );
}
