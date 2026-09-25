-- Os resultado consideram somente pedidos com o status 'delivered'

-- 1. Como o desempenho comercial evolui ao longo do período?

-- 1.1 Faturamento anual
SELECT
    d.year AS ano,
    SUM(oi.total_value) AS faturamento
FROM fact_order_items AS oi
INNER JOIN dim_date AS d
    ON oi.purchase_date = d.date_key
INNER JOIN fact_orders AS o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY d.year
ORDER BY d.year;


-- 1.2 Crescimento percentual do faturamento anual

WITH faturamento_anual AS (
    SELECT
        d.year,
        SUM(oi.total_value) AS faturamento
    FROM fact_order_items AS oi
    INNER JOIN dim_date AS d
        ON oi.purchase_date = d.date_key
    INNER JOIN fact_orders AS o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY d.year
),

faturamento_anual_anterior AS (
    SELECT
        year,
        faturamento,
        LAG(faturamento) OVER (ORDER BY year) AS faturamento_ano_anterior
    FROM faturamento_anual
)

SELECT
    year AS ano,
    ROUND(
        ((faturamento - faturamento_ano_anterior) * 100.0) / faturamento_ano_anterior, 2
    ) AS crescimento_faturamento_anual
FROM faturamento_anual_anterior
WHERE faturamento_ano_anterior IS NOT NULL
ORDER BY year;


-- 1.3 Quantidade de dias com vendas por ano

SELECT
    d.year AS ano,
    COUNT(DISTINCT oi.purchase_date) AS qtde_dias
FROM fact_order_items AS oi
INNER JOIN dim_date AS d
    ON oi.purchase_date = d.date_key
INNER JOIN fact_orders AS o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY d.year
ORDER BY d.year;


-- 1.4 Quantidade de pedidos por ano

SELECT
    d.year AS ano,
    COUNT(DISTINCT oi.order_id) AS qtde_pedidos
FROM fact_order_items AS oi
INNER JOIN dim_date AS d
    ON oi.purchase_date = d.date_key
INNER JOIN fact_orders AS o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY d.year
ORDER BY d.year;


-- 1.5 Crescimento percentual da quantidade de pedidos por ano

WITH pedidos_anuais AS (
    SELECT
        d.year,
        COUNT(DISTINCT oi.order_id) AS qtde_pedidos
    FROM fact_order_items AS oi
    INNER JOIN dim_date AS d
        ON oi.purchase_date = d.date_key
    INNER JOIN fact_orders AS o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY d.year
),

pedidos_ano_anterior AS (
    SELECT
        year,
        qtde_pedidos,
        LAG(qtde_pedidos) OVER (ORDER BY year) AS qtde_pedidos_anterior
    FROM pedidos_anuais
)

SELECT
    year AS ano,
    ROUND(
        ((qtde_pedidos - qtde_pedidos_anterior) * 100.0) / qtde_pedidos_anterior, 2
    ) AS crescimento_pedidos_anual
FROM pedidos_ano_anterior
WHERE qtde_pedidos_anterior IS NOT NULL
ORDER BY year;


-- 1.6 Faturamento Mensal

SELECT
    d.year AS ano,
    d.month AS mes,
    SUM(oi.total_value) AS faturamento
FROM fact_order_items AS oi
INNER JOIN dim_date AS d
    ON oi.purchase_date = d.date_key
INNER JOIN fact_orders AS o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY
    d.year,
    d.month;

-- A partir deste ponto, o ano de 2016 não será considerado devido à baixa cobertura temporal, 
-- com poucos dias de vendas registrados.

-- 1.7 Crescimento percentual do faturamento mensal de 2017 e 2018

WITH faturamento_mensal AS (
    SELECT
        d.year,
        d.month,
        SUM(oi.total_value) AS faturamento
    FROM fact_order_items AS oi
    INNER JOIN dim_date AS d
        ON oi.purchase_date = d.date_key
    INNER JOIN fact_orders AS o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
        AND d.year IN (2017, 2018)
    GROUP BY
        d.year,
        d.month
),

faturamento_mensal_anterior AS (
    SELECT
        year,
        month,
        faturamento,
        LAG(faturamento) OVER (PARTITION BY year ORDER BY month) AS faturamento_mes_anterior
    FROM faturamento_mensal
)

SELECT
    year AS ano,
    month AS mes,
    ROUND(
        ((faturamento - faturamento_mes_anterior) * 100.0) / faturamento_mes_anterior, 2
    ) AS crescimento_faturamento_mensal
FROM faturamento_mensal_anterior
WHERE faturamento_mes_anterior IS NOT NULL
ORDER BY year, month;


-- Nessa parte só será considerado os meses de janeiro até agosto,
-- pois 2018 não possui pedidos entregues em setembro.

-- 1.8 Comparando o faturamento entre os meses de 2017 e 2018

WITH faturamento_mensal AS (
    SELECT
        d.year,
        d.month,
        SUM(oi.total_value) AS faturamento
    FROM fact_order_items AS oi
    INNER JOIN dim_date AS d
        ON oi.purchase_date = d.date_key
    INNER JOIN fact_orders AS o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
        AND d.year IN (2017, 2018)
        AND d.month <= 8
    GROUP BY
        d.year,
        d.month
)

