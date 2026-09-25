-- Os resultados consideram somente pedidos com o status 'delivered'

-- 2. Quais categorias de produtos e regiões mais contribuem para o faturamento?

-- 2.1 Faturamento e quantidade de itens vendidos por categoria

SELECT
    p.category_name,
    SUM(oi.total_value) AS faturamento,
    COUNT(oi.item_id) AS qtde_itens_vendidos,
    ROUND(
        SUM(oi.total_value) / COUNT(oi.item_id), 2
    ) AS faturamento_medio_por_item
FROM fact_order_items AS oi
INNER JOIN dim_products AS p
    ON oi.product_id = p.product_id
INNER JOIN fact_orders AS o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.category_name
ORDER BY faturamento DESC;


-- 2.2 Faturamento e quantidade de vendedores por estado

SELECT
    s.seller_state AS estado,
    SUM(oi.total_value) AS faturamento,
    COUNT(oi.item_id) AS qtde_itens_vendidos,
    COUNT(DISTINCT s.seller_id) AS qtde_vendedores,
    ROUND(
        SUM(oi.total_value) / COUNT(DISTINCT s.seller_id), 2
    ) AS faturamento_medio_por_vendedor
FROM fact_order_items AS oi
INNER JOIN dim_sellers AS s
    ON oi.seller_id = s.seller_id
INNER JOIN fact_orders AS o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY s.seller_state
ORDER BY faturamento DESC;


-- 2.3 Faturamento e quantidade de vendedores por cidade

SELECT
    s.seller_city AS cidade,
    SUM(oi.total_value) AS faturamento,
    COUNT(oi.item_id) AS qtde_itens_vendidos,
    COUNT(DISTINCT s.seller_id) AS qtde_vendedores,
    ROUND(
        SUM(oi.total_value) / COUNT(DISTINCT s.seller_id), 2
    ) AS faturamento_medio_por_vendedor
FROM fact_order_items AS oi
INNER JOIN dim_sellers AS s
    ON oi.seller_id = s.seller_id
INNER JOIN fact_orders AS o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY s.seller_city
ORDER BY faturamento DESC;


-- 2.4 Faturamento e quantidade de clientes por estado

SELECT
    c.customer_state AS estado,
    SUM(oi.total_value) AS faturamento,
    COUNT(oi.item_id) AS qtde_itens_vendidos,
    COUNT(DISTINCT c.customer_id) AS qtde_clientes,
    ROUND(
        SUM(oi.total_value) / COUNT(DISTINCT c.customer_id), 2
    ) AS faturamento_medio_por_cliente
FROM fact_order_items AS oi
INNER JOIN fact_orders AS o
    ON oi.order_id = o.order_id
INNER JOIN dim_customers AS c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY faturamento DESC;


-- 2.5 Faturamento e quantidade de clientes por cidade

SELECT
    c.customer_city AS cidade,
    SUM(oi.total_value) AS faturamento,
    COUNT(oi.item_id) AS qtde_itens_vendidos,
    COUNT(DISTINCT c.customer_id) AS qtde_clientes,
    ROUND(
        SUM(oi.total_value) / COUNT(DISTINCT c.customer_id), 2
    ) AS faturamento_medio_por_cliente
FROM fact_order_items AS oi
INNER JOIN fact_orders AS o
    ON oi.order_id = o.order_id
INNER JOIN dim_customers AS c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_city
ORDER BY faturamento DESC;