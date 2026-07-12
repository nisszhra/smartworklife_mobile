import os

fpath = 'lib/app/data/services/app_translations.dart'
with open(fpath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# delete lines 60 to 122 (0-indexed)
del lines[60:123]

# Now the indices shift up by 63 lines.
# Old lines 821 to 883 become 821-63 = 758 to 883-63 = 820.
# Let's find the first ID block again.
start_id = -1
for i, l in enumerate(lines):
    if 'Auto-generated Snackbar Translations (ID)' in l:
        start_id = i
        break

if start_id != -1:
    del lines[start_id:start_id+63]

with open(fpath, 'w', encoding='utf-8') as f:
    f.writelines(lines)
