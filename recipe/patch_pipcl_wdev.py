import sys
import pipcl.wdev
import os

p = os.path.abspath(pipcl.wdev.__file__)
print(f'Patching: {p}', flush=True)
s = open(p, encoding='utf-8').read()

# --- Fix 1: tolerate missing devenv.com (VS Build Tools has no devenv) ---
old1 = (
    "            devenv = f'{directory}\\\\Common7\\\\IDE\\\\devenv.com'\n"
    "            assert os.path.isfile( devenv), f'Does not exist: {devenv}'"
)
if old1 not in s:
    idx = s.find("Common7")
    print("ANCHOR 1 NOT FOUND:", flush=True)
    print(repr(s[max(0, idx-200):idx+300]), flush=True)
    sys.exit(1)
new1 = (
    "            devenv = f'{directory}\\\\Common7\\\\IDE\\\\devenv.com'\n"
    "            if not os.path.isfile(devenv):\n"
    "                devenv = None"
)
s = s.replace(old1, new1, 1)

# --- Fix 2: vswhere.exe default invocation doesn't list Build Tools SKU ---
old2 = (
    "vss_json = pipcl.run(rf'\"%ProgramFiles(x86)%\\Microsoft Visual Studio"
    "\\Installer\\vswhere.exe\" -format json', capture=1)"
)
if old2 not in s:
    idx = s.find('vswhere.exe" -format json')
    print("ANCHOR 2 NOT FOUND:", flush=True)
    print(repr(s[max(0, idx-150):idx+150]), flush=True)
    sys.exit(1)
new2 = (
    "vss_json = pipcl.run(rf'\"%ProgramFiles(x86)%\\Microsoft Visual Studio"
    "\\Installer\\vswhere.exe\" -format json -products *', capture=1)"
)
s = s.replace(old2, new2, 1)

# --- Fix 3: sort key doesn't recognise 'BuildTools' as a valid grade ---
old3 = "        grades = ['Community', 'Professional', 'Enterprise']"
if old3 not in s:
    idx = s.find("grades = [")
    print("ANCHOR 3 NOT FOUND:", flush=True)
    print(repr(s[max(0, idx-100):idx+150]), flush=True)
    sys.exit(1)
new3 = "        grades = ['BuildTools', 'Community', 'Professional', 'Enterprise']"
s = s.replace(old3, new3, 1)

with open(p, 'w', encoding='utf-8') as f:
    f.write(s)

print('Patched pipcl.wdev successfully.', flush=True)
