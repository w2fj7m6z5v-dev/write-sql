import caseScreenshot from "../assets/case-age65-cursor.png";

/**
 * @param {{ annotations: Array<{ id: number, label: string, target: { x: number, y: number }, labelPos: { x: number, y: number } }> }} props
 */
export function AnnotatedCaseShot({ annotations }) {
  return (
    <div id="case-annotated" className="relative w-full">
      {/* 桌面端：截图 + SVG 标注 */}
      <div className="hidden md:block relative rounded-2xl overflow-hidden border border-slate-200 shadow-xl bg-slate-900">
        <img
          src={caseScreenshot}
          alt="Cursor 中 write-query 技能处理老年客群订单需求的实拍截图"
          className="w-full h-auto block"
        />
        <svg
          className="absolute inset-0 w-full h-full pointer-events-none"
          viewBox="0 0 100 100"
          preserveAspectRatio="none"
          aria-hidden="true"
        >
          <defs>
            <marker
              id="arrowhead"
              markerWidth="6"
              markerHeight="6"
              refX="5"
              refY="3"
              orient="auto"
            >
              <polygon points="0 0, 6 3, 0 6" fill="#e11d48" />
            </marker>
          </defs>
          {annotations.map((ann) => (
            <g key={ann.id}>
              <line
                x1={ann.labelPos.x}
                y1={ann.labelPos.y}
                x2={ann.target.x}
                y2={ann.target.y}
                stroke="#e11d48"
                strokeWidth="0.35"
                fill="none"
                markerEnd="url(#arrowhead)"
                opacity="0.9"
              />
              <circle
                cx={ann.target.x}
                cy={ann.target.y}
                r="1.2"
                fill="#e11d48"
                stroke="white"
                strokeWidth="0.3"
              />
            </g>
          ))}
        </svg>
        {annotations.map((ann) => (
          <div
            key={`label-${ann.id}`}
            className="absolute z-10 -translate-x-1/2 -translate-y-1/2"
            style={{
              left: `${ann.labelPos.x}%`,
              top: `${ann.labelPos.y}%`,
            }}
          >
            <span className="annotation-badge annotation-badge-red whitespace-nowrap">
              <span className="w-5 h-5 rounded-full bg-white text-brand-600 flex items-center justify-center text-xs font-black">
                {ann.id}
              </span>
              {ann.label}
            </span>
          </div>
        ))}
      </div>

      {/* 移动端：截图 + 下方图例 */}
      <div className="md:hidden">
        <div className="rounded-2xl overflow-hidden border border-slate-200 shadow-lg">
          <img
            src={caseScreenshot}
            alt="Cursor 案例截图"
            className="w-full h-auto block"
          />
        </div>
        <ol className="mt-6 space-y-3">
          {annotations.map((ann) => (
            <li
              key={ann.id}
              className="flex gap-3 items-start bg-brand-50 border border-brand-200 rounded-xl p-4"
            >
              <span className="w-7 h-7 rounded-full bg-brand-600 text-white flex items-center justify-center text-sm font-bold flex-shrink-0">
                {ann.id}
              </span>
              <span className="text-sm text-slate-700 font-medium leading-relaxed">
                {ann.label}
              </span>
            </li>
          ))}
        </ol>
      </div>
    </div>
  );
}
