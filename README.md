<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Legacy SSL/TLS Certificate Auditor Documentation</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif; line-height: 1.6; color: #24292e; max-width: 900px; margin: 0 auto; padding: 2rem; }
        h1 { border-bottom: 1px solid #eaecef; padding-bottom: .3em; }
        h2 { border-bottom: 1px solid #eaecef; padding-bottom: .3em; margin-top: 24px; }
        code { background-color: rgba(27,31,35,.05); border-radius: 3px; padding: .2em .4em; font-family: "SFMono-Regular", Consolas, "Liberation Mono", Menlo, monospace; font-size: 85%; }
        pre { background-color: #f6f8fa; border-radius: 3px; padding: 16px; overflow: auto; line-height: 1.45; }
        table { border-spacing: 0; border-collapse: collapse; width: 100%; margin-top: 0; margin-bottom: 16px; }
        table th, table td { padding: 6px 13px; border: 1px solid #dfe2e5; }
        table tr { background-color: #fff; border-top: 1px solid #c6cbd1; }
        table tr:nth-child(2n) { background-color: #f6f8fa; }
        .badge { display: inline-block; padding: 2px 10px; font-weight: 500; border-radius: 20px; background-color: #0366d6; color: white; font-size: 12px; }
    </style>
</head>
<body>

    <h1>Legacy SSL/TLS Certificate Auditor</h1>
    <p><span class="badge">PowerShell 5.1+</span> <span class="badge">SSLv3/TLS Supported</span></p>
    
    <p>A robust PowerShell utility designed to audit SSL/TLS certificates across large internal networks. This script is specifically hardened to handle <strong>legacy hardware</strong> (PDUs, AV gear, older appliances) that may require deprecated protocols or have malformed certificate fields.</p>

    <h2>🚀 Features</h2>
    <ul>
        <li><strong>Legacy Protocol Support:</strong> Explicitly handles <code>SSLv3</code>, <code>TLS 1.0</code>, <code>TLS 1.1</code>, and <code>TLS 1.2</code>.</li>
        <li><strong>Dynamic Port Scanning:</strong> Reads target IPs and unique ports directly from a CSV.</li>
        <li><strong>Handshake Bypass:</strong> Extracts metadata from expired, self-signed, or untrusted certificates using a custom <code>TrustAllCertsPolicy</code>.</li>
        <li><strong>Deep Metadata Extraction:</strong> Parses Common Name (CN), EKU via OID brute-force, and SANs.</li>
        <li><strong>Status Logic:</strong> Automatically flags <strong>Self-Signed</strong> certificates.</li>
    </ul>

    <h2>📋 Prerequisites</h2>
    <p>The script requires an input file named <code>sites.csv</code> in the same directory with the following structure:</p>
    <pre>IP,Port
10.201.115.114,443
10.201.115.115,7443</pre>

    <h2>🛠️ Usage</h2>
    <ol>
        <li>Place your target list in <code>sites.csv</code>.</li>
        <li>Run the script in PowerShell: <code>.\Cert_Auditor.ps1</code></li>
        <li>View the interactive <code>Out-GridView</code> or the generated <code>Cert_Audit_Results.csv</code>.</li>
    </ol>

    <h2>🔍 Technical Details</h2>
    <p>The script utilizes the legacy <code>HttpWebRequest</code> engine. This is critical for connecting to older hardware that strictly adheres to legacy SSPI implementations and may fail with modern <code>HttpClient</code> or <code>SslStream</code> methods. It handles null-value exceptions gracefully, ensuring the audit continues even when encountering malformed certificate subjects.</p>

    <h2>📄 Output Fields</h2>
    <table>
        <thead>
            <tr>
                <th>Field</th>
                <th>Description</th>
            </tr>
        </thead>
        <tbody>
            <tr><td><strong>IPAddress</strong></td><td>The destination IP being audited.</td></tr>
            <tr><td><strong>Port</strong></td><td>The specific port used for the handshake.</td></tr>
            <tr><td><strong>Status</strong></td><td>Categorized as CA Signed, Self-Signed, or ERROR.</td></tr>
            <tr><td><strong>CommonName</strong></td><td>The primary identity on the certificate.</td></tr>
            <tr><td><strong>Issuer</strong></td><td>The entity that signed the certificate.</td></tr>
            <tr><td><strong>Expiration</strong></td><td>Date and time the certificate expires.</td></tr>
            <tr><td><strong>DaysLeft</strong></td><td>Integer count of days remaining.</td></tr>
            <tr><td><strong>SANs</strong></td><td>Subject Alternative Names (DNS/IP).</td></tr>
            <tr><td><strong>EKU</strong></td><td>Enhanced Key Usage (e.g., Server Authentication).</td></tr>
        </tbody>
    </table>

</body>
</html>
