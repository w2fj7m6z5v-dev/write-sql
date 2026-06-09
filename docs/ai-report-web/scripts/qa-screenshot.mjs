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

  await page.goto("http://127.0.0.1:5174", { waitUntil: "networkidle" });
  const metrics = await page.evaluate(() => {
    const ids = ["pain", "flow", "knowledge", "case", "apps", "value"];
    const missing = ids.filter((id) => !document.getElementById(id));
    const widthOverflow = document.documentElement.scrollWidth - document.documentElement.clientWidth;
    const bodyText = document.body.innerText;
    const hero = document.querySelector(".hero");
    const heroRect = hero?.getBoundingClientRect();
    return {
      missing,
      widthOverflow,
      hasTitle: bodyText.includes("AI自然语言取数能力底座"),
      hasCase: bodyText.includes("主宽入网量（按维汇总）"),
      heroHeight: heroRect?.height ?? 0,
      scrollHeight: document.documentElement.scrollHeight,
    };
  });

  const screenshotPath = fileURLToPath(new URL(`${viewport.name}.png`, outputDir));
  await page.screenshot({ path: screenshotPath, fullPage: true });
  results.push({ viewport, consoleErrors, metrics, screenshot: screenshotPath });
  await page.close();
}

await browser.close();
console.log(JSON.stringify(results, null, 2));
