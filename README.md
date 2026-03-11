# SSL/TLS Certificate Auditor

A robust PowerShell utility designed to audit SSL/TLS certificates across large internal networks. This script is specifically hardened to handle new and legacy Web Servers that may require deprecated protocols or have malformed certificate fields.

---

## 🚀 Features

* **Legacy Protocol Support:** Explicitly handles `SSLv3`, `TLS 1.0`, `TLS 1.1`, and `TLS 1.2`.
* **Dynamic Port Scanning:** Reads target IPs and unique ports (e.g., 443, 7443, 8443) directly from a CSV.
* **Handshake Bypass:** Implements a custom `TrustAllCertsPolicy` to extract metadata from expired, self-signed, or untrusted certificates without failing.
* **Deep Metadata Extraction:**
    * **Common Name (CN):** Intelligent parsing of complex or multiple CN entries.
    * **EKU:** Brute-force OID parsing for Enhanced Key Usage.
    * **SANs:** Full extraction of Subject Alternative Names.
    * **Status:** Auto-detects and flags **Self-Signed** certificates.
* **Dual Output:** Generates an interactive, sortable UI (`Out-GridView`) and exports a clean `CSV` report.

---

## 📋 Prerequisites

* **PowerShell 5.1+**
* **Input File:** A file named `sites.csv` must exist in the same directory as the script.

### CSV Format Requirement
Your `sites.csv` should be formatted as follows:

| IP | Port |
| :--- | :--- |
| 10.201.115.114 | 443 |
| 10.201.115.115 | 7443 |

---

## 🛠️ Usage

1.  Place your target list in `sites.csv`.
2.  Run the script:
    ```powershell
    .\Cert_Audit.ps1
    ```
3.  View results in the pop-up window or open `Cert_Audit_Results.csv`.

---

## 🔍 Technical Details

The script uses the legacy `[System.Net.HttpWebRequest]` engine rather than the modern `HttpClient`. This is critical for connecting to older hardware that strictly adheres to legacy SSPI implementations. It handles "Null-Value" exceptions gracefully—if a certificate has an empty Subject or Issuer field, the script labels it as `Unknown/Empty` rather than crashing.

## 📄 Output Fields

| Field | Description |
| :--- | :--- |
| **IPAddress** | The destination IP being audited. |
| **Port** | The specific port used for the handshake. |
| **Status** | Categorized as `CA Signed`, `Self-Signed`, or `ERROR`. |
| **CommonName** | The primary identity on the certificate. |
| **Issuer** | The entity that signed the certificate. |
| **Expiration** | Date and time the certificate expires. |
| **DaysLeft** | Days remaining until expiration. |
| **SANs** | Subject Alternative Names (DNS/IP). |
| **EKU** | Enhanced Key Usage (Server Auth, etc). |

Sample output window:
<img width="1918" height="283" alt="image" src="https://github.com/user-attachments/assets/06bde363-4625-4ecf-8dc9-2eca7caab6c2" />

---

## Logic Flow
<img width="4384" height="2534" alt="image" src="https://github.com/user-attachments/assets/e7bbe9b7-11c2-46fa-aca2-aa27874bf4f7" />

## 🛡️ License
This project is provided "as-is" for internal auditing and administrative purposes.
