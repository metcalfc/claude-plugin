---
date: 2026-03-10
type: spraints-dashboard
tags:
  - spraints
  - engineering
  - dashboard
---

# Spraints Dashboard

> [!tip] Nightly lookback reports across Abri repos. Grades merged PRs on test quality, commit hygiene, issue fidelity, review effectiveness, and prep quality.

## Current Status

```dataviewjs
const reports = dv.pages('"05-areas/engineering/spraints"')
  .where(p => p.type === "spraints")
  .sort(p => p.date, 'desc')

const latest = reports[0]
const last7 = reports.slice(0, 7)
const last30 = reports.slice(0, 30)

if (!latest) {
  dv.paragraph("*No spraints reports yet. Run `/spraints` to generate the first one.*")
} else {
  const avg7 = last7.length > 0
    ? Math.round(last7.reduce((s, p) => s + (p.grade_numeric || 0), 0) / last7.length)
    : null
  const avg30 = last30.length > 0
    ? Math.round(last30.reduce((s, p) => s + (p.grade_numeric || 0), 0) / last30.length)
    : null

  const trend = latest.trend_direction === "up" ? "📈"
    : latest.trend_direction === "down" ? "📉" : "➡️"

  dv.paragraph(`> [!info] Latest: **${latest.grade} (${latest.grade_numeric})** ${trend} | 7-day avg: **${avg7 ?? "—"}** | 30-day avg: **${avg30 ?? "—"}** | Reports: **${reports.length}**`)
}
```

## Grade Over Time

```dataviewjs
const reports = dv.pages('"05-areas/engineering/spraints"')
  .where(p => p.type === "spraints")
  .sort(p => p.date, 'asc')
  .slice(-30)

if (reports.length < 2) {
  dv.paragraph("*Need at least 2 reports for charts.*")
} else {
  const labels = reports.map(p => p.date?.toFormat?.("MM-dd") ?? p.file.name).values
  const grades = reports.map(p => p.grade_numeric || 0).values

  // 7-day rolling average
  const rolling = grades.map((_, i) => {
    const window = grades.slice(Math.max(0, i - 6), i + 1)
    return Math.round(window.reduce((s, v) => s + v, 0) / window.length)
  })

  window.renderChart({
    type: 'line',
    data: {
      labels: labels,
      datasets: [
        {
          label: 'Daily Grade',
          data: grades,
          borderColor: 'rgba(255, 179, 71, 0.6)',
          backgroundColor: 'rgba(255, 179, 71, 0.1)',
          pointBackgroundColor: 'rgb(255, 179, 71)',
          tension: 0.2,
          fill: true
        },
        {
          label: '7-day Average',
          data: rolling,
          borderColor: 'rgb(139, 90, 43)',
          borderDash: [5, 5],
          pointRadius: 0,
          tension: 0.3
        }
      ]
    },
    options: {
      scales: {
        y: { min: 0, max: 100, title: { display: true, text: 'Score' } }
      },
      plugins: {
        title: { display: true, text: 'Overall Grade (last 30 days)' }
      }
    }
  }, this.container)
}
```

## Per-Repo Grades

```dataviewjs
const reports = dv.pages('"05-areas/engineering/spraints"')
  .where(p => p.type === "spraints")
  .sort(p => p.date, 'asc')
  .slice(-30)

if (reports.length < 2) {
  dv.paragraph("*Need at least 2 reports for charts.*")
} else {
  const labels = reports.map(p => p.date?.toFormat?.("MM-dd") ?? p.file.name).values
  const kelp = reports.map(p => p.repos?.kelp?.grade_numeric ?? null).values
  const otto = reports.map(p => p.repos?.otto?.grade_numeric ?? null).values
  const holt = reports.map(p => p.repos?.holt?.grade_numeric ?? null).values

  window.renderChart({
    type: 'line',
    data: {
      labels: labels,
      datasets: [
        { label: 'kelp', data: kelp, borderColor: 'rgb(72, 160, 120)', tension: 0.2, spanGaps: true },
        { label: 'otto', data: otto, borderColor: 'rgb(100, 149, 237)', tension: 0.2, spanGaps: true },
        { label: 'holt', data: holt, borderColor: 'rgb(205, 133, 63)', tension: 0.2, spanGaps: true }
      ]
    },
    options: {
      scales: {
        y: { min: 0, max: 100, title: { display: true, text: 'Score' } }
      },
      plugins: {
        title: { display: true, text: 'Grade by Repo (last 30 days)' }
      }
    }
  }, this.container)
}
```

## Dimensions Breakdown

```dataviewjs
const reports = dv.pages('"05-areas/engineering/spraints"')
  .where(p => p.type === "spraints")
  .sort(p => p.date, 'asc')
  .slice(-14)

if (reports.length < 2) {
  dv.paragraph("*Need at least 2 reports for charts.*")
} else {
  const labels = reports.map(p => p.date?.toFormat?.("MM-dd") ?? p.file.name).values
  const dims = [
    { key: 'test_quality', label: 'Test Quality', color: 'rgb(255, 99, 132)' },
    { key: 'commit_hygiene', label: 'Commit Hygiene', color: 'rgb(54, 162, 235)' },
    { key: 'issue_fidelity', label: 'Issue Fidelity', color: 'rgb(255, 206, 86)' },
    { key: 'review_effectiveness', label: 'Review Effectiveness', color: 'rgb(75, 192, 192)' },
    { key: 'prep_quality', label: 'Prep Quality', color: 'rgb(153, 102, 255)' }
  ]

  window.renderChart({
    type: 'line',
    data: {
      labels: labels,
      datasets: dims.map(d => ({
        label: d.label,
        data: reports.map(p => p[d.key] ?? null).values,
        borderColor: d.color,
        tension: 0.2,
        spanGaps: true
      }))
    },
    options: {
      scales: {
        y: { min: 0, max: 100 }
      },
      plugins: {
        title: { display: true, text: 'Dimensions (last 14 days)' }
      }
    }
  }, this.container)
}
```

## Attribution Over Time

```dataviewjs
const reports = dv.pages('"05-areas/engineering/spraints"')
  .where(p => p.type === "spraints")
  .sort(p => p.date, 'asc')
  .slice(-30)

if (reports.length < 2) {
  dv.paragraph("*Need at least 2 reports for charts.*")
} else {
  const labels = reports.map(p => p.date?.toFormat?.("MM-dd") ?? p.file.name).values

  window.renderChart({
    type: 'bar',
    data: {
      labels: labels,
      datasets: [
        {
          label: 'Human',
          data: reports.map(p => p.attribution?.human ?? 0).values,
          backgroundColor: 'rgba(72, 160, 120, 0.7)'
        },
        {
          label: 'Claude',
          data: reports.map(p => p.attribution?.claude ?? 0).values,
          backgroundColor: 'rgba(255, 179, 71, 0.7)'
        },
        {
          label: 'Pair',
          data: reports.map(p => p.attribution?.pair ?? 0).values,
          backgroundColor: 'rgba(100, 149, 237, 0.7)'
        }
      ]
    },
    options: {
      scales: {
        x: { stacked: true },
        y: { stacked: true, title: { display: true, text: 'PRs' } }
      },
      plugins: {
        title: { display: true, text: 'Attribution (last 30 days)' }
      }
    }
  }, this.container)
}
```

## Latest Dimension Radar

```dataviewjs
const reports = dv.pages('"05-areas/engineering/spraints"')
  .where(p => p.type === "spraints")
  .sort(p => p.date, 'desc')

const latest = reports[0]
if (!latest) {
  dv.paragraph("*No reports yet.*")
} else {
  const dims = ['test_quality', 'commit_hygiene', 'issue_fidelity', 'review_effectiveness', 'prep_quality']
  const dimLabels = ['Test Quality', 'Commit Hygiene', 'Issue Fidelity', 'Review Effectiveness', 'Prep Quality']
  const scores = dims.map(d => latest[d] ?? 0)

  // 7-day average for comparison
  const last7 = reports.slice(0, 7)
  const avgScores = dims.map(d => {
    const vals = last7.map(p => p[d]).filter(v => v != null).values
    return vals.length > 0 ? Math.round(vals.reduce((s, v) => s + v, 0) / vals.length) : 0
  })

  window.renderChart({
    type: 'radar',
    data: {
      labels: dimLabels,
      datasets: [
        {
          label: `Latest (${latest.date?.toFormat?.("MM-dd") ?? latest.file.name})`,
          data: scores,
          borderColor: 'rgb(255, 179, 71)',
          backgroundColor: 'rgba(255, 179, 71, 0.2)'
        },
        {
          label: '7-day Average',
          data: avgScores,
          borderColor: 'rgb(139, 90, 43)',
          backgroundColor: 'rgba(139, 90, 43, 0.1)',
          borderDash: [5, 5]
        }
      ]
    },
    options: {
      scales: {
        r: { min: 0, max: 100 }
      },
      plugins: {
        title: { display: true, text: 'Quality Dimensions' }
      }
    }
  }, this.container)
}
```

## Recent Reports

```dataview
TABLE WITHOUT ID
  file.link AS "Report",
  grade AS "Grade",
  grade_numeric AS "Score",
  total_prs AS "PRs",
  trend_direction AS "Trend",
  attribution.human AS "👤",
  attribution.claude AS "🤖",
  attribution.pair AS "🤝"
FROM "05-areas/engineering/spraints"
WHERE type = "spraints"
SORT date DESC
LIMIT 14
```

## Tooling Improvement Tracker

```dataviewjs
const reports = dv.pages('"05-areas/engineering/spraints"')
  .where(p => p.type === "spraints" && p.tooling_actions)
  .sort(p => p.date, 'desc')
  .slice(0, 14)

if (reports.length === 0) {
  dv.paragraph("*No tooling actions recorded yet.*")
} else {
  // Aggregate actions across recent reports
  const actions = []
  for (const report of reports) {
    const ta = report.tooling_actions
    if (Array.isArray(ta)) {
      for (const action of ta) {
        actions.push({
          date: report.date?.toFormat?.("MM-dd") ?? report.file.name,
          report: report.file.link,
          target: action.target ?? "unknown",
          finding: action.finding ?? "",
          priority: action.priority ?? "medium"
        })
      }
    }
  }

  // Group by target
  const grouped = {}
  for (const a of actions) {
    if (!grouped[a.target]) grouped[a.target] = []
    grouped[a.target].push(a)
  }

  for (const [target, items] of Object.entries(grouped).sort()) {
    dv.header(4, target)
    dv.table(
      ["Date", "Finding", "Priority"],
      items.map(i => [i.date, i.finding, i.priority])
    )
  }
}
```
