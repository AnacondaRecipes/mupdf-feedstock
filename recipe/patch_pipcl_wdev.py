import sys
import pipcl.wdev
import os

p = os.path.abspath(pipcl.wdev.__file__)
print(f'Patching: {p}', flush=True)
s = open(p, encoding='utf-8').read()

old1 = (
    "            devenv = f'{directory}\\\\Common7\\\\IDE\\\\devenv.com'\n"
    "            assert os.path.isfile( devenv), f'Does not exist: {devenv}'"
)
if old1 not in s:
    idx = s.find("Common7")
    print("ANCHOR 1 NOT FOUND. Actual content near 'Common7':", flush=True)
    print(repr(s[max(0, idx-200):idx+300]), flush=True)
    sys.exit(1)

new1 = (
    "            devenv = f'{directory}\\\\Common7\\\\IDE\\\\devenv.com'\n"
    "            if not os.path.isfile(devenv):\n"
    "                devenv = None"
)
s = s.replace(old1, new1, 1)

old2 = 'vswhere.exe\\" -format json\', capture=1)'
if old2 not in s:
    idx = s.find("vswhere.exe")
    print("ANCHOR 2 NOT FOUND. Actual content near 'vswhere.exe':", flush=True)
    print(repr(s[max(0, idx-100):idx+150]), flush=True)
    sys.exit(1)

new2 = 'vswhere.exe\\" -format json -products *\', capture=1)'
s = s.replace(old2, new2, 1)

with open(p, 'w', encoding='utf-8') as f:
    f.write(s)

print('Patched pipcl.wdev successfully.', flush=True)
