import os
import sys
import subprocess

project_dir = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))

chainSpec = os.path.join(project_dir, "chainSpec.json")
privateKey = ""

privateKeyPath = os.path.join(project_dir, "private_key")
if os.path.exists(privateKeyPath):
    with open(privateKeyPath, "r", encoding="utf-8") as key_file:
        privateKey = key_file.read()

print("input:", sys.argv)

if len(sys.argv) > 1:
    chainSpec = os.path.join(project_dir, sys.argv[1])
    if len(sys.argv) > 2:
        privateKey = sys.argv[2]

if not privateKey:
    raise ValueError("Private Key not appointed")

cmd = f"rm -rf {project_dir}/abi {project_dir}/types {project_dir}/broadcast {project_dir}/out"
print("*** remove abi/types/broadcast/out ***")
print(f"{cmd}")
_, output = subprocess.getstatusoutput(cmd)

worldAddress = ""
worldAddressPath = os.path.join(project_dir, "world_address.txt")
if os.path.exists(worldAddressPath):
    with open(worldAddressPath, "r", encoding="utf-8") as address_file:
        worldAddress = address_file.read()

extra = ""
# if worldAddress:
#     extra = f"--world {worldAddress.strip()}"

cmd = f"pnpm mud deploy {extra} --chainSpec {chainSpec.strip()} --deployerPrivateKey {privateKey.strip()}"
print("*** start deploy ***")
print(f"{cmd}")
_, output = subprocess.getstatusoutput(cmd)
if not os.path.exists(os.path.join(project_dir, "logs")):
    os.mkdir(os.path.join(project_dir, "logs"))
with open(os.path.join(project_dir, "logs", "deploy.log"), "w", encoding="utf-8") as output_file:
    output_file.write(output)
print(output)
print("*** end deploy ***")
