# Active Directory Toolkit

A collection of PowerShell scripts for managing, validating, and troubleshooting Active Directory environments.
This toolkit is useful for sysadmins performing domain controller promotions, pre/post validations, port checks, 
registry configuration, and AD site exports.

---

## 📁 Contents

### 1. **dc_promotion.ps1**
Automates promotion of a server to a Domain Controller using IFM (Install From Media).
- Parameters: DomainName, ReplicationSourceDC, SiteName, IFMPath, etc.
- Prompts for credentials
- Customizable paths for logs, database, and SYSVOL

### 2. **dc_pre_validation.ps1**
Scans servers and ports using `portqry.exe` to validate readiness of critical services.
- Modular and reusable
- Accepts hashtable input for server roles and ports

### 3. **dc_post_validation.ps1** (coming soon)
Validates post-promotion health: checks SYSVOL, services, replication status, etc.

### 4. **check_dc_for_KB.ps1** (coming soon)
Queries all domain controllers to check if a specific hotfix (KB) is installed.

### 5. **export_ad_sites_by_site.ps1** (coming soon)
Exports all AD sites, subnets, and server memberships into a clean CSV file.

### 6. **query_server_for_reg_key.ps1** / **add_registry_key.ps1** (coming soon)
Push or query registry keys on domain controllers — useful for Change Auditor, security hardening, etc.

---

## ✅ Requirements

- PowerShell 5.1+
- RSAT Tools (`Install-WindowsFeature RSAT-ADDS`)
- `portqry.exe` (for validation scripts)

---

## 🔒 Credentials

Several scripts will prompt for credentials using `Get-Credential` for secure access to remote servers.

---

## 📜 License

MIT License (or add your preferred one here)

---

## 🚀 Getting Started

Clone this repo and run scripts individually, or integrate them into your automation workflows.
