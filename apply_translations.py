import json
import re
import os

def generate_translations(snackbars_data):
    # Standardize titles
    title_map = {
        'Sukses': 'success',
        'Berhasil': 'success',
        'Tugas Ditambahkan': 'success',
        'Error': 'error',
        'Gagal': 'error',
        '❌ Gagal': 'error',
        '❌ Error': 'error',
        'Info': 'info',
        '⚠️ Info': 'info',
        'Peringatan': 'warning',
        'Validasi': 'warning',
        '⚠️ Izin Diperlukan': 'warning',
        'Pemulihan Akun': 'info',
        'Verifikasi Diperlukan': 'warning',
        'Akun Tidak Ditemukan': 'error',
        'Kotak Masuk Bersih': 'success',
        'Terhapus': 'success',
        'Share': 'info',
    }

    en_translations = {
        'success': 'Success',
        'error': 'Error',
        'info': 'Info',
        'warning': 'Warning'
    }
    
    id_translations = {
        'success': 'Berhasil',
        'error': 'Gagal',
        'info': 'Info',
        'warning': 'Peringatan'
    }

    file_replacements = {} # filepath -> { old_line: new_line }

    for idx, (key, item) in enumerate(snackbars_data.items()):
        title = item['title_id']
        msg = item['msg_id']
        
        # Clean emojis and find generic title
        clean_title = re.sub(r'[^\w\s]', '', title).strip()
        title_key = title_map.get(title, title_map.get(clean_title, 'info'))
        
        # Handle message
        msg_key = f"sb_msg_{idx}"
        
        # Determine if it has interpolation
        has_interpolation = '${' in msg or '$' in msg
        
        base_msg = msg
        append_var = ""
        if has_interpolation:
            # Simplistic handling: split at the first $
            parts = re.split(r'(\$.*)', msg, 1)
            if len(parts) > 1:
                base_msg = parts[0].strip()
                append_var = ' ' + parts[1]
                
        # Simple Translation Dictionary
        id_translations[msg_key] = base_msg
        
        # Attempt simple english translation (rough)
        en_msg = base_msg.replace("Berhasil", "Successfully")\
                         .replace("Gagal", "Failed to")\
                         .replace("dihapus", "deleted")\
                         .replace("menghapus", "delete")\
                         .replace("notulen", "notes")\
                         .replace("tugas", "task")\
                         .replace("membagikan", "share")\
                         .replace("profil", "profile")\
                         .replace("belum", "not yet")\
                         .replace("teman", "friend")
        en_translations[msg_key] = en_msg
        
        # Replacement pattern
        for fpath in item['files']:
            if fpath not in file_replacements:
                file_replacements[fpath] = []
            
            replacement = f"Get.snackbar('{title_key}'.tr, '{msg_key}'.tr"
            if append_var:
                replacement += f" + '{append_var}'"
                
            file_replacements[fpath].append({
                'title': title,
                'msg': msg,
                'title_key': title_key,
                'msg_key': msg_key,
                'append': append_var
            })

    return en_translations, id_translations, file_replacements

def apply_to_dart(replacements):
    import fileinput
    
    for fpath, reps in replacements.items():
        with open(fpath, 'r', encoding='utf-8') as f:
            content = f.read()
            
        for rep in reps:
            # regex replace
            t = re.escape(rep['title'])
            m = re.escape(rep['msg'])
            pattern = re.compile(r"Get\.snackbar\(\s*['\"]" + t + r"['\"]\s*,\s*['\"]" + m + r"['\"]")
            
            new_str = f"Get.snackbar('{rep['title_key']}'.tr, "
            if rep['append']:
                 new_str += f"'{rep['msg_key']}'.tr + '{rep['append']}'"
            else:
                 new_str += f"'{rep['msg_key']}'.tr"
                 
            content = pattern.sub(new_str, content)
            
        with open(fpath, 'w', encoding='utf-8') as f:
            f.write(content)

def update_app_translations(en_trans, id_trans):
    fpath = 'd:/KULIAH/SEMESTER 6/CAPSTONE/smartworklife_mobile/lib/app/data/services/app_translations.dart'
    with open(fpath, 'r', encoding='utf-8') as f:
        content = f.read()
        
    en_block = ""
    for k, v in en_trans.items():
        en_block += f"      '{k}': '{v}',\n"
        
    id_block = ""
    for k, v in id_trans.items():
        id_block += f"      '{k}': '{v}',\n"
        
    # Inject before language selection
    content = content.replace("      // Language Selection", en_block + "\n      // Language Selection", 1)
    # The second replace might fail if we don't distinguish en from id, but we can do a hacky regex
    
    # We will just write a new file if we have to, but this is a rough script.
    # Instead, let's just let the LLM (me) handle app_translations.dart manually via tools if needed, 
    # or write them to a temp file and I can view it.
    with open('translations_to_add.json', 'w') as f:
        json.dump({'en': en_trans, 'id': id_trans}, f, indent=2)

if __name__ == '__main__':
    with open('snackbars.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
        
    en_trans, id_trans, reps = generate_translations(data)
    apply_to_dart(reps)
    update_app_translations(en_trans, id_trans)
    print("Dart files updated. Translations saved to translations_to_add.json")
