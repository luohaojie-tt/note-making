param(
    [Parameter(Mandatory = $false)]
    [datetime]$TradeDate = (Get-Date),

    [Parameter(Mandatory = $false)]
    [string]$TemplateDir,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath,

    [Parameter(Mandatory = $false)]
    [switch]$IncludeTradeAppendix = $true,

    [Parameter(Mandatory = $false)]
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($TemplateDir)) {
    $TemplateDir = Split-Path -Parent $MyInvocation.MyCommand.Path
}

$sheets = @(
    @{ File = "summary.csv"; Sheet = "summary" },
    @{ File = "sector_strength.csv"; Sheet = "sector_strength" },
    @{ File = "limit_up_list.csv"; Sheet = "limit_up_list" },
    @{ File = "limit_down_list.csv"; Sheet = "limit_down_list" },
    @{ File = "next_day_watchlist.csv"; Sheet = "next_day_watchlist" }
)

if ($IncludeTradeAppendix) {
    $sheets += @{ File = "trade_appendix.csv"; Sheet = "trade_appendix" }
}

$missing = @()
foreach ($s in $sheets) {
    $csvPath = Join-Path $TemplateDir $s.File
    if (-not (Test-Path -Path $csvPath)) {
        $missing += $csvPath
    }
}

if ($missing.Count -gt 0) {
    throw "Missing required CSV files:`n$($missing -join "`n")"
}

if (-not $OutputPath) {
    $OutputPath = Join-Path $TemplateDir ("replay_{0}.xlsx" -f $TradeDate.ToString("yyyyMMdd"))
}

if ($DryRun) {
    Write-Output "DRY_RUN=1"
    Write-Output "TEMPLATE_DIR=$TemplateDir"
    Write-Output "OUTPUT_PATH=$OutputPath"
    Write-Output "SHEETS=$($sheets.Sheet -join ',')"
    return
}

$excel = $null
$outWorkbook = $null

try {
    try {
        $excel = New-Object -ComObject Excel.Application
    } catch {
        throw "Excel COM not available. Please install Microsoft Excel desktop, or run with -DryRun to verify inputs."
    }

    $excel.Visible = $false
    $excel.DisplayAlerts = $false
    $outWorkbook = $excel.Workbooks.Add()

    $createdSheetNames = @()

    for ($i = 0; $i -lt $sheets.Count; $i++) {
        $entry = $sheets[$i]
        $csvPath = Join-Path $TemplateDir $entry.File

        $csvWorkbook = $excel.Workbooks.Open($csvPath)
        $csvSheet = $csvWorkbook.Worksheets.Item(1)
        $usedRange = $csvSheet.UsedRange

        if ($i -eq 0) {
            $outSheet = $outWorkbook.Worksheets.Item(1)
        } else {
            $outSheet = $outWorkbook.Worksheets.Add()
        }

        $outSheet.Name = $entry.Sheet

        if ($usedRange -and $usedRange.Rows.Count -gt 0 -and $usedRange.Columns.Count -gt 0) {
            $targetRange = $outSheet.Range("A1").Resize($usedRange.Rows.Count, $usedRange.Columns.Count)
            $targetRange.Value2 = $usedRange.Value2
            $null = $outSheet.Columns.AutoFit()
            $null = $outSheet.Rows.Item(1).Font.Bold = $true
            $null = $outSheet.Activate()
            $null = $excel.ActiveWindow.SplitRow = 1
            $null = $excel.ActiveWindow.FreezePanes = $true
        }

        $createdSheetNames += $entry.Sheet
        $csvWorkbook.Close($false)
    }

    for ($idx = $outWorkbook.Worksheets.Count; $idx -ge 1; $idx--) {
        $ws = $outWorkbook.Worksheets.Item($idx)
        if ($createdSheetNames -notcontains $ws.Name) {
            $ws.Delete()
        }
    }

    $null = $outWorkbook.Worksheets.Item(1).Activate()
    $outWorkbook.SaveAs($OutputPath, 51)
    Write-Output "OK=1"
    Write-Output "OUTPUT_PATH=$OutputPath"
}
finally {
    if ($outWorkbook) { $outWorkbook.Close($false) }
    if ($excel) { $excel.Quit() }

    if ($outWorkbook) { [void][Runtime.InteropServices.Marshal]::ReleaseComObject($outWorkbook) }
    if ($excel) { [void][Runtime.InteropServices.Marshal]::ReleaseComObject($excel) }

    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
}