SELECT
    f17.month AS mes,
    f17.faturamento AS faturamento_2017,
    f18.faturamento AS faturamento_2018,
    f18.faturamento - f17.faturamento AS diferenca_faturamento,
    ROUND(
        ((f18.faturamento - f17.faturamento) * 100.0) / f17.faturamento, 2
    ) AS diferenca_percentual
FROM faturamento_mensal AS f17
INNER JOIN faturamento_mensal AS f18
    ON f17.month = f18.month
WHERE f17.year = 2017
    AND f18.year = 2018
ORDER BY
    f17.month;


-- 1.9 Comparando o faturamento total de janeiro a agosto de 2017 e 2018

WITH faturamento_mensal AS (
    SELECT
        d.year,
        d.month,
        SUM(oi.total_value) AS faturamento
    FROM fact_order_items AS oi
    INNER JOIN dim_date AS d
        ON oi.purchase_date = d.date_key
    INNER JOIN fact_orders AS o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
        AND d.year IN (2017, 2018)
        AND d.month <= 8
    GROUP BY
        d.year,
        d.month
)

SELECT
    SUM(f17.faturamento) AS faturamento_2017,
    SUM(f18.faturamento) AS faturamento_2018,
    SUM(f18.faturamento) - SUM(f17.faturamento) AS diferenca_faturamento,
    ROUND(
        ((SUM(f18.faturamento) - SUM(f17.faturamento)) * 100.0) / SUM(f17.faturamento), 2
    ) AS diferenca_percentual
FROM faturamento_mensal AS f17
INNER JOIN faturamento_mensal AS f18
    ON f17.month = f18.month
WHERE f17.year = 2017
    AND f18.year = 2018;


-- A partir deste ponto, serão investigados os fatores que contribuíram
-- para o crescimento do faturamento de 2018 em relação a 2017.

-- 2.0 Comparando a quantidade de pedidos entre os meses de 2017 e 2018

WITH pedidos_mensais AS (
    SELECT
        d.year,
        d.month,
        COUNT(DISTINCT oi.order_id) AS qtde_pedidos
    FROM fact_order_items AS oi
    INNER JOIN dim_date AS d
        ON oi.purchase_date = d.date_key
    INNER JOIN fact_orders AS o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
        AND d.year IN (2017, 2018)
        AND d.month <= 8
    GROUP BY
        d.year,
        d.month
)
SELECT
    p17.month AS mes,
    p17.qtde_pedidos AS qtde_pedidos_2017,
    p18.qtde_pedidos AS qtde_pedidos_2018,
    p18.qtde_pedidos - p17.qtde_pedidos AS diferenca_pedidos,
    ROUND(
        (p18.qtde_pedidos - p17.qtde_pedidos) * 100.0 / p17.qtde_pedidos, 2
    ) AS diferenca_percentual
FROM pedidos_mensais AS p17
INNER JOIN pedidos_mensais AS p18
    ON p17.month = p18.month
WHERE p17.year = 2017
    AND p18.year = 2018
ORDER BY p17.month;


-- 2.1 Comparando a quantidade total de pedidos entre janeiro e agosto de 2017 e 2018

WITH pedidos_mensais AS (
    SELECT
        d.year,
        d.month,
        COUNT(DISTINCT oi.order_id) AS qtde_pedidos
    FROM fact_order_items AS oi
    INNER JOIN dim_date AS d
        ON oi.purchase_date = d.date_key
    INNER JOIN fact_orders AS o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
        AND d.year IN (2017, 2018)
        AND d.month <= 8
    GROUP BY
        d.year,
        d.month
)
SELECT
    SUM(p17.qtde_pedidos) AS qtde_pedidos_2017,
    SUM(p18.qtde_pedidos) AS qtde_pedidos_2018,
    SUM(p18.qtde_pedidos) - SUM(p17.qtde_pedidos) AS diferenca_pedidos,
    ROUND(
        (SUM(p18.qtde_pedidos) - SUM(p17.qtde_pedidos)) * 100.0 / SUM(p17.qtde_pedidos), 2
    ) AS diferenca_percentual
FROM pedidos_mensais AS p17
INNER JOIN pedidos_mensais AS p18
    ON p17.month = p18.month
WHERE p17.year = 2017
    AND p18.year = 2018;


-- 2.2 Comparando o ticket médio entre os meses de 2017 e 2018

WITH ticket_medio_mensal AS (
    SELECT
        d.year,
        d.month,
        ROUND(SUM(oi.total_value) / COUNT(DISTINCT oi.order_id), 2) AS ticket_medio
    FROM fact_order_items AS oi
    INNER JOIN dim_date AS d
        ON oi.purchase_date = d.date_key
    INNER JOIN fact_orders AS o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
        AND d.year IN (2017, 2018)
        AND d.month <= 8
    GROUP BY
        d.year,
        d.month
)
SELECT
    t17.month AS mes,
    t17.ticket_medio AS ticket_medio_2017,
    t18.ticket_medio AS ticket_medio_2018,
    ROUND(t18.ticket_medio - t17.ticket_medio, 2) AS diferenca_ticket_medio,
    ROUND(
        (t18.ticket_medio - t17.ticket_medio) * 100.0 / t17.ticket_medio, 2
    ) AS diferenca_percentual
FROM ticket_medio_mensal AS t17
INNER JOIN ticket_medio_mensal AS t18
    ON t17.month = t18.month
WHERE t17.year = 2017
    AND t18.year = 2018
ORDER BY t17.month;