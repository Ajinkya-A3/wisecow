# Scripts Overview

This document explains the purpose, usage, and expected output of the utility scripts found in the `/scripts` directory of the wisecow project.

---

## 1. `app_health.py`

**Purpose:**  
Checks if a web application is "up" or "down" by sending an HTTP request and evaluating the response status code.

**Usage:**  
```bash
python scripts/app_health.py <URL>
```
Example:
```bash
python scripts/app_health.py https://google.com
```

**Expected Output:**  
- If the application responds with a status code between 200 and 399:
  ```
  UP: <URL> is responding with status <status_code>
  ```
- If the application is unreachable or returns an error:
  ```
  DOWN: <URL> returned status <status_code>
  ```
  or
  ```
  DOWN: <URL> is not responding. Error: <error_message>
  ```

---

## 2. `health-moniter.sh`

**Purpose:**  
Monitors system health by checking CPU, memory, and disk usage. Alerts are printed to the console and logged to a timestamped file in `/tmp/`.

**Usage:**  
```bash
bash scripts/health-moniter.sh
```

**Expected Output:**  
- Console alerts if thresholds are exceeded:
  - CPU usage > 80% (1-minute average)
  - Memory usage > 80%
  - Disk usage on `/` > 85%
- A log file `/tmp/sys_health_<timestamp>.log` containing detailed health status and alerts.

---

## 3. `log_analyzer.sh`

**Purpose:**  
Analyzes web server access logs (e.g., Apache or Nginx) for common patterns such as 404 errors, most requested pages, and IP addresses with the most requests.

**Usage:**  
```bash
bash scripts/log_analyzer.sh <path_to_access.log>
```
Example:
```bash
bash scripts/log_analyzer.sh scripts/dummy_access.log
```

**Expected Output:**  
- Console summary report:
  - Number of 404 errors
  - Top 10 requested pages
  - Top 10 IP addresses by request count
- A log file `/tmp/log_analysis_<timestamp>.log` with the same report.

---

## 4. `dummy_access.log`

**Purpose:**  
A sample web server log file for testing the `log_analyzer.sh` script.

**Usage:**  
Use as input for the log analyzer:
```bash
bash scripts/log_analyzer.sh scripts/dummy_access.log
```

**Expected Output:**  
A summary report as described above, based on the sample data.

---

## Notes

- All scripts are designed for use in a Linux environment.
- Ensure required dependencies are installed (see Dockerfile for details).
- Output files are timestamped and stored in `/tmp/` for easy access and log rotation.

---