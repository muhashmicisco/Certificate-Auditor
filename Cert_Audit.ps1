# 1. Setup the "Trust All" Policy and Protocols
[Reflection.Assembly]::LoadWithPartialName("System.Xml.Linq") | Out-Null
if (-not ([System.Management.Automation.PSTypeName]'TrustAllCertsPolicy').Type) {
    Add-Type -TypeDefinition "using System.Net; using System.Security.Cryptography.X509Certificates; public class TrustAllCertsPolicy : ICertificatePolicy { public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) { return true; } }"
}
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
# Added Tls13 for modern compatibility while keeping older ones for legacy
$Protocols = [Net.SecurityProtocolType]"Ssl3, Tls, Tls11, Tls12, Tls13"
[System.Net.ServicePointManager]::SecurityProtocol = $Protocols

# 2. Configuration
$inputFile  = "sites.csv"    
$outputFile = "Cert_Audit_Results.csv"

if (-not (Test-Path $inputFile)) { Write-Host "Error: $inputFile not found!" -ForegroundColor Red; return }

# 3. Process
$results = Import-Csv $inputFile | ForEach-Object {
    $ip = $_.IP.ToString().Trim()
    $port = if ($_.Port) { $_.Port.ToString().Trim() } else { "443" }

    Write-Host "Auditing $ip on port $port..." -ForegroundColor Cyan

    try {
        $cert = $null
        
        if ($port -eq "5061") {
            # --- SIP/TLS LOGIC (Hardened Handshake) ---
            $tcpClient = New-Object System.Net.Sockets.TcpClient
            $connect = $tcpClient.BeginConnect($ip, [int]$port, $null, $null)
            if (-not $connect.AsyncWaitHandle.WaitOne(5000, $false)) { throw "Connection Timeout (TCP 5061)" }
            $tcpClient.EndConnect($connect)
            
            # User-defined callback to ignore all chain errors
            $sslStream = New-Object System.Net.Security.SslStream($tcpClient.GetStream(), $false, ({ return $true }))
            
            # THE FIX: Explicitly pass protocols and ignore revocation checks
            $sslStream.AuthenticateAsClient($ip, $null, $Protocols, $false)
            
            if ($sslStream.RemoteCertificate) {
                $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($sslStream.RemoteCertificate)
            }
            $tcpClient.Close()
        }
        else {
            # --- WEB/SSL LOGIC ---
            $webRequest = [System.Net.HttpWebRequest]::Create("https://$ip`:$port")
            $webRequest.Timeout = 5000
            $webRequest.AllowAutoRedirect = $false
            $response = $webRequest.GetResponse()
            $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($webRequest.ServicePoint.Certificate)
            $response.Close()
        }

        if ($null -eq $cert) { throw "Could not retrieve certificate" }

        # --- PARSING LOGIC (Remains the same for consistency) ---
        $ekuExt = $cert.Extensions | Where-Object { $_.Oid.Value -eq "2.5.29.37" }
        $ekuFormatted = if ($ekuExt) { $ekuExt.Format($false) } else { "None Found" }

        $sanExt = $cert.Extensions | Where-Object { $_.Oid.Value -eq "2.5.29.17" }
        $sanFormatted = if ($sanExt) { $sanExt.Format($true) -replace "`r`n", "; " } else { "None" }

        $cn = "Unknown/Empty"
        if ($cert.Subject) {
            $cnRaw = $cert.Subject.Split(',').Where({$_ -like "CN=*" }) | Select-Object -First 1
            if ($cnRaw) { $cn = ([string]$cnRaw).Replace("CN=", "").Trim() }
            else { $cn = $cert.Subject }
        }

        $issuer = "Unknown/Empty"
        if ($cert.Issuer) {
            $issuerRaw = $cert.Issuer.Split(',').Where({$_ -like "CN=*" }) | Select-Object -First 1
            if ($issuerRaw) { $issuer = ([string]$issuerRaw).Replace("CN=", "").Trim() }
            else { $issuer = $cert.Issuer }
        }

        $status = if ($cn -eq $issuer -and $cn -ne "Unknown/Empty") { "Self-Signed" } else { "CA Signed" }

        [PSCustomObject]@{
            IPAddress    = $ip
            Port         = $port
            Status       = $status
            CommonName   = $cn
            Issuer       = $issuer
            Expiration   = $cert.NotAfter
            DaysLeft     = ($cert.NotAfter - (Get-Date)).Days
            EKU          = $ekuFormatted
            SANs         = $sanFormatted
        }
    }
    catch {
        [PSCustomObject]@{
            IPAddress    = $ip; Port = $port; Status = "ERROR"; CommonName = "FAILED"; Issuer = "N/A"; Expiration = $null; DaysLeft = $null; SANs = "N/A"; EKU = "Error: $($_.Exception.Message)"
        }
    }
}

# 4. Final Outputs
$results | Out-GridView -Title "Certificate Audit: Multi-Port & SIP Results"
$results | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8
Write-Host "`n[DONE] Results saved to: $outputFile" -ForegroundColor Green
