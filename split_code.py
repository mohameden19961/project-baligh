import re

with open('admin-dashboard/index.html', 'r', encoding='utf-8') as f:
    html_content = f.read()

# Extract style
style_match = re.search(r'<style>(.*?)</style>', html_content, re.DOTALL)
if style_match:
    with open('admin-dashboard/style.css', 'w', encoding='utf-8') as f:
        f.write(style_match.group(1).strip())
    html_content = html_content.replace(style_match.group(0), '<link rel="stylesheet" href="style.css">')

# Extract script (the main one, not the CDN links)
# The first scripts are supabase and chartjs. We want the one that starts after <script> and ends with </script> without src.
script_matches = list(re.finditer(r'<script>(.*?)</script>', html_content, re.DOTALL))
for match in script_matches:
    if 'SUPABASE_URL' in match.group(1) or 'initLang' in match.group(1):
        with open('admin-dashboard/app.js', 'w', encoding='utf-8') as f:
            f.write(match.group(1).strip())
        html_content = html_content.replace(match.group(0), '<script src="app.js"></script>')

# Add SweetAlert2 to HTML head before style.css
html_content = html_content.replace('<link rel="stylesheet" href="style.css">', '<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>\n<link rel="stylesheet" href="style.css">')

with open('admin-dashboard/index.html', 'w', encoding='utf-8') as f:
    f.write(html_content)

print("Split completed.")
