import os

file_path = r"c:\Users\Bigyan\Downloads\TreatUp\index.html"

with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
skip = False
button_replaced = False

for line in lines:
    # Replace Button
    if 'id="view-full-menu-btn"' in line and not button_replaced:
        new_lines.append('                <a href="menu.html" class="btn btn-outline" style="font-size: 1.1rem; padding: 15px 40px; text-decoration: none;">View Full Menu</a>\n')
        button_replaced = True
        continue
    
    # Skip the old button lines if they were multi-line (the previous view showed it as multi-line)
    # Line 226: <button id="view-full-menu-btn" class="btn btn-outline"
    # Line 227: style="font-size: 1.1rem; padding: 15px 40px; cursor: pointer;">View Full Menu</button>
    # My simple check above might miss the second line.
    
    # Let's refine the logic.
    
    if 'id="full-menu"' in line and 'class="full-menu-container"' in line:
        skip = True
    
    if skip:
        # Check for end of container
        # The container ends at line 776 which is a </div> before another </div> and </section>
        # This is risky with just string matching.
        pass
    else:
        new_lines.append(line)

# This python script approach is getting complicated because of state tracking.
# Using accurate line numbers from my previous `view_file` is safer.
