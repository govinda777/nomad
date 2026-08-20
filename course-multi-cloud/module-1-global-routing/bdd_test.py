import subprocess
import time
import urllib.request
import urllib.error
import sys

def get_timestamp():
    return time.strftime("%H:%M:%S")

def log_step(step_type, message):
    print(f"\033[1;36m[{get_timestamp()}]\033[0m \033[1;34m{step_type:5}\033[0m {message}")

def log_command(command):
    print(f"\033[1;36m[{get_timestamp()}]\033[0m \033[1;30m    >>> [EXEC] {command}\033[0m")

def log_info(message):
    print(f"\033[1;36m[{get_timestamp()}]\033[0m \033[1;32m    >>> [INFO] {message}\033[0m")

def log_response(status, headers, body):
    print(f"\033[1;36m[{get_timestamp()}]\033[0m \033[1;35m    >>> [RESP] HTTP {status}\033[0m")
    # Print server type header if present
    server = headers.get('Server', 'Unknown')
    print(f"\033[1;36m[{get_timestamp()}]\033[0m \033[1;30m               Server: {server}\033[0m")
    # Print preview of body
    body_preview = body.strip().replace('\n', ' ').replace('\r', '')
    if len(body_preview) > 80:
        body_preview = body_preview[:77] + "..."
    print(f"\033[1;36m[{get_timestamp()}]\033[0m \033[1;30m               Body: {body_preview}\033[0m")

class BDDTest:
    def __init__(self):
        self.failed = False

    def given_infrastructure_is_healthy(self):
        log_step("GIVEN", "The multi-cloud infrastructure is up and healthy")
        try:
            # Check AWS direct status
            log_command("curl -s -I http://localhost:8081")
            req = urllib.request.Request("http://localhost:8081", method="HEAD")
            with urllib.request.urlopen(req, timeout=2) as response:
                log_response(response.status, response.headers, "(HEAD response)")
            
            # Check GCP direct status
            log_command("curl -s -I http://localhost:8082")
            req = urllib.request.Request("http://localhost:8082", method="HEAD")
            with urllib.request.urlopen(req, timeout=2) as response:
                log_response(response.status, response.headers, "(HEAD response)")
            
            log_step("AND", "AWS and GCP endpoints are reachable directly")
        except Exception as e:
            print(f"Error checking health: {e}")
            self.failed = True
            raise AssertionError("Infrastructure is not in a healthy state. Run 'make up' first.")

    def when_aws_fails(self):
        log_step("WHEN", "The AWS cloud region experiences a blackout (stopping lb-mock-aws)")
        log_command("docker stop lb-mock-aws")
        result = subprocess.run(["docker", "stop", "lb-mock-aws"], capture_output=True, text=True, check=True)
        log_info(f"Container AWS parado com sucesso: {result.stdout.strip()}")
        log_step("AND", "We wait 6 seconds for the Global Traffic Manager to detect the failure")
        time.sleep(6)

    def then_traffic_is_routed_to_gcp(self):
        log_step("THEN", "The GTM (port 8080) should route traffic to GCP")
        try:
            log_command("curl -s http://localhost:8080")
            with urllib.request.urlopen("http://localhost:8080", timeout=2) as response:
                content = response.read().decode('utf-8')
                log_response(response.status, response.headers, content)
                if "GCP" in content:
                    log_step("PASS", "Traffic successfully failed over to GCP!")
                else:
                    self.failed = True
                    print(f"Response did not contain GCP: {content}")
                    raise AssertionError("GTM did not route to GCP!")
        except Exception as e:
            self.failed = True
            raise AssertionError(f"Failed to query GTM: {e}")

    def and_when_aws_recovers(self):
        log_step("WHEN", "The AWS cloud region recovers (starting lb-mock-aws)")
        log_command("docker start lb-mock-aws")
        result = subprocess.run(["docker", "start", "lb-mock-aws"], capture_output=True, text=True, check=True)
        log_info(f"Container AWS iniciado com sucesso: {result.stdout.strip()}")
        log_step("AND", "We wait 5 seconds for the GTM to detect recovery")
        time.sleep(5)


    def then_traffic_is_routed_back_to_aws(self):
        log_step("THEN", "The GTM should revert traffic back to AWS (Primary)")
        try:
            log_command("curl -s http://localhost:8080")
            with urllib.request.urlopen("http://localhost:8080", timeout=2) as response:
                content = response.read().decode('utf-8')
                log_response(response.status, response.headers, content)
                if "AWS" in content:
                    log_step("PASS", "Traffic successfully failed back to AWS!")
                else:
                    self.failed = True
                    print(f"Response did not contain AWS: {content}")
                    raise AssertionError("GTM did not route back to AWS!")
        except Exception as e:
            self.failed = True
            raise AssertionError(f"Failed to query GTM: {e}")

    def run(self):
        print("\n\033[1;33m[BDD Scenario] Active-Active Global Failover Validation\033[0m")
        try:
            self.given_infrastructure_is_healthy()
            self.when_aws_fails()
            self.then_traffic_is_routed_to_gcp()
            self.and_when_aws_recovers()
            self.then_traffic_is_routed_back_to_aws()
            print("\033[1;32m[RESULT] BDD Scenario Passed Successfully!\033[0m\n")
        except AssertionError as e:
            print(f"\033[1;31m[RESULT] BDD Scenario Failed: {e}\033[0m\n")
            # Always ensure AWS is running again at the end
            log_command("docker start lb-mock-aws")
            subprocess.run(["docker", "start", "lb-mock-aws"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            sys.exit(1)

if __name__ == "__main__":
    BDDTest().run()
