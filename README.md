# Certificate-Auditor
A robust PowerShell utility designed to audit SSL/TLS certificates across large internal networks. This script is specifically hardened to handle legacy hardware (PDUs, AV gear, older appliances) that may require deprecated protocols or have malformed certificate fields.
<p>
🚀 Features
  Legacy Protocol Support: Explicitly handles SSLv3, TLS 1.0, TLS 1.1, and TLS 1.2.
  Dynamic Port Scanning: Reads target IPs and unique ports (e.g., 443, 7443, 8443) directly from a CSV.
  Handshake Bypass: Implements a custom TrustAllCertsPolicy to extract metadata from expired, self-signed, or untrusted certificates without failing.
  Deep Metadata Extraction: * Common Name (CN): Intelligent parsing of complex or multiple CN entries.
    EKU: Brute-force OID parsing for Enhanced Key Usage.
    SANs: Full extraction of Subject Alternative Names.
    Status: Auto-detects and flags Self-Signed certificates.
  Dual Output: Generates an interactive, sortable UI (Out-GridView) and exports a clean CSV report.
  
📋 Prerequisites
  PowerShell 5.1 or higher
  Permissions: Ability to run scripts (Set-ExecutionPolicy RemoteSigned).
  Input File: A file named sites.csv in the same directory as the script.
  
CSV Format Requirement
  The sites.csv must include at least the following columns:

Code snippet
  IP,Port
  10.201.115.114,443
  10.201.115.115,7443

🛠️ Usage
  1. Clone this repository or download the .ps1 file.
  2. Place your target list in sites.csv.
  3. Run the script:
    PowerShell:
    .\Cert_Auditor.ps1
  4. View results in the pop-up window or open Cert_Audit_Results.csv.

🔍 How it Works
  The script uses a legacy HttpWebRequest engine rather than the modern SslStream. This is critical for connecting to older hardware that strictly adheres to older SSPI implementations.It handles "Null-Value" exceptions   gracefully—if a certificate has an empty Subject or Issuer field, the script labels it as Unknown/Empty rather than crashing, ensuring your entire audit finishes even if some devices return malformed data.

📄 Output Fields
  Field        Description
  IPAddress    The destination IP being audited.
  Port         The specific port used for the handshake.
  Status       Categorized as CA Signed, Self-Signed, or ERROR.
  CommonName   The primary identity on the certificate.
  Issuer       The entity that signed the certificate.
  Expiration   Date and time the certificate expires.
  DaysLeft     Integer count of days remaining until expiration.
  SANsSubject  Alternative Names (DNS/IP).
  EKU          Enhanced Key Usage (e.g., Server   Authentication).
</p>
