function Get-Branch {
  # Gets the current branch
  return &git branch | ForEach-Object -Process { if ($_.StartsWith("*")) { $_.Substring(2) } }
}

function New-Branch {
  param (
    [Parameter(Position=0)]
    [string] $Branch,
    [string] $Initials = "mu",
    [switch] $Bug = $false,
    [switch] $Devops = $false
  )

  if ($Bug) {
    $Branch = "bug/$Initials/$Branch"
  } elseif ($Devops) {
    $Branch = "devops/$Initials/$Branch"
  } else {
    $Branch = "feature/$Initials/$Branch"
  }

  $result = &git checkout -b $Branch
  Write-Host $result -ForegroundColor green
}

function Push-Branch {
  $branch = Get-Branch

  # If there is an error in obtaining the branch
  if ($branch.StartsWith("fatal")) {
    Write-Host $branch -ForegroundColor -red
    return
  }

  $result = &git push --set-upstream origin $branch
  return $result
}

function Push-Fast {
  param (
    [Parameter(Mandatory=$true)]
    [string] $M
  )

  &git add .
  &git commit -m $M
  &git push
}

function Remove-Branches {
  # Delete all branches except main, master, or current
  &git branch | Select-String -Pattern '^(?!.*(\*|main|master)).*$' | ForEach-Object { git branch -D $_.ToString().Trim() }
  Write-Host "Remaining branches:"
  &git branch
}

function Git-Log {
  param (
    [switch] $Graph = $false
  )

  $params = @("--oneline")

  if ($Graph) {
    $params += "--graph"
  }

  &git log $params
}

Export-ModuleMember -Function "Git-Log"
Export-ModuleMember -Function "Push-Fast"
Export-ModuleMember -Function "Get-Branch"
Export-ModuleMember -Function "New-Branch"
Export-ModuleMember -Function "Push-Branch"
Export-ModuleMember -Function "Remove-Branches"
