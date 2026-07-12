import os
import re
import json

def collect_snackbars(directory):
    results = {}
    pattern = re.compile(r"Get\.snackbar\(\s*['\"]([^'\"]+)['\"]\s*,\s*['\"](.*?)['\"]\s*(?:,|\))")
    
    idx = 1
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(".dart") and file != "app_translations.dart":
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                    
                    matches = pattern.finditer(content)
                    for match in matches:
                        title = match.group(1)
                        msg = match.group(2)
                        
                        if not title.endswith('.tr') and not msg.endswith('.tr'):
                            key_title = f"sb_title_{idx}"
                            key_msg = f"sb_msg_{idx}"
                            
                            if (title, msg) not in results.values():
                                results[idx] = {
                                    'title_id': title,
                                    'msg_id': msg,
                                    'title_en': title, # Placeholder
                                    'msg_en': msg, # Placeholder
                                    'files': [filepath]
                                }
                                idx += 1
                            else:
                                for k, v in results.items():
                                    if v['title_id'] == title and v['msg_id'] == msg:
                                        if filepath not in v['files']:
                                            v['files'].append(filepath)
    return results

if __name__ == '__main__':
    res = collect_snackbars('d:/KULIAH/SEMESTER 6/CAPSTONE/smartworklife_mobile/lib/app/modules')
    with open('snackbars.json', 'w', encoding='utf-8') as f:
        json.dump(res, f, ensure_ascii=False, indent=2)
