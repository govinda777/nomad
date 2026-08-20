import urllib.request
import time
import threading
import sys
from collections import Counter

# Configuration
TARGET_URL = "http://localhost:8080"
NUM_THREADS = 10
stats = {"requests": 0, "status_codes": Counter(), "backends": Counter()}
stop_flag = False

def worker():
    global stop_flag
    while not stop_flag:
        try:
            stats["requests"] += 1
            with urllib.request.urlopen(TARGET_URL, timeout=1) as response:
                status = response.status
                body = response.read().decode('utf-8')
                stats["status_codes"][status] += 1
                if "AWS" in body:
                    stats["backends"]["AWS"] += 1
                elif "GCP" in body:
                    stats["backends"]["GCP"] += 1
                else:
                    stats["backends"]["Other"] += 1
        except urllib.error.HTTPError as e:
            stats["status_codes"][e.code] += 1
            stats["backends"]["Failed"] += 1
        except Exception:
            stats["status_codes"]["Failed/Timeout"] += 1
            stats["backends"]["Failed"] += 1
        time.sleep(0.02) # Small pause to limit CPU utilization

def reporter():
    print("\033[2J\033[H", end="") # Clear screen
    last_req = 0
    while not stop_flag:
        time.sleep(1)
        reqs = stats["requests"]
        rps = reqs - last_req
        last_req = reqs
        
        # Print metrics
        print("\033[H")
        print("\033[1;33m=== SISTEMA DE TESTE DE CARGA REAL-TIME (Módulo 1) ===\033[0m")
        print("Pressione Ctrl+C para encerrar o teste de carga.")
        print("-" * 50)
        print(f"Total Requests: {reqs}")
        print(f"Taxa de Carga:  {rps} req/sec")
        print("\n\033[1;34mDistribuição de Status HTTP:\033[0m")
        for code, count in sorted(stats["status_codes"].items()):
            color = "\033[1;32m" if str(code).startswith("2") else "\033[1;31m"
            print(f"  HTTP {color}{code}\033[0m: {count}")
            
        print("\n\033[1;34mDistribuição por Nuvem (Borda Global):\033[0m")
        for backend, count in sorted(stats["backends"].items()):
            color = "\033[1;33m" if backend == "AWS" else "\033[1;36m"
            if backend == "Failed":
                color = "\033[1;31m"
            print(f"  Nuvem {color}{backend:6}\033[0m: {count}")
        print("-" * 50)

if __name__ == "__main__":
    threads = []
    # Start workers
    for _ in range(NUM_THREADS):
        t = threading.Thread(target=worker)
        t.daemon = True
        t.start()
        threads.append(t)
        
    # Start reporter
    r = threading.Thread(target=reporter)
    r.daemon = True
    r.start()
    
    try:
        while True:
            time.sleep(0.5)
    except KeyboardInterrupt:
        stop_flag = True
        print("\n\033[1;32mTeste de carga finalizado pelo usuário.\033[0m")
        sys.exit(0)
