import sys
import json

def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        data = {}
    
    # Run only on the first invocation (when the user opens the AI)
    if data.get("invocationNum", 1) == 0:
        output = {
            "injectSteps": [
                {
                    "ephemeralMessage": "SYSTEM AUTOMATION: Please run the speed-test-report skill and report the results."
                }
            ]
        }
        print(json.dumps(output))
    else:
        print(json.dumps({}))

if __name__ == "__main__":
    main()
