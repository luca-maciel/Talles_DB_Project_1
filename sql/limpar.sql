
SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE pg_stat_activity.datname = 'postgres'
  AND pid <> pg_backend_pid();


DROP TABLE IF EXISTS item_pedido_compra CASCADE;
DROP TABLE IF EXISTS pedido_compra CASCADE;
DROP TABLE IF EXISTS item_venda CASCADE;
DROP TABLE IF EXISTS venda CASCADE;
DROP TABLE IF EXISTS movimentacao_estoque CASCADE;
DROP TABLE IF EXISTS estoque CASCADE;
DROP TABLE IF EXISTS produto_fornecedor CASCADE;
DROP TABLE IF EXISTS endereco CASCADE;
DROP TABLE IF EXISTS usuario CASCADE;
DROP TABLE IF EXISTS produto CASCADE;
DROP TABLE IF EXISTS funcionario CASCADE;
DROP TABLE IF EXISTS cliente CASCADE;
DROP TABLE IF EXISTS fornecedor CASCADE;
DROP TABLE IF EXISTS categoria CASCADE;


DROP EXTENSION IF EXISTS pg_trgm;


SELECT COUNT(*) as tabelas_restantes
FROM information_schema.tables
WHERE table_schema = 'public';