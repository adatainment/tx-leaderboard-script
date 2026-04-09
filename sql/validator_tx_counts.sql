WITH output_hits AS (
  SELECT
    o.payment_cred AS payment_cred,
    t.id AS tx_id
  FROM tx_out o
  JOIN tx t    ON t.id = o.tx_id
  JOIN block b ON b.id = t.block_id
  WHERE o.payment_cred = ANY(%(payment_creds)s)
    AND b.time >= %(window_start)s
    AND b.time <  %(window_end)s
),
mint_hits AS (
  SELECT
    ma.policy AS payment_cred,
    t.id AS tx_id
  FROM ma_tx_mint mtm
  JOIN multi_asset ma ON ma.id = mtm.ident
  JOIN tx t           ON t.id = mtm.tx_id
  JOIN block b        ON b.id = t.block_id
  WHERE ma.policy = ANY(%(payment_creds)s)
    AND b.time >= %(window_start)s
    AND b.time <  %(window_end)s
),
all_hits AS (
  SELECT payment_cred, tx_id FROM output_hits
  UNION ALL
  SELECT payment_cred, tx_id FROM mint_hits
)
SELECT
  payment_cred,
  COUNT(DISTINCT tx_id) AS tx_count
FROM all_hits
GROUP BY payment_cred;
