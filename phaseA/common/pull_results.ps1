# Pull results from the cluster to D:\project
#
# Run this in PowerShell ON YOUR LAPTOP (not on the cluster).
# The cluster cannot push to you - your laptop has no SSH server and sits
# behind the VPN - so you always pull.
#
#   powershell -ExecutionPolicy Bypass -File pull_results.ps1
#
# Copies only small, meaningful outputs. It deliberately does NOT copy
# 01_raw (173 GB of FASTQ) or 02_qc/*.fq.gz - those stay on the cluster.

$User   = "alainaa26"
$Host_  = "211.69.141.130"      # login01, on campus. Off campus: 211.69.141.140
$Port   = "22333"               # off campus: 33322
$Remote = "/public/home/alainaa26/selenium"
$Local  = "D:\project\from-cluster"

New-Item -ItemType Directory -Force -Path $Local | Out-Null
$stamp = Get-Date -Format "yyyy-MM-dd_HHmm"
Write-Host "pulling into $Local  ($stamp)" -ForegroundColor Cyan

# what to fetch: path under $Remote, and whether it is a directory
$items = @(
  @{ p = "00_meta";                d = $true  },   # samples.tsv, run table
  @{ p = "logs";                   d = $true  },   # every job log
  @{ p = "02_qc/*.json";           d = $false },   # fastp reports
  @{ p = "02_qc/*.html";           d = $false },
  @{ p = "03_profiles/*.tsv";      d = $false },   # taxonomy tables
  @{ p = "04_screen/*.tsv";        d = $false },   # selenium marker counts
  @{ p = "09_stats";               d = $true  },   # figures and statistics
  @{ p = "scripts";                d = $true  },
  @{ p = "*.lsf";                  d = $false }
)

foreach ($i in $items) {
  $src = "${User}@${Host_}:${Remote}/$($i.p)"
  $flag = if ($i.d) { "-r" } else { "" }
  Write-Host "  $($i.p)" -NoNewline
  $out = & scp -P $Port $flag $src $Local 2>&1
  if ($LASTEXITCODE -eq 0) { Write-Host "   ok" -ForegroundColor Green }
  else { Write-Host "   (nothing yet)" -ForegroundColor DarkGray }
}

Write-Host ""
Write-Host "done. Contents of $Local :" -ForegroundColor Cyan
Get-ChildItem $Local | Select-Object Name, Length, LastWriteTime | Format-Table
