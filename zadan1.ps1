#предполагается, что все сервера в одном домене и используется учетка у которой есть права на эти операции
#пароль  в зашифрованном файле и от туда его вычитывать
#типа такой 
#$credentials = Get-Credential MyDomain\UserForCopy
#$key = @(1..24)
#$Credentials.Password | ConvertFrom-SecureString -Key $key | Set-Content pass.txt
#потом вычитывать так
#$UserName = ″MyDomain\UserForCopy″
#$password = Get-Content pass.txt | ConverTo-SecureString -Key $key
#$Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserName, $password
# второй способ
# простой способ но мненее безопасный пароль хранится в открытом виде 
$date=Get-Date -Format "HHmmddMMyyyy" 
$PlainPassword = "11"
$SecurePassword = $PlainPassword | ConvertTo-SecureString -AsPlainText -Force
$UserName = "MyDomain\UserForCopy"
$Credentials = New-Object System.Management.Automation.PSCredential `
     -ArgumentList $UserName, $SecurePassword

for ([int]$i = 1; $i -lt 4; $i++) {
      $servername='appserver'  
      $servername=$servername+$i
       $session = New-PSSession -ComputerName $servername -Credential $credentials 
       $list = Invoke-Command -Cn $servername {
               Get-ChildItem C:\app\server
               }
        if ($list.Count -eq 0)
            {  Copy-Item -Path C:\Update\bin -Destination C:\app\server -Recurse -Force  -ToSession $session
               Copy-Item -Path C:\Update\config -Destination C:\app\server -Recurse -Force  -ToSession $session}
        else {
               Copy-Item -Path C:\app\server -Destination c:\backup\$servername\$date -Recurse -Force  -FromSession $session
               Copy-Item -Path C:\Update\bin -Destination C:\app\server -Recurse -Force  -ToSession $session
               Copy-Item -Path C:\Update\config -Destination C:\app\server -Recurse -Force  -ToSession $session
               }

}