"""
generate_data.py
Generates ~20,000 rows of synthetic retail data and writes
02_seed_data.sql ready to import into MySQL.
No external dependencies — uses only Python stdlib.
"""
import random
import string
from datetime import date, timedelta

random.seed(42)

# ── helpers ──────────────────────────────────────────────────────────────────

def rand_date(start, end):
    delta = (end - start).days
    return start + timedelta(days=random.randint(0, delta))

def rand_email(name, uid):
    domains = ["gmail.com", "yahoo.com", "outlook.com", "hotmail.com"]
    slug = name.lower().replace(" ", ".") + str(uid)
    return f"{slug}@{random.choice(domains)}"

def rand_phone():
    return "9" + "".join([str(random.randint(0,9)) for _ in range(9)])

# ── reference data ────────────────────────────────────────────────────────────

REGIONS = [
    (1, "North",  "India"),
    (2, "South",  "India"),
    (3, "East",   "India"),
    (4, "West",   "India"),
    (5, "Central","India"),
]

CITIES_BY_REGION = {
    1: ["Delhi","Chandigarh","Jaipur","Lucknow"],
    2: ["Chennai","Bangalore","Hyderabad","Kochi"],
    3: ["Kolkata","Bhubaneswar","Patna","Guwahati"],
    4: ["Mumbai","Pune","Ahmedabad","Surat"],
    5: ["Bhopal","Nagpur","Raipur","Indore"],
}

FIRST_NAMES = ["Aarav","Aditi","Amit","Ananya","Arjun","Deepa","Gaurav",
               "Isha","Kiran","Manoj","Neha","Priya","Rahul","Riya","Rohan",
               "Sanya","Shruti","Suresh","Tanvi","Vikram"]
LAST_NAMES  = ["Sharma","Verma","Patel","Singh","Kumar","Mehta","Joshi",
               "Gupta","Nair","Reddy","Iyer","Das","Shah","Rao","Mishra"]

CATEGORIES = [
    (1, "Electronics",  "Technology"),
    (2, "Clothing",     "Fashion"),
    (3, "Home & Kitchen","Home"),
    (4, "Books",        "Education"),
    (5, "Sports",       "Lifestyle"),
    (6, "Beauty",       "Personal Care"),
]

PRODUCTS = [
    # (id, name, cat_id, unit_price, cost_price)
    (1,  "Wireless Earbuds",      1, 2499,  900),
    (2,  "Smartphone Cover",      1,  399,  100),
    (3,  "USB-C Hub",             1, 1899,  700),
    (4,  "Bluetooth Speaker",     1, 3499, 1200),
    (5,  "Men's T-Shirt",         2,  599,  180),
    (6,  "Women's Kurta",         2,  899,  280),
    (7,  "Denim Jeans",           2, 1299,  450),
    (8,  "Running Shoes",         5, 2799,  950),
    (9,  "Non-stick Pan",         3,  999,  380),
    (10, "Steel Water Bottle",    3,  449,  130),
    (11, "Air Fryer",             3, 4999, 2200),
    (12, "Fiction Novel",         4,  299,   80),
    (13, "Self-Help Book",        4,  349,   90),
    (14, "Yoga Mat",              5,  799,  260),
    (15, "Cricket Bat",           5, 1599,  600),
    (16, "Face Serum",            6,  899,  300),
    (17, "Moisturiser 50ml",      6,  499,  150),
    (18, "Laptop Stand",          1, 1299,  450),
    (19, "LED Desk Lamp",         3,  799,  280),
    (20, "Protein Shaker Bottle", 5,  349,  100),
]

PAYMENT_MODES  = ["UPI","Credit Card","Debit Card","NetBanking","COD"]
ORDER_STATUSES = ["Completed","Completed","Completed","Pending","Cancelled"]
RETURN_REASONS = ["Defective product","Wrong item delivered",
                  "Changed my mind","Size mismatch","Better price elsewhere"]

# ── generate rows ─────────────────────────────────────────────────────────────

START = date(2023, 1, 1)
END   = date(2024, 12, 31)

NUM_CUSTOMERS = 2000
NUM_ORDERS    = 8000   # → ~20k order_item rows

customers, orders, order_items, returns_rows = [], [], [], []

for cid in range(1, NUM_CUSTOMERS + 1):
    fn  = random.choice(FIRST_NAMES)
    ln  = random.choice(LAST_NAMES)
    rid = random.randint(1, 5)
    city = random.choice(CITIES_BY_REGION[rid])
    customers.append((cid, f"{fn} {ln}", rand_email(f"{fn}{ln}", cid),
                      rand_phone(), city, rid, rand_date(START, END)))

item_id   = 1
return_id = 1

for oid in range(1, NUM_ORDERS + 1):
    cid    = random.randint(1, NUM_CUSTOMERS)
    odate  = rand_date(START, END)
    status = random.choice(ORDER_STATUSES)
    pay    = random.choice(PAYMENT_MODES)
    orders.append((oid, cid, odate, status, pay))

    n_items = random.randint(1, 4)
    picked  = random.sample(PRODUCTS, n_items)
    for prod in picked:
        pid, pname, cat, up, cp = prod
        qty  = random.randint(1, 5)
        disc = random.choice([0, 0, 0, 5, 10, 15])
        order_items.append((item_id, oid, pid, qty, up, disc))

        # ~6 % return rate on Completed orders
        if status == "Completed" and random.random() < 0.06:
            rdate = odate + timedelta(days=random.randint(1, 14))
            returns_rows.append((return_id, oid, pid, rdate,
                                 random.choice(RETURN_REASONS)))
            return_id += 1
        item_id += 1

# ── write SQL ─────────────────────────────────────────────────────────────────

lines = ["USE retail_analytics;\n\n"]

# regions
lines.append("INSERT INTO regions (region_id, region_name, country) VALUES\n")
lines.append(",\n".join(
    f"  ({r[0]}, '{r[1]}', '{r[2]}')" for r in REGIONS) + ";\n\n")

# categories
lines.append("INSERT INTO categories (category_id, category_name, parent_category) VALUES\n")
lines.append(",\n".join(
    f"  ({c[0]}, '{c[1]}', '{c[2]}')" for c in CATEGORIES) + ";\n\n")

# products
lines.append("INSERT INTO products (product_id, product_name, category_id, unit_price, cost_price, stock_qty) VALUES\n")
lines.append(",\n".join(
    f"  ({p[0]}, '{p[1]}', {p[2]}, {p[3]}, {p[4]}, {random.randint(50,500)})"
    for p in PRODUCTS) + ";\n\n")

# customers (batched 500 at a time)
lines.append("-- Customers\n")
batch = 500
for i in range(0, len(customers), batch):
    chunk = customers[i:i+batch]
    lines.append("INSERT INTO customers (customer_id, full_name, email, phone, city, region_id, signup_date) VALUES\n")
    lines.append(",\n".join(
        f"  ({c[0]}, '{c[1]}', '{c[2]}', '{c[3]}', '{c[4]}', {c[5]}, '{c[6]}')"
        for c in chunk) + ";\n\n")

# orders
lines.append("-- Orders\n")
for i in range(0, len(orders), batch):
    chunk = orders[i:i+batch]
    lines.append("INSERT INTO orders (order_id, customer_id, order_date, status, payment_mode) VALUES\n")
    lines.append(",\n".join(
        f"  ({o[0]}, {o[1]}, '{o[2]}', '{o[3]}', '{o[4]}')"
        for o in chunk) + ";\n\n")

# order_items
lines.append("-- Order Items\n")
for i in range(0, len(order_items), batch):
    chunk = order_items[i:i+batch]
    lines.append("INSERT INTO order_items (item_id, order_id, product_id, quantity, unit_price, discount_pct) VALUES\n")
    lines.append(",\n".join(
        f"  ({it[0]}, {it[1]}, {it[2]}, {it[3]}, {it[4]}, {it[5]})"
        for it in chunk) + ";\n\n")

# returns
if returns_rows:
    lines.append("-- Returns\n")
    for i in range(0, len(returns_rows), batch):
        chunk = returns_rows[i:i+batch]
        lines.append("INSERT INTO returns (return_id, order_id, product_id, return_date, reason) VALUES\n")
        lines.append(",\n".join(
            f"  ({r[0]}, {r[1]}, {r[2]}, '{r[3]}', '{r[4]}')"
            for r in chunk) + ";\n\n")

with open("02_seed_data.sql", "w") as f:
    f.writelines(lines)

total_rows = (len(REGIONS) + len(CATEGORIES) + len(PRODUCTS) +
              len(customers) + len(orders) + len(order_items) + len(returns_rows))

print(f"✅ 02_seed_data.sql written")
print(f"   Customers  : {len(customers):,}")
print(f"   Orders     : {len(orders):,}")
print(f"   Order Items: {len(order_items):,}")
print(f"   Returns    : {len(returns_rows):,}")
print(f"   TOTAL ROWS : {total_rows:,}")
