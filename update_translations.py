import json
import re

def update_app_translations():
    fpath = 'd:/KULIAH/SEMESTER 6/CAPSTONE/smartworklife_mobile/lib/app/data/services/app_translations.dart'
    
    with open('translations_to_add.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
        
    en_trans = data['en']
    id_trans = data['id']
    
    with open(fpath, 'r', encoding='utf-8') as f:
        content = f.read()
        
    # Build blocks
    en_block = "\n      // --- Auto-generated Snackbar Translations (EN) ---\n"
    for k, v in en_trans.items():
        v_escaped = v.replace("'", "\\'")
        en_block += f"      '{k}': '{v_escaped}',\n"
        
    id_block = "\n      // --- Auto-generated Snackbar Translations (ID) ---\n"
    for k, v in id_trans.items():
        v_escaped = v.replace("'", "\\'")
        id_block += f"      '{k}': '{v_escaped}',\n"
        
    # Let's insert into 'en_US' right before 'language_changed': 'Language has been successfully changed.',
    content = content.replace("      'language_changed': 'Language has been successfully changed.',", en_block + "      'language_changed': 'Language has been successfully changed.',", 1)
    
    # Let's insert into 'id_ID' right before 'language_changed': 'Bahasa berhasil diubah.',
    content = content.replace("      'language_changed': 'Bahasa berhasil diubah.',", id_block + "      'language_changed': 'Bahasa berhasil diubah.',", 1)
    
    with open(fpath, 'w', encoding='utf-8') as f:
        f.write(content)
        
if __name__ == '__main__':
    update_app_translations()
    print("app_translations.dart updated.")
