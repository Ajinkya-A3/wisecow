import requests
import sys

def check_app_status(url, timeout=5):
    try:
        response = requests.get(url, timeout=timeout)
        if 200 <= response.status_code < 400:
            print(f"UP: {url} is responding with status {response.status_code}")
            return True
        else:
            print(f"DOWN: {url} returned status {response.status_code}")
            return False
    except requests.RequestException as e:
        print(f"DOWN: {url} is not responding. Error: {e}")
        return False

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python app_uptime_check.py <URL>")
        sys.exit(1)
    url = sys.argv[1]
    check_app_status(url)