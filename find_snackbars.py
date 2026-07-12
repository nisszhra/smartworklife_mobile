import os
import re

def find_snackbars(directory):
    results = []
    pattern = re.compile(r"Get\.snackbar\(\s*['\"]([^'\"]+)['\"]\s*,\s*(['\"](.*?)['\"]|.*?)\s*(\)|,)")
    
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(".dart") and file != "app_translations.dart":
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                    
                    matches = pattern.finditer(content)
                    for match in matches:
                        title = match.group(1)
                        if not title.endswith('.tr'):
                            # Find line number
                            line_no = content[:match.start()].count('\n') + 1
                            results.append({
                                'file': filepath,
                                'line': line_no,
                                'title': title,
                                'message': match.group(2)
                            })
    return results

if __name__ == '__main__':
    res = find_snackbars('d:/KULIAH/SEMESTER 6/CAPSTONE/smartworklife_mobile/lib/app/modules')
    for r in res:
        print(f"{r['file'].split('lib\\\\app\\\\modules\\\\')[-1]}:{r['line']} - Title: {r['title']} | Msg: {r['message']}")
