from subprocess import Popen
from pathlib import Path
import json
import time
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--u', action='store', help='Docker username', type=str, required=True)
parser.add_argument('--p', action='store', help='Docker password', type=str, required=True)
args = parser.parse_args()

DIRECTORY_PATH = Path(__file__).resolve().parent
print(DIRECTORY_PATH)

init_process = Popen(f'cd "{DIRECTORY_PATH}" && terraform init', shell=True)
init_process.wait()

apply_process = Popen(f'cd "{DIRECTORY_PATH}" && terraform apply', shell=True)
apply_process.wait()

produce_output = Popen(f'cd "{DIRECTORY_PATH}" && terraform output -json > "{DIRECTORY_PATH}/output.json"', shell=True)

with open(f'{DIRECTORY_PATH}/output.json', "r") as file:
    data = json.loads(file.read())

server_ip = data["ec2_global_ips"]["value"][0][0]

print("waiting for server to be built")
time.sleep(5)
print("attempting to enter server")

build_process = Popen(f'cd "{DIRECTORY_PATH}" && sh ./run_build.sh {server_ip} {args.u} {args.p}', shell=True)
build_process.wait()

destroy_process = Popen(f'cd "{DIRECTORY_PATH}" && terraform destroy', shell=True)
destroy_process.wait()
