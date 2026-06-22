import { mkdir } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import { chromium } from "playwright";

const outputDir = new URL("../qa/", import.meta.url);
await mkdir(outputDir, { recursive: true });

const launchOptions = [
  { headless: true },
  { channel: "chrome", headless: true },
  { channel: "msedge", headless: true },
];

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

if (!browser) {
  throw launchError;
}

const viewports = [
  { name: "desktop", width: 1440, height: 1200 },
  { name: "mobile", width: 390, height: 900 },
];

const results = [];
for (const viewport of viewports) {
  const page = await browser.newPage({ viewport });
  const consoleErrors = [];
  page.on("console", (message) => {
    if (message.type() === "error") {
      consoleErrors.push(message.text());
    }
  });

  await page.goto("http://127.0.0.1:5173", { waitUntil: "networkidle" });
  const metrics = await page.evaluate(() => {
    const ids = [
      "hero",
      "case",
      "annotated",
      "matrix",
      "plan",
      "knowledge",
      "flow",
      "case-annotated",
    ];
    const missing = ids.filter((id) => !document.getElementById(id));
    const widthOverflow =
      document.documentElement.scrollWidth -
      document.documentElement.clientWidth;
    const bodyText = document.body.innerText;
    return {
      missing,
      widthOverflow,
      hasTitle: bodyText.includes("write-query"),
      hasCase: bodyText.includes("老年客群订单明细"),
      hasAnnotations: bodyText.includes("业务同事用自然语言提需求"),
      hasPlan: bodyText.includes("方案确认"),
      hasKnowledge: bodyText.includes("ROUTING.md"),
      hasMatrix: bodyText.includes("左目录结构"),
      scrollHeight: document.documentElement.scrollHeight,
    };
  });

  const screenshotPath = fileURLToPath(
    new URL(`${viewport.name}.png`, outputDir),
  );
  await page.screenshot({ path: screenshotPath, fullPage: true });

  if (viewport.name === "desktop") {
    const caseShotPath = fileURLToPath(
      new URL("case-annotated-desktop.png", outputDir),
    );
    const caseEl = page.locator("#case-annotated");
    if ((await caseEl.count()) > 0) {
      await caseEl.screenshot({ path: caseShotPath });
    }
  }

  results.push({ viewport, consoleErrors, metrics, screenshot: screenshotPath });
  await page.close();
}

await browser.close();
console.log(JSON.stringify(results, null, 2));
