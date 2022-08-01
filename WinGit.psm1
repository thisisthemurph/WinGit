function Get-Branch {
  # Gets the current branch
  return &git branch | ForEach-Object -Process { if ($_.StartsWith("*")) { $_.Substring(2) } }
}

function Get-Branches {
  param (
    [switch] $Indexed
  )

  &git branch | ForEach-Object -Begin {$idx = 0} -Process {
    $idx++

    [boolean] $isActive = $_.StartsWith("*")
    [string] $name = "$_"

    if ($isActive) {
      $name = -join($name.Substring(2), " 🌳")
    }

    $name = $name -replace "  ", ""
    
    if ($Indexed) {
      $name = "$idx.  $name"
    }

    Write-Host $name
  } 
}

function Select-Branch {
  Get-Branches -Indexed

  $index = Read-Host "Select branch #"
  
  &git branch | ForEach-Object -Begin {$idx = 0} -Process { 
    $idx++
    
    if ($idx -eq $index) {
      $branch = $_ -replace "  ", ""
      Write-Host "Changing to branch '$branch'" -ForegroundColor Yellow

      if ($branch -match "\*") {
        Write-Host "You are already on this branch 🤡" -ForegroundColor Red
      } else {
        &git checkout $branch
      }
    }
  }
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

Export-ModuleMember -Function "Push-Fast"
Export-ModuleMember -Function "Get-Branch"
Export-ModuleMember -Function "Get-Branches"
Export-ModuleMember -Function "Select-Branch"
Export-ModuleMember -Function "New-Branch"
Export-ModuleMember -Function "Push-Branch"
Export-ModuleMember -Function "Remove-Branches"
