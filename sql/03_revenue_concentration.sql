-- Os resultados consideram somente pedidos com o status 'delivered'

-- 3. O faturamento está concentrado em poucos elementos?

-- 3.1 Top 10 categorias por faturamento

WITH faturamento_categoria AS (
    SELECT
        p.category_name,
        SUM(oi.total_value) AS faturamento
    FROM fact_order_items AS oi
    INNER JOIN dim_products AS p
        ON oi.product_id = p.product_id
    INNER JOIN fact_orders AS o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY p.category_name
),

ranking AS (
    SELECT
        category_name,
        faturamento * 100.0 / SUM(faturamento) OVER () AS percentual_faturamento
    FROM faturamento_categoria
)

SELECT
    category_name,
    ROUND(percentual_faturamento, 2) AS percentual_faturamento,
    ROUND(
        SUM(percentual_faturamento) OVER (ORDER BY percentual_faturamento DESC), 2
    ) AS percentual_acumulado
FROM ranking
ORDER BY percentual_faturamento DESC
LIMIT 10;


-- 3.2 Concentração do faturamento nas 5, 10 e 20 principais categorias

WITH faturamento_categoria AS (
    SELECT
        p.category_name,
        SUM(oi.total_value) AS faturamento
    FROM fact_order_items AS oi
    INNER JOIN dim_products AS p
        ON oi.product_id = p.product_id
    INNER JOIN fact_orders AS o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY p.category_name
),

ranking AS (
    SELECT
        category_name,
        faturamento * 100.0 / SUM(faturamento) OVER () AS percentual_faturamento
    FROM faturamento_categoria
),

acumulado AS (
    SELECT
        category_name,
        percentual_faturamento,
        SUM(percentual_faturamento) OVER (ORDER BY percentual_faturamento DESC
        ) AS percentual_acumulado,
        ROW_NUMBER() OVER (ORDER BY percentual_faturamento DESC
        ) AS ranking
    FROM ranking
)

SELECT
    CASE
        WHEN ranking = 5 THEN 'Top 5'
        WHEN ranking = 10 THEN 'Top 10'
        WHEN ranking = 20 THEN 'Top 20'
    END AS grupo,
    ROUND(percentual_acumulado, 2) AS percentual_acumulado
FROM acumulado
WHERE ranking IN (5, 10, 20)
ORDER BY ranking;


-- 3.3 Top 10 clientes por faturamento

WITH faturamento_clientes AS (
    SELECT
        c.customer_id,
        SUM(oi.total_value) AS faturamento
    FROM fact_order_items AS oi
    INNER JOIN fact_orders AS o
        ON oi.order_id = o.order_id
    INNER JOIN dim_customers AS c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_id
),

ranking AS (
    SELECT
        customer_id,
        faturamento * 100.0 / SUM(faturamento) OVER () AS percentual_faturamento
    FROM faturamento_clientes
)

SELECT
    customer_id,
    ROUND(percentual_faturamento, 2) AS percentual_faturamento,
    ROUND(
        SUM(percentual_faturamento) OVER (ORDER BY percentual_faturamento DESC), 2
    ) AS percentual_acumulado
FROM ranking
ORDER BY percentual_faturamento DESC
LIMIT 10;


-- 3.4 Concentração do faturamento nos 5, 10 e 20 principais clientes

WITH faturamento_cliente AS (
    SELECT
        c.customer_id,
        SUM(oi.total_value) AS faturamento
    FROM fact_order_items AS oi
    INNER JOIN fact_orders AS o
        ON oi.order_id = o.order_id
    INNER JOIN dim_customers AS c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_id
),

ranking AS (
    SELECT
        customer_id,
        faturamento * 100.0 / SUM(faturamento) OVER () AS percentual_faturamento
    FROM faturamento_cliente
),

acumulado AS (
    SELECT
        customer_id,
        percentual_faturamento,
        SUM(percentual_faturamento) OVER (ORDER BY percentual_faturamento DESC
        ) AS percentual_acumulado,
        ROW_NUMBER() OVER (ORDER BY percentual_faturamento DESC
        ) AS ranking
    FROM ranking
)

SELECT
    CASE
        WHEN ranking = 5 THEN 'Top 5'
        WHEN ranking = 10 THEN 'Top 10'
        WHEN ranking = 20 THEN 'Top 20'
    END AS grupo,
    ROUND(percentual_acumulado, 2) AS percentual_acumulado
FROM acumulado
WHERE ranking IN (5, 10, 20)
ORDER BY ranking;


-- 3.5 Top 10 produtos por faturamento

WITH faturamento_produto AS (
    SELECT
        p.product_id,
        SUM(oi.total_value) AS faturamento
    FROM fact_order_items AS oi
    INNER JOIN dim_products AS p
        ON oi.product_id = p.product_id
    INNER JOIN fact_orders AS o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY p.product_id
),

ranking AS (
    SELECT
        product_id,
        faturamento * 100.0 / SUM(faturamento) OVER () AS percentual_faturamento
    FROM faturamento_produto
)

