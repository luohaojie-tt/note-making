# Replay Excel Template

This folder contains CSV templates and a one-click PowerShell script to generate a daily replay workbook.

## Files
- `summary.csv`
- `sector_strength.csv`
- `limit_up_list.csv`
- `limit_down_list.csv`
- `next_day_watchlist.csv`
- `trade_appendix.csv` (optional)
- `build_replay_excel.ps1` (build workbook from CSV)

## One-Click Build

```powershell
powershell -ExecutionPolicy Bypass -File .\build_replay_excel.ps1 -TradeDate "2026-03-07"
```

Output example:
- `replay_20260307.xlsx`

## Useful Options

```powershell
# verify paths and sheet plan without opening Excel
powershell -ExecutionPolicy Bypass -File .\build_replay_excel.ps1 -TradeDate "2026-03-07" -DryRun

# do not include trade appendix sheet
powershell -ExecutionPolicy Bypass -File .\build_replay_excel.ps1 -TradeDate "2026-03-07" -IncludeTradeAppendix:$false

# custom output path
powershell -ExecutionPolicy Bypass -File .\build_replay_excel.ps1 -TradeDate "2026-03-07" -OutputPath ".\my_replay.xlsx"
```

## Notes
- Requires Microsoft Excel desktop (COM automation).
- If Excel is not installed, use `-DryRun` to check inputs, then import CSV files manually in Excel.
