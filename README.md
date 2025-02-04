
## **Step 1: Create a Resource Group**

```bash
az group create --name VulnVMLab-RG --location eastus
```

---

## **Step 2: Create a Virtual Network with Two Subnets**

1. **Create VNet with address space 10.0.0.0/16:**

   ```bash
   az network vnet create \
     --resource-group VulnVMLab-RG \
     --name VulnVMLab-VNet \
     --address-prefix 10.0.0.0/16 \
     --subnet-name VulnerableSubnet \
     --subnet-prefix 10.0.1.0/24
   ```

2. **Add a Management Subnet (10.0.2.0/24):**

   ```bash
   az network vnet subnet create \
     --resource-group VulnVMLab-RG \
     --vnet-name VulnVMLab-VNet \
     --name ManagementSubnet \
     --address-prefix 10.0.2.0/24
   ```

---

## **Step 3: Create a Network Security Group (NSG) for Vulnerable Subnet**

1. **Create the NSG:**

   ```bash
   az network nsg create \
     --resource-group VulnVMLab-RG \
     --name VulnSubnet-NSG \
     --location eastus
   ```

2. **Create an inbound rule to allow traffic only from the Management Subnet (10.0.2.0/24):**

   ```bash
   az network nsg rule create \
     --resource-group VulnVMLab-RG \
     --nsg-name VulnSubnet-NSG \
     --name AllowMgmtSubnet \
     --priority 100 \
     --source-address-prefixes 10.0.2.0/24 \
     --destination-port-ranges '*' \
     --direction Inbound \
     --access Allow \
     --protocol '*' \
     --description "Allow traffic from Management Subnet only"
   ```

3. **Associate the NSG with the Vulnerable Subnet:**

   ```bash
   az network vnet subnet update \
     --resource-group VulnVMLab-RG \
     --vnet-name VulnVMLab-VNet \
     --name VulnerableSubnet \
     --network-security-group VulnSubnet-NSG
   ```

---

## **Step 4: Deploy a Vulnerable VM**

*In this example, we deploy an Ubuntu VM and then later simulate vulnerabilities by leaving default settings or applying misconfigurations via scripts.*

1. **Create a VM in the Vulnerable Subnet:**

   ```bash
   az vm create \
      --resource-group VulnVMLab-RG \
      --name vulnVM01 \
      --image Ubuntu2204 \
      --admin-username azureuser \
      --admin-password 'P@ssw0rd1234!' \
      --vnet-name VulnVMLab-VNet \
      --subnet VulnerableSubnet \
      --public-ip-address "" \
      --no-wait

   ```

   *Note: For lab purposes, you might deliberately use weak credentials or misconfigure the OS after creation (e.g., disable auto-updates or open unnecessary ports).*

  **inject malicious file to trigger Cloud security findings**


## Files Included

- **malicious_file.sh:**  
  A Bash script that performs the following:
  - Installs necessary build dependencies.
  - Downloads and extracts Apache 2.4.23 from the Apache Archive.
  - Configures, compiles, and installs Apache.
  - Starts the Apache server.
  - Appends insecure CGI configurations to the Apache configuration.
  - Creates and tests a CGI script.
  - Attempts a path traversal test.

``` bash

nano malicious_file.sh

chmod +x malicious_file.sh

sudo ./malicious_file.sh

````
---

## **Step 5: Enable Azure Security Center (ASC) for Vulnerability Scanning**

*Note: ASC is usually enabled by default on new subscriptions. To ensure it's set to the Standard tier for enhanced capabilities:*

```bash
az security pricing create --name virtualMachines --tier Standard
```

*Check recommendations and alerts via the portal or CLI (using `az security alert list` or `az security recommendation list`).*

---

## **Step 6: (Optional) Configure Automated Remediation**

1. **Create a simple Logic App or Automation Runbook via CLI:**

   *For a quick runbook example:*

   - **Create an Automation Account:**

     ```bash
     az automation account create \
       --resource-group VulnVMLab-RG \
       --name VulnAutomationAccount \
       --location eastus
     ```

   - **Create a Runbook (use a local file named `remediate_vuln.ps1`):**

     ```bash
     az automation runbook create \
       --automation-account-name VulnAutomationAccount \
       --resource-group VulnVMLab-RG \
       --name RemediateVuln \
       --type PowerShell \
       --description "A simple remediation runbook"
     ```

   - **Upload the Runbook content:**

     ```bash
     az automation runbook replace-content \
       --automation-account-name VulnAutomationAccount \
       --resource-group VulnVMLab-RG \
       --name RemediateVuln \
       --content @remediate_vuln.ps1
     ```

2. **Link the Runbook to ASC Alerts**

   *This involves setting up a Logic App or webhook trigger that calls the runbook when ASC raises an alert. This can be done using ARM templates or the portal; CLI setup may require further scripting.*

---

## **Step 7: Reporting and Documentation**

1. **View Security Recommendations via CLI:**

   ```bash
   az security recommendation list --output table
   ```

2. **Export Alerts for Reporting:**

   ```bash
   az security alert list --output table
   ```


Below is a short summary of your lab:

---

### **Lab Summary**

- **Environment Setup in Azure:**  
  - Created a resource group, virtual network (with separate vulnerable and management subnets), and NSGs using CLI.
  - Deployed a VM in the vulnerable subnet without a public IP for hosting the lab.

- **Vulnerable Apache Installation:**  
  - Compiled and installed Apache 2.4.23 (a vulnerable version) on the Ubuntu VM.
  - Deliberately misconfigured the CGI directory (unsafe CGI settings) to simulate vulnerabilities.

- **Testing & Monitoring:**  
  - Ran tests (CGI script and path traversal) to validate the vulnerabilities.
  - Azure Security (Microsoft Defender for Cloud) can monitor the VM, detect misconfigurations, and recommend remediation steps.

- **Learning Outcome:**  
  Gain hands-on experience provisioning Azure resources, deploying vulnerable software, and understanding how Azure Security identifies and helps remediate vulnerabilities.

---
by#CheikhB