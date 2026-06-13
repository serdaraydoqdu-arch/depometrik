$urls = @{
  "shell" = "https://logo.clearbit.com/shell.com"
  "opet" = "https://logo.clearbit.com/opet.com.tr"
  "petrol_ofisi" = "https://logo.clearbit.com/petrolofisi.com.tr"
  "bp" = "https://logo.clearbit.com/bp.com"
  "aytemiz" = "https://logo.clearbit.com/aytemiz.com.tr"
  "total" = "https://logo.clearbit.com/totalenergies.com"
  "aygaz" = "https://logo.clearbit.com/aygaz.com.tr"
}

foreach ($key in $urls.Keys) {
  $outputPath = "e:\Depometrik\assets\images\$key.png"
  Write-Host "Downloading $key logo to $outputPath..."
  try {
    Invoke-WebRequest -Uri $urls[$key] -OutFile $outputPath -TimeoutSec 10
  } catch {
    Write-Host "Failed to download $key logo: $_"
  }
}
