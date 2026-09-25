import pandas as pd


def transform_data(dfs: dict[str, pd.DataFrame]) -> dict[str, pd.DataFrame]:
    """Gera um novo dicionário contendo as tabelas após sua modelagem e transformação."""

    new_orders = dfs["orders"].merge(
        dfs["customers"],
        how="left",
        on="customer_id"
    )

    new_orders = new_orders[
        [
            "order_id",
            "customer_unique_id",
            "order_status"
        ]
    ]

    new_customers = (
        dfs["customers"]
        .drop(columns="customer_id")
        .drop_duplicates(subset="customer_unique_id")
    )

    new_order_items = dfs["order_items"].merge(
        dfs["orders"],
        how="left",
        on="order_id"
    )

    new_order_items = new_order_items[
        [
            "order_id",
            "product_id",
            "seller_id",
            "order_purchase_timestamp",
            "price",
            "freight_value"
        ]
    ]

    new_order_items["total_value"] = (
        new_order_items["price"] + new_order_items["freight_value"]
    )

    new_order_items["item_id"] = range(1, len(new_order_items) + 1)

    new_order_items["purchase_date"] = (
        pd.to_datetime(new_order_items["order_purchase_timestamp"])
        .dt.normalize()
    )

    new_order_items = new_order_items.drop(
        columns="order_purchase_timestamp"
    )

    dim_date = pd.DataFrame()

    dim_date["date_key"] = (
        new_order_items["purchase_date"]
        .drop_duplicates()
        .sort_values(ascending=True)
    )

    dim_date["year"] = dim_date["date_key"].dt.year
    dim_date["month"] = dim_date["date_key"].dt.month
    dim_date["name_month"] = dim_date["date_key"].dt.month_name()

    new_dfs = {
        "dim_customers": new_customers,
        "fact_orders": new_orders,
        "dim_products": dfs["products"],
        "dim_sellers": dfs["sellers"],
        "dim_date": dim_date,
        "fact_order_items": new_order_items
    }

    return new_dfs


def format_data(dfs: dict[str, pd.DataFrame]) -> dict[str, pd.DataFrame]:
    """Renomeia e organiza as colunas das tabelas."""

    dfs["dim_customers"] = dfs["dim_customers"].rename(
        columns={"customer_unique_id": "customer_id"}
    )

    dfs["fact_orders"] = dfs["fact_orders"].rename(
        columns={"customer_unique_id": "customer_id"}
    )

    dfs["dim_products"] = dfs["dim_products"].rename(
        columns={"product_category_name": "category_name"}
    )

    dfs["dim_date"]["date_key"] = (
        dfs["dim_date"]["date_key"].dt.strftime("%Y-%m-%d")
    )

    dfs["fact_order_items"]["purchase_date"] = (
        dfs["fact_order_items"]["purchase_date"].dt.strftime("%Y-%m-%d")
    )

    dfs["fact_order_items"] = dfs["fact_order_items"][
        [
            "item_id",
            "order_id",
            "product_id",
            "seller_id",
            "purchase_date",
            "price",
            "freight_value",
            "total_value"
        ]
    ]

    return dfs