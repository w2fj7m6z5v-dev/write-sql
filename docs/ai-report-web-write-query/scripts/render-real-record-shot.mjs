import { mkdir } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import { chromium } from "playwright";

const outputDir = new URL("../src/assets/", import.meta.url);
await mkdir(outputDir, { recursive: true });

const transcript = [
  {
    role: "业务同事",
    time: "16:03",
    tone: "user",
    text: "请教下，能帮忙取一下近三个月，机主年龄大于等于65岁的所有订单不？",
  },
  {
    role: "AI 支撑",
    time: "16:03",
    tone: "ai",
    text:
      "我先按这个理解：\n\n查什么：订单明细，不是汇总数量。\n查谁：机主年龄 >=65 的客户对应的号码/服务订单。\n时间：近三个月订单，默认先理解为按订单受理时间。\n结果：输出所有订单明细，保留订单编码、号码、客户、年龄、受理时间、订单状态、动作类型、机构/揽装信息等。\n默认假设：你说“所有订单”，所以默认不排除撤单/作废，也不只取竣工订单；年龄用 069 的身份证字段计算，不输出身份证原文。\n\n还差这几个会影响 SQL 的点：\n1. “近三个月”按哪个订单时间算：受理时间 act_date，还是竣工/状态时间 subs_stat_date？\n2. 年龄按哪个时间点算：当前最新资料月年龄，还是订单发生当月的年龄快照？\n3. 输出要订单明细即可，还是还要顺便按月/分局/营服汇总一版？\n\n你确认这 3 点后，我下一步给你“方案确认”，确认完再出 SQL。",
  },
  {
    role: "业务同事",
    time: "16:04",
    tone: "user",
    text:
      "1、受理时间，看202604到202606；2、按当前资料月算年龄；3、输出订单明细，字段：订单id，订单编码、号码、客户、年龄、受理时间、网点信息、揽装信息等",
  },
  {
    role: "AI 支撑",
    time: "16:08",
    tone: "ai",
    text:
      "方案确认\n\n主表：040 全业务号码订单表\n用订单事实表取“所有订单明细”\n当前表：zone_gz_yz.dwm_yz_rpt_comm_ba_subs_final\n月表：zone_gz_yz.dwm_yz_rpt_comm_ba_subs_mon_final\n\n时间口径：按受理时间 act_date\n查询窗口：2026-04-01 <= act_date < 2026-07-01\n月表的 par_month_id 只是归档月，不当作受理月；SQL 会先合并订单池，再按 act_date 过滤。\n\n补表：补 069 全业务资料表 当前最新资料月算年龄\n表：dwm_yz_tb_comm_cm_all_final\n关联键：040.serv_id = 069.serv_id\n年龄口径：social_id_type='1' 身份证，按当前年份减出生年份；不输出身份证原文。\n\n过滤：age >= 65\n“所有订单”默认保留全流程状态：不加 subs_stat='301200'，不排除撤单/作废。\n\n风险点：年龄按当前资料月，不是订单发生当月年龄；当前表 + 月表可能重复同一订单；069 同一 serv_id 仍需自检是否放大。",
  },
  {
    role: "业务同事",
    time: "16:08",
    tone: "user",
    text: "没问题",
  },
  {
    role: "AI 支撑",
    time: "16:09",
    tone: "ai",
    text:
      "确认收到，按刚才方案生成 SQL。这里用 202604-202606 受理时间窗口，即 2026-04-01 <= act_date < 2026-07-01。\n\n-- 需求：取 202604-202606 受理订单中，机主年龄 >= 65 岁的所有订单明细\n-- 主表：040 全业务号码订单表\n-- 补表：069 全业务资料表当前最新资料月\n-- 口径：所有订单，不默认排除撤单/作废，不默认只取竣工\n-- 年龄：069 social_id/social_id_type 计算，不输出身份证原文\n\ncreate table tmp_old65_order_pool_202606 as ...\ncreate table tmp_old65_order_dedup_202606 as ...\ncreate table tmp_old65_cm_latest_202606 as ...\ncreate table ads_old65_order_detail_202606 as ...\n\n自检 SQL：\nselect count(*), count(distinct subs_id), count(distinct serv_id) from ads_old65_order_detail_202606;\nselect age_snapshot_month, count(*) from ads_old65_order_detail_202606 group by age_snapshot_month;\nselect substr(cast(act_date as string),1,7), count(*) from ads_old65_order_detail_202606 group by substr(cast(act_date as string),1,7);\n\n小提醒：月表归档月裁到 202604-202607，是为了覆盖 4-6 月受理、稍后归档的订单；当前表也补了一遍未归档/当前池订单。",
  },
];

