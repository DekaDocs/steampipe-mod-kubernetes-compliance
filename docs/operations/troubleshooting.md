# Root Cause Analysis: [Brief Problem Title]

**Date:** `YYYY-MM-DD`
**Status:** `Investigating / Resolved / Monitoring`
**Related System/Feature:** `[Feature/System Name]`
**Reference Ticket:** `[Link to Jira/Trello/GitHub Issue]`

---

## 1. Problem Summary

### Problem
> [Briefly describe the problem from user or system perspective. Example: "User cannot create Load Balancer service because usage is not recorded."]

### Expected Behavior
> [Describe what should happen if there's no problem.]
> 1. ...
> 2. ...

### Actual Behavior
> [Describe what actually happened.]
> 1. ...
> 2. ...

---

## 2. Analysis Conclusion

> [Provide high-level conclusion of the root cause after investigation. Example: "There's a mismatch between IP Pool data in database (CloudekaIPPool) and IP Pool configuration used by MetalLB (IPAddressPool)."]

---

## 3. Deep Analysis & Investigation

### Timeline & Investigation Steps
1. **Step 1:** [Example: "Check logs on `dekagpu-service-webhook` pod when Load Balancer service is created."]
2. **Step 2:** [Example: "Debug function `database.GetIPPoolBasedOnIP` to see returned values."]
3. **Step 3:** [Example: "Compare `CloudekaIPPool` table in database with `IPAddressPool` CRD in cluster."]

### Observations & Findings
* **Finding 1: Error Log Appeared**
    > Found error in logs:
    > ```log
    > [Paste relevant log snippet here]
    > ```
    > This error indicates failure in `[function/process name]`.

* **Finding 2: Code Analysis**
    > After examining code in file `[filename]` at line `[line number]`, found that function `[function name]` doesn't handle cases where no IP Pool is found, thus returning default value `0` for ID, causing "record not found" error in subsequent process.
    > ```go
    > // Relevant code snippet
    > func GetIPPoolBasedOnIP(ipaddress string) (*structMySQL.IPPool, error) {
    >   // ...
    >   // At the end, function returns empty object, not error
    >   ippoolModel := structMySQL.IPPool{}
    >   return &ippoolModel, nil // <-- THIS IS THE SOURCE OF PROBLEM
    > }
    > ```

* **Finding 3: Configuration Differences**
    > IP Pool data in database is not synchronized with what exists in MetalLB.
    >
    > **Database (`CloudekaIPPool`):**
    > `[Data or screenshot]`
    >
    > **MetalLB (`IPAddressPool`):**
    > `[Data or screenshot]`

---

## 4. Root Cause

> [Mention 1-3 main root causes that are most fundamental.]
> 1. **Logic Error:** Function `GetIPPoolBasedOnIP` has incorrect error handling, where it doesn't return error when IP Pool is not found.
> 2. **Data Desynchronization:** There's inconsistency between IP Pool managed by Core Validation (database) and IP Pool actually used by MetalLB.

---

## 5. Action Plan & Solution

### Short-term Solution (Immediate Fix)
* **Task 1: Fix Error Handling**
    * **Description:** Modify function `GetIPPoolBasedOnIP` to return `error` when no matching IP Pool is found.
    * **PIC:** `[Name]`
    * **Status:** `To Do`

* **Task 2: Synchronize IP Pool**
    * **Description:** Add missing IP Pool data to `CloudekaIPPool` table to match MetalLB configuration. This will resolve the issue for new Load Balancer creation.
    * **PIC:** `[Name]`
    * **Status:** `To Do`

### Long-term Solution
* **Task 1: Create Automatic Synchronization Mechanism**
    * **Description:** Build a *controller* or *job* that periodically checks and aligns data between `IPAddressPool` CRD and `CloudekaIPPool` table in database to prevent this issue from recurring.
    * **PIC:** `[Name]`
    * **Status:** `Backlog`

### Handling Existing Cases (If Any)
> [Explain plan to handle resources (like Load Balancers) that were already created with wrong conditions.]
> - Need to create script to detect Load Balancers that exist in Kubernetes but not recorded in database.
> - ...

