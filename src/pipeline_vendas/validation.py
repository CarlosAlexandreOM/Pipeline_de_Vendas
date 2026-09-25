import pandas as pd


def validate_data(
    processed_dfs: dict[str, pd.DataFrame],
    transformed_dfs: dict[str, pd.DataFrame],
    formatted_dfs: dict[str, pd.DataFrame]
) -> dict:
    
    """
    Valida a quantidade de registros, a unicidade das chaves primárias
    e a integridade das chaves estrangeiras.

    Parameters
    ----------
    processed_dfs : dict[str, pd.DataFrame]
        Dicionário contendo os DataFrames após a etapa de limpeza
        e tratamento dos dados.

    transformed_dfs : dict[str, pd.DataFrame]
        Dicionário contendo os DataFrames após a etapa de transformação
        e modelagem dos dados.

    formatted_dfs : dict[str, pd.DataFrame]
        Dicionário contendo os DataFrames após a etapa de padronização
        e organização das colunas.

    Returns
    -------
    dict
        Dicionário contendo os resultados das validações. A chave
        ``row_counts`` contém a quantidade de registros antes e depois
        da transformação; ``primary_keys`` contém a verificação da
        unicidade das chaves primárias; e ``foreign_keys`` contém a
        verificação da integridade das chaves estrangeiras.
    """
    
    validation = {}

    validation["row_counts"] = {
        "customers": (
            len(processed_dfs["customers"]),
            len(transformed_dfs["dim_customers"])
        ),
        "orders": (
            len(processed_dfs["orders"]),
            len(transformed_dfs["fact_orders"])
        ),
        "order_items": (
            len(processed_dfs["order_items"]),
            len(transformed_dfs["fact_order_items"])
        ),
        "products": (
            len(processed_dfs["products"]),
            len(transformed_dfs["dim_products"])
        ),
        "sellers": (
            len(processed_dfs["sellers"]),
            len(transformed_dfs["dim_sellers"])
        )
    }

    validation["primary_keys"] = {
        "customer_id": formatted_dfs["dim_customers"]["customer_id"].is_unique,
        "product_id": formatted_dfs["dim_products"]["product_id"].is_unique,
        "seller_id": formatted_dfs["dim_sellers"]["seller_id"].is_unique,
        "date_key": formatted_dfs["dim_date"]["date_key"].is_unique,
        "order_id": formatted_dfs["fact_orders"]["order_id"].is_unique,
        "item_id": formatted_dfs["fact_order_items"]["item_id"].is_unique
    }

    validation["foreign_keys"] = {
        "customer_id": formatted_dfs["fact_orders"]["customer_id"].isin(
            formatted_dfs["dim_customers"]["customer_id"]
        ).all(),

        "order_id": formatted_dfs["fact_order_items"]["order_id"].isin(
            formatted_dfs["fact_orders"]["order_id"]
        ).all(),

        "product_id": formatted_dfs["fact_order_items"]["product_id"].isin(
            formatted_dfs["dim_products"]["product_id"]
        ).all(),

        "seller_id": formatted_dfs["fact_order_items"]["seller_id"].isin(
            formatted_dfs["dim_sellers"]["seller_id"]
        ).all(),

        "purchase_date": formatted_dfs["fact_order_items"]["purchase_date"].isin(
            formatted_dfs["dim_date"]["date_key"]
        ).all()
    }

    return validation