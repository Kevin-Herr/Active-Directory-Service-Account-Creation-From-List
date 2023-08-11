###
# Create Multiple Service Accounts With Random Passwords
###
# Credits:
#	  "Random Password Function" code acquired from https://www.sharepointdiary.com/2020/04/powershell-generate-random-password.html

$PasswordCharacterCount = "20"
$AccountOU = "OU=Service Accounts,OU=Employees,DC=contoso,DC=org"
$AccountListFile = "c:\users\kherradmin\desktop\serviceaccountlist.txt"

### Random Password Function
Function Get-RandomPassword
{
    # Define Parameters
    param([int]$PasswordLength = 10)
 
    # ASCII Character Set for Password
    $CharacterSet = @{
            Uppercase   = (97..122) | Get-Random -Count 10 | % {[char]$_}
            Lowercase   = (65..90)  | Get-Random -Count 10 | % {[char]$_}
            Numeric     = (48..57)  | Get-Random -Count 10 | % {[char]$_}
    }
 
    # Frame Random Password from given character set
    $StringSet = $CharacterSet.Uppercase + $CharacterSet.Lowercase + $CharacterSet.Numeric
     -join(Get-Random -Count $PasswordLength -InputObject $StringSet)
}

# Load New Accounts from File
$AccountListFile = Get-Content $AccountListFile

# Loop Through and Create Accounts
foreach ($username in $AccountListFile) {
	# Generate New Password for Each Account
	$newpassword = Get-RandomPassword -PasswordLength $PasswordCharacterCount

	$newuser = @{
		Name 					= $username
		Path					= $AccountOU
		AccountPassword 		= (ConvertTo-SecureString -AsPlainText $newpassword -Force)
		Enabled 				= $true
		CannotChangePassword	= $true
		PasswordNeverExpires	= $true
		OtherAttributes			= @{'title' = 'BCP Service Account'
									'description' = 'BCP Service Account'}
	}
	New-ADUser @newuser
}