SELECT
    product_id,
    ROUND(percentual_faturamento, 2) AS percentual_faturamento,
    ROUND(
        SUM(percentual_faturamento) OVER (ORDER BY percentual_faturamento DESC), 2
    ) AS percentual_acumulado
FROM ranking
ORDER BY percentual_faturamento DESC
LIMIT 10;


-- 3.6 Concentração do faturamento nos 5, 10 e 20 principais produtos

WITH faturamento_produto AS (
    SELECT
        p.product_id,
        SUM(oi.total_value) AS faturamento
    FROM fact_order_items AS oi
    INNER JOIN dim_products AS p
        ON oi.product_id = p.product_id
    INNER JOIN fact_orders AS o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY p.product_id
),

ranking AS (
    SELECT
        product_id,
        faturamento * 100.0 / SUM(faturamento) OVER () AS percentual_faturamento
    FROM faturamento_produto
),

acumulado AS (
    SELECT
        product_id,
        percentual_faturamento,
        SUM(percentual_faturamento) OVER (ORDER BY percentual_faturamento DESC
        ) AS percentual_acumulado,
        ROW_NUMBER() OVER (ORDER BY percentual_faturamento DESC
        ) AS ranking
    FROM ranking
)

SELECT
    CASE
        WHEN ranking = 5 THEN 'Top 5'
        WHEN ranking = 10 THEN 'Top 10'
        WHEN ranking = 20 THEN 'Top 20'
    END AS grupo,
    ROUND(percentual_acumulado, 2) AS percentual_acumulado
FROM acumulado
WHERE ranking IN (5, 10, 20)
ORDER BY ranking;


-- 3.7 Top 10 vendedores por faturamento

WITH faturamento_vendedor AS (
    SELECT
        s.seller_id,
        SUM(oi.total_value) AS faturamento
    FROM fact_order_items AS oi
    INNER JOIN dim_sellers AS s
        ON oi.seller_id = s.seller_id
    INNER JOIN fact_orders AS o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY s.seller_id
),

ranking AS (
    SELECT
        seller_id,
        faturamento * 100.0 / SUM(faturamento) OVER () AS percentual_faturamento
    FROM faturamento_vendedor
)

SELECT
    seller_id,
    ROUND(percentual_faturamento, 2) AS percentual_faturamento,
    ROUND(
        SUM(percentual_faturamento) OVER (ORDER BY percentual_faturamento DESC), 2
    ) AS percentual_acumulado
FROM ranking
ORDER BY percentual_faturamento DESC
LIMIT 10;


-- 3.8 Concentração do faturamento nos 5, 10 e 20 principais vendedores

WITH faturamento_vendedor AS (
    SELECT
        s.seller_id,
        SUM(oi.total_value) AS faturamento
    FROM fact_order_items AS oi
    INNER JOIN dim_sellers AS s
        ON oi.seller_id = s.seller_id
    INNER JOIN fact_orders AS o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY s.seller_id
),

ranking AS (
    SELECT
        seller_id,
        faturamento * 100.0 / SUM(faturamento) OVER () AS percentual_faturamento
    FROM faturamento_vendedor
),

acumulado AS (
    SELECT
        seller_id,
        percentual_faturamento,
        SUM(percentual_faturamento) OVER (ORDER BY percentual_faturamento DESC
        ) AS percentual_acumulado,
        ROW_NUMBER() OVER (ORDER BY percentual_faturamento DESC
        ) AS ranking
    FROM ranking
)

SELECT
    CASE
        WHEN ranking = 5 THEN 'Top 5'
        WHEN ranking = 10 THEN 'Top 10'
        WHEN ranking = 20 THEN 'Top 20'
    END AS grupo,
    ROUND(percentual_acumulado, 2) AS percentual_acumulado
FROM acumulado
WHERE ranking IN (5, 10, 20)
ORDER BY ranking;


-- A partir deste ponto, será investigado por que as categorias
-- apresentam alta concentração do faturamento.

-- 3.9 Quantidade de produtos e faturamento médio nas 20 principais categorias por faturamento

WITH analise_categoria AS (
    SELECT
        p.category_name,
        SUM(oi.total_value) AS faturamento,
        COUNT(DISTINCT p.product_id) AS qtde_produtos,
        ROUND(
            SUM(oi.total_value) / COUNT(DISTINCT p.product_id), 2
        ) AS faturamento_medio_por_produto
    FROM fact_order_items AS oi
    INNER JOIN dim_products AS p
        ON oi.product_id = p.product_id
    INNER JOIN fact_orders AS o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY p.category_name
)

SELECT
    category_name,
    qtde_produtos,
    ROUND(
        qtde_produtos * 100.0 / SUM(qtde_produtos) OVER (), 2
    ) AS percentual_produtos,
    faturamento_medio_por_produto
FROM analise_categoria
ORDER BY faturamento DESC
LIMIT 20;