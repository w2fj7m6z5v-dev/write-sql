import React from "react";

/**
 * 左侧“目录结构 + 用途”小组件（用于矩阵每一行）
 *
 * @param {{
 *  assets: Array<{ path: string, use: string }>
 * }} props
 */
export function DirectoryUsePanel({ assets }) {
  return (
    <div className="space-y-3">
      <div className="text-xs font-bold text-brand-600 uppercase tracking-wider">
        Directory
      </div>
      <ul className="space-y-2">
        {assets.map((a) => (
          <li key={a.path} className="flex gap-3 items-start">
            <span className="w-2.5 h-2.5 rounded-full bg-brand-600 mt-2 flex-shrink-0" />
            <div>
              <code className="block text-xs font-mono text-brand-700 break-words">
                {a.path}
              </code>
              <div className="text-sm text-slate-600 leading-relaxed">
                {a.use}
              </div>
            </div>
          </li>
        ))}
      </ul>
    </div>
  );
}

