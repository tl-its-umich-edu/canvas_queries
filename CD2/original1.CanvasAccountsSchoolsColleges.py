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

# Function to recursively find all child accounts under a parent account
def find_all_child_accounts(parent_id):
    child_accounts = []
    if parent_id in parent_child_map:
        for child_id in parent_child_map[parent_id]:
            child_accounts.append(child_id)
            child_accounts.extend(find_all_child_accounts(child_id))
    return child_accounts

# Find all child accounts under the top-level account (account_id = 1)
top_level_account_id = 1
all_child_accounts = find_all_child_accounts(top_level_account_id)

# Print the rolled-up subaccounts
print("Rolled-up subaccounts:")
for account_id in all_child_accounts:
    print(f"Subaccount ID: {account_id}")

# Optionally, you can create a new DataFrame with the rolled-up subaccounts
rolled_up_df = df[df["id"].isin(all_child_accounts)]

# Save the rolled-up subaccounts to a new CSV file (e.g., "rolled_up_subaccounts.csv")
rolled_up_df.to_csv("rolled_up_subaccounts.csv", index=False)

# Print a success message
print(f"Rolled-up subaccounts saved to 'rolled_up_subaccounts.csv'")