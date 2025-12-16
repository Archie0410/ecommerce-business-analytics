import os
from datetime import datetime, timedelta

import numpy as np
import pandas as pd


def random_date(start: datetime, end: datetime, size: int):
    """Generate a list of random datetimes between start and end."""
    delta = end - start
    return [start + timedelta(days=int(np.random.rand() * delta.days)) for _ in range(size)]


def main():
    base_dir = r"C:\Users\Archana\Desktop\data analysis\E-Commerce-Analytics"
    raw_dir = os.path.join(base_dir, "data", "raw")
    os.makedirs(raw_dir, exist_ok=True)

    np.random.seed(42)

    # Parameters
    n_customers = 1500
    n_products = 300
    n_orders = 8000

    start_date = datetime(2023, 1, 1)
    end_date = datetime(2024, 12, 31)

    # Customers
    countries = ["USA", "Canada", "UK", "Germany", "France", "Australia", "India"]

    customers = pd.DataFrame(
        {
            "customer_id": range(1, n_customers + 1),
            "customer_name": [f"Customer_{i}" for i in range(1, n_customers + 1)],
            "customer_email": [f"customer{i}@example.com" for i in range(1, n_customers + 1)],
            "customer_city": np.random.choice(
                ["New York", "Los Angeles", "Toronto", "London", "Berlin", "Paris", "Sydney", "Mumbai"],
                size=n_customers,
            ),
            "customer_country": np.random.choice(countries, size=n_customers),
            "signup_date": random_date(start_date - timedelta(days=365), start_date, n_customers),
        }
    )

    # Products
    categories = [
        "Electronics",
        "Fashion",
        "Home & Kitchen",
        "Sports",
        "Beauty",
        "Books",
        "Toys",
    ]

    product_base_prices = {
        "Electronics": (50, 800),
        "Fashion": (10, 200),
        "Home & Kitchen": (15, 400),
        "Sports": (20, 300),
        "Beauty": (5, 150),
        "Books": (5, 80),
        "Toys": (8, 120),
    }

    product_rows = []
    for pid in range(1, n_products + 1):
        cat = np.random.choice(categories)
        low, high = product_base_prices[cat]
        price = np.round(np.random.uniform(low, high), 2)
        product_rows.append((pid, f"Product_{pid}", cat, price))

    products = pd.DataFrame(
        product_rows, columns=["product_id", "product_name", "product_category", "unit_price"]
    )

    # Orders
    order_statuses = ["delivered", "shipped", "processing", "cancelled"]
    status_probs = [0.7, 0.15, 0.1, 0.05]

    order_dates = random_date(start_date, end_date, n_orders)

    orders = pd.DataFrame(
        {
            "order_id": range(1, n_orders + 1),
            "customer_id": np.random.randint(1, n_customers + 1, size=n_orders),
            "order_date": order_dates,
            "order_status": np.random.choice(order_statuses, p=status_probs, size=n_orders),
            "shipping_city": np.random.choice(
                ["New York", "Los Angeles", "Toronto", "London", "Berlin", "Paris", "Sydney", "Mumbai"],
                size=n_orders,
            ),
            "shipping_country": np.random.choice(countries, size=n_orders),
        }
    )

    # Order items (1-5 items per order)
    order_items_rows = []
    item_id = 1
    for oid in orders["order_id"]:
        n_items = np.random.randint(1, 6)
        prod_ids = np.random.choice(products["product_id"], size=n_items, replace=True)
        for pid in prod_ids:
            qty = np.random.randint(1, 6)
            price = float(products.loc[products["product_id"] == pid, "unit_price"].iloc[0])
            order_items_rows.append((item_id, oid, pid, qty, price))
            item_id += 1

    order_items = pd.DataFrame(
        order_items_rows, columns=["order_item_id", "order_id", "product_id", "quantity", "price"]
    )

    # Payments
    payment_types = ["credit_card", "debit_card", "paypal", "bank_transfer", "cash_on_delivery"]
    payment_probs = [0.5, 0.2, 0.15, 0.1, 0.05]

    # Compute order totals from order_items
    order_totals = order_items.groupby("order_id")["quantity"].sum().rename("total_items").to_frame()
    order_totals["order_amount"] = (
        order_items.assign(line_total=lambda df: df["quantity"] * df["price"])
        .groupby("order_id")["line_total"]
        .sum()
    )

    payments_rows = []
    for oid, row in order_totals.iterrows():
        # Some orders partially paid or split tender: 1-2 payment rows
        n_pays = 1 if np.random.rand() < 0.9 else 2
        remaining = row["order_amount"]
        for i in range(n_pays):
            if i == n_pays - 1:
                amt = remaining
            else:
                amt = np.round(remaining * np.random.uniform(0.3, 0.7), 2)
                remaining = np.round(remaining - amt, 2)
            payments_rows.append((oid, amt, np.random.choice(payment_types, p=payment_probs)))

    payments = pd.DataFrame(payments_rows, columns=["order_id", "payment_amount", "payment_type"])

    # Save CSVs
    customers.to_csv(os.path.join(raw_dir, "customers.csv"), index=False)
    orders.to_csv(os.path.join(raw_dir, "orders.csv"), index=False)
    order_items.to_csv(os.path.join(raw_dir, "order_items.csv"), index=False)
    products.to_csv(os.path.join(raw_dir, "products.csv"), index=False)
    payments.to_csv(os.path.join(raw_dir, "payments.csv"), index=False)

    print("Generated CSV files in:", raw_dir)


if __name__ == "__main__":
    main()


