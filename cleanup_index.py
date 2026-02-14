import os

file_path = r"c:\Users\Bigyan\Downloads\TreatUp\index.html"

with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
skip_menu = False
menu_div_balance = 0
button_open = False

for line in lines:
    # 1. Handle Button Replacement
    if 'id="view-full-menu-btn"' in line:
        # We found the button start.
        # Write the new anchor tag immediately.
        new_lines.append('                <a href="menu.html" class="btn btn-outline" style="font-size: 1.1rem; padding: 15px 40px; text-decoration: none;">View Full Menu</a>\n')
        button_open = True
        
        # Check if it closes on the same line
        if '</button>' in line:
            button_open = False
        continue # Don't write the original line
        
    if button_open:
        # We are inside the old button tag (multi-line), skipping lines until closed
        if '</button>' in line:
            button_open = False
        continue

    # 2. Handle Hidden Menu Deletion
    if 'id="full-menu"' in line and 'class="full-menu-container"' in line:
        skip_menu = True
        menu_div_balance = 0 # specific balance for this block
    
    if skip_menu:
        # Update balance
        # Note: We must be careful not to count divs inside comments if possible, but simplest approach:
        menu_div_balance += line.count('<div')
        menu_div_balance -= line.count('</div>')
        
        # If balance returns to 0 (or less if malformed, but likely 0), we are done with the block.
        if menu_div_balance <= 0:
            skip_menu = False
        
        continue # Skip this line (it is part of the block to delete)

    # 3. Write line if not skipped
    new_lines.append(line)

with open(file_path, 'w', encoding='utf-8') as f:
    f.writelines(new_lines)
print("Successfully cleaned up index.html")
