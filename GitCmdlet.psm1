function Get-Branch {
  # Gets the current branch
  return &git branch | ForEach-Object -Process { if ($_.StartsWith("*")) { $_.Substring(2) } }
}

function New-Branch {
  param (
    [Parameter(Mandatory=$true)]
    [string] $BranchName,
    [string] $Initials = "mu",
    [switch] $Bug = $false,
    [switch] $Devops = $false
  )

  if ($Bug) {
    $BranchName = "bug/$Initials/$BranchName"
  } elseif ($Devops) {
    $BranchName = "devops/$Initials/$BranchName"
  } else {
    $BranchName = "feature/$Initials/$BranchName"
  }

  $result = &git checkout -b $BranchName
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

function Remove-Branches {
  # Delete all branches except main, master, or current
  &git branch | Select-String -Pattern '^(?!.*(\*|main|master)).*$' | ForEach-Object { git branch -D $_.ToString().Trim() }
  Write-Host "Remaining branches:"
  &git branch
}

Export-ModuleMember -Function "Get-Branch"
Export-ModuleMember -Function "New-Branch"
Export-ModuleMember -Function "Push-Branch"
Export-ModuleMember -Function "Remove-Branches"