const html = String.raw`
<!doctype html>
<html lang="zh-CN">
  <head>
    <meta charset="utf-8" />
    <style>
      * { box-sizing: border-box; }
      body {
        margin: 0;
        background: #e5e7eb;
        color: #0f172a;
        font-family: "Microsoft YaHei", "PingFang SC", "Segoe UI", Arial, sans-serif;
      }
      #shot {
        width: 1180px;
        min-height: 1600px;
        background: #f8fafc;
        padding: 28px;
      }
      .window {
        overflow: hidden;
        border: 1px solid #cbd5e1;
        border-radius: 22px;
        background: white;
        box-shadow: 0 28px 70px rgba(15, 23, 42, 0.18);
      }
      .topbar {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 18px 22px;
        background: #0f172a;
        color: white;
      }
      .dots {
        display: flex;
        gap: 8px;
      }
      .dot {
        width: 12px;
        height: 12px;
        border-radius: 999px;
      }
      .title {
        font-weight: 800;
        letter-spacing: .02em;
      }
      .subtitle {
        color: #94a3b8;
        font-size: 13px;
        font-weight: 700;
      }
      .content {
        padding: 24px;
        background:
          linear-gradient(90deg, rgba(225,29,72,.05), transparent 38%),
          #f8fafc;
      }
      .message {
        display: grid;
        grid-template-columns: 94px 1fr;
        gap: 16px;
        margin-bottom: 18px;
      }
      .meta {
        padding-top: 8px;
        text-align: right;
      }
      .role {
        font-size: 14px;
        font-weight: 900;
        color: #0f172a;
      }
      .time {
        margin-top: 4px;
        color: #64748b;
        font-size: 12px;
        font-weight: 800;
      }
      .bubble {
        border: 1px solid #e2e8f0;
        border-radius: 18px;
        padding: 18px 20px;
        background: white;
        font-size: 18px;
        font-weight: 600;
        line-height: 1.72;
        white-space: pre-wrap;
      }
      .message.user .bubble {
        border-color: #fecdd3;
        background: #fff1f2;
      }
      .message.ai .bubble {
        background: white;
      }
      .message.ai .role {
        color: #be123c;
      }
      .message.ai .bubble {
        box-shadow: inset 4px 0 0 #e11d48;
      }
      .code {
        margin-top: 10px;
        border-radius: 12px;
        background: #111827;
        color: #e5e7eb;
        padding: 14px;
        font-family: Consolas, "JetBrains Mono", monospace;
        font-size: 15px;
        line-height: 1.6;
      }
      .footer {
        display: flex;
        justify-content: space-between;
        border-top: 1px solid #e2e8f0;
        padding: 16px 22px;
        color: #64748b;
        font-size: 13px;
        font-weight: 800;
        background: white;
      }
    </style>
  </head>
  <body>
    <div id="shot">
      <div class="window">
        <div class="topbar">
          <div class="dots">
            <span class="dot" style="background:#fb7185"></span>
            <span class="dot" style="background:#facc15"></span>
            <span class="dot" style="background:#22c55e"></span>
          </div>
          <div>
            <div class="title">真实案例记录：65岁以上机主近三个月订单</div>
            <div class="subtitle">需求澄清 → 方案确认 → SQL 生成 → 自检交付</div>
          </div>
        </div>
        <div class="content">
          ${transcript
            .map(
              (item) => `
                <section class="message ${item.tone}">
                  <div class="meta">
                    <div class="role">${item.role}</div>
                    <div class="time">${item.time}</div>
                  </div>
                  <div class="bubble">${escapeHtml(item.text)}</div>
                </section>
              `,
            )
            .join("")}
        </div>
        <div class="footer">
          <span>来源：用户粘贴的真实对话记录</span>
          <span>write-query case asset map</span>
        </div>
      </div>
    </div>
  </body>
</html>
`;

function escapeHtml(value) {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

const launchOptions = [{ headless: true }, { channel: "chrome", headless: true }];
let browser;
let launchError;
for (const options of launchOptions) {
  try {
    browser = await chromium.launch(options);
    break;
  } catch (error) {
    launchError = error;
  }
}
if (!browser) throw launchError;

const page = await browser.newPage({ viewport: { width: 1240, height: 1800 }, deviceScaleFactor: 1 });
await page.setContent(html, { waitUntil: "networkidle" });
const outputPath = fileURLToPath(new URL("case-age65-real-record.png", outputDir));
await page.locator("#shot").screenshot({ path: outputPath });
await browser.close();

console.log(outputPath);
