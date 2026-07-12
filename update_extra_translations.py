import re

def update_app_translations():
    fpath = 'd:/KULIAH/SEMESTER 6/CAPSTONE/smartworklife_mobile/lib/app/data/services/app_translations.dart'
    
    with open(fpath, 'r', encoding='utf-8') as f:
        content = f.read()
        
    en_block = """      'account_deleted_pending_desc': 'Your account is in Pending Deletion status for 14 days.',
"""
    id_block = """      'account_deleted_pending_desc': 'Akun Anda masuk ke status Pending Deletion selama 14 hari.',
"""
        
    # Let's insert into 'en_US' right before 'language_changed': 'Language has been successfully changed.',
    content = content.replace("      'language_changed': 'Language has been successfully changed.',", en_block + "      'language_changed': 'Language has been successfully changed.',", 1)
    
    # Let's insert into 'id_ID' right before 'language_changed': 'Bahasa berhasil diubah.',
    content = content.replace("      'language_changed': 'Bahasa berhasil diubah.',", id_block + "      'language_changed': 'Bahasa berhasil diubah.',", 1)
    
    with open(fpath, 'w', encoding='utf-8') as f:
        f.write(content)
        
if __name__ == '__main__':
    update_app_translations()
    print("app_translations.dart updated extra 2.")
