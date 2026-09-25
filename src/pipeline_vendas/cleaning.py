import pandas as pd

def select_relevant_columns(dfs: dict[str, pd.DataFrame]) -> dict[str, pd.DataFrame]:
    """
    Seleciona as colunas relevantes para as etapas posteriores da pipeline.

    Parameters
    ----------
    dfs : dict[str, pd.DataFrame]
        Dicionário contendo os DataFrames a serem processados.

    Returns
    -------
    dict[str, pd.DataFrame]
        Dicionário contendo os DataFrames após a seleção das colunas
        relevantes para o projeto.
    """

    dfs["customers"] = dfs["customers"].drop(columns = "customer_zip_code_prefix")

    dfs["sellers"] = dfs["sellers"].drop(columns = "seller_zip_code_prefix")

    dfs["products"] = dfs["products"].loc[:, ["product_id", "product_category_name"]]

    dfs["orders"] = (dfs["orders"].drop(columns = 
    ["order_approved_at",
     "order_delivered_carrier_date",
     "order_delivered_customer_date",
     "order_estimated_delivery_date"]))

    dfs["order_items"] = dfs["order_items"].drop(columns="shipping_limit_date")

    return dfs