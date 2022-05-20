function Get-Branch {
  return &git branch | ForEach-Object -Process { if ($_.StartsWith("*")) { $_.Substring(2) } }
}

function New-Branch {
  param (
    [string] $Name
  )

  if (!$name.StartsWith("feature") -and !$Name.StartsWith("bug")) {
    $Name = "feature/mu/$Name"
  }

  $result = &git checkout -b $Name
  Write-Host $result -ForegroundColor green
}

function Push-Branch {
  $branch = Get-Branch

  if ($branch.StartsWith("fatal")) {
    Write-Host $branch -ForegroundColor -red
    return
  }

  $result = &git push --set-upstream origin $branch
  return $result
}

Export-ModuleMember -Function "Get-Branch"
Export-ModuleMember -Function "New-Branch"
Export-ModuleMember -Function "Push-Branch"
