#Roll up Canvas subaccounts into schools and colleges

import pandas as pd

# Read the CSV file (assuming it's named "subaccounts.csv")
df = pd.read_csv("subaccounts.csv")

# Create a dictionary to store the parent-child relationships
parent_child_map = {}

# Populate the dictionary with parent-child relationships
for _, row in df.iterrows():
    parent_id = row["parent_account"]
    child_id = row["id"]
    if parent_id not in parent_child_map:
        parent_child_map[parent_id] = []
    parent_child_map[parent_id].append(child_id)

# Function to recursively find the top-level parent account
def find_top_level_parent(account_id):
    if account_id in parent_child_map:
        return find_top_level_parent(parent_child_map[account_id][0])
    return account_id

# Create a dictionary to store the School_College values
school_college_map = {}

# Populate the dictionary with School_College values
for _, row in df.iterrows():
    account_id = row["id"]
    parent_id = row["parent_account"]
    top_level_parent = find_top_level_parent(account_id)
    if parent_id == 1:
        school_college_map[account_id] = row["subaccount"]
    elif top_level_parent in school_college_map:
        school_college_map[account_id] = school_college_map[top_level_parent]
    else:
        # If the top-level parent is not found, use the subaccount name
        school_college_map[account_id] = row["subaccount"]

# Add the School_College column to the DataFrame
df["School_College"] = df["id"].map(school_college_map)

# Print the updated DataFrame
print("Updated DataFrame:")
print(df[["id", "subaccount", "parent_account", "School_College"]])

# Optionally, you can save the updated DataFrame to a new CSV file
df.to_csv("subaccounts_with_school_college.csv", index=False)

# Print a success message
print("\nUpdated DataFrame saved to 'subaccounts_with_school_college.csv'")
