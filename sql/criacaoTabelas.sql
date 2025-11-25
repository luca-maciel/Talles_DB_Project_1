CREATE TABLE categoria (
                           id SERIAL PRIMARY KEY,
                           nome VARCHAR(100) NOT NULL UNIQUE,
                           descricao TEXT,
                           data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE fornecedor (
                            id SERIAL PRIMARY KEY,
                            nome VARCHAR(200) NOT NULL,
                            cnpj VARCHAR(18) UNIQUE,
                            telefone VARCHAR(20),
                            email VARCHAR(100),
                            endereco TEXT,
                            cidade VARCHAR(100),
                            estado CHAR(2),
                            data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE produto (
                         id SERIAL PRIMARY KEY,
                         nome VARCHAR(200) NOT NULL,
                         descricao TEXT,
                         codigo_barras VARCHAR(50) UNIQUE,
                         preco_custo DECIMAL(10,2) NOT NULL CHECK (preco_custo >= 0),
                         preco_venda DECIMAL(10,2) NOT NULL CHECK (preco_venda >= 0),
                         estoque_atual INTEGER DEFAULT 0 CHECK (estoque_atual >= 0),
                         estoque_minimo INTEGER DEFAULT 5 CHECK (estoque_minimo >= 0),
                         categoria_id INTEGER NOT NULL,
                         data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                         ativo BOOLEAN DEFAULT true
);


CREATE TABLE cliente (
                         id SERIAL PRIMARY KEY,
                         nome VARCHAR(200) NOT NULL,
                         cpf VARCHAR(14) UNIQUE,
                         telefone VARCHAR(20),
                         email VARCHAR(100),
                         data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE funcionario (
                             id SERIAL PRIMARY KEY,
                             nome VARCHAR(200) NOT NULL,
                             cpf VARCHAR(14) UNIQUE,
                             telefone VARCHAR(20),
                             email VARCHAR(100),
                             cargo VARCHAR(100),
                             salario DECIMAL(10,2) CHECK (salario >= 0),
                             data_admissao DATE,
                             data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE venda (
                       id SERIAL PRIMARY KEY,
                       numero_venda VARCHAR(20) UNIQUE NOT NULL,
                       data_venda TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                       total DECIMAL(10,2) NOT NULL CHECK (total >= 0),
                       status VARCHAR(20) DEFAULT 'FINALIZADA' CHECK (status IN ('PENDENTE', 'FINALIZADA', 'CANCELADA')),
                       cliente_id INTEGER,
                       funcionario_id INTEGER NOT NULL,
                       observacao TEXT
);


CREATE TABLE item_venda (
                            id SERIAL PRIMARY KEY,
                            venda_id INTEGER NOT NULL,
                            produto_id INTEGER NOT NULL,
                            quantidade INTEGER NOT NULL CHECK (quantidade > 0),
                            preco_unitario DECIMAL(10,2) NOT NULL CHECK (preco_unitario >= 0),
                            subtotal DECIMAL(10,2) NOT NULL CHECK (subtotal >= 0)
);


CREATE TABLE estoque (
                         id SERIAL PRIMARY KEY,
                         produto_id INTEGER UNIQUE NOT NULL,
                         quantidade INTEGER DEFAULT 0 CHECK (quantidade >= 0),
                         estoque_minimo INTEGER DEFAULT 5 CHECK (estoque_minimo >= 0),
                         estoque_maximo INTEGER DEFAULT 100 CHECK (estoque_maximo >= 0),
                         localizacao VARCHAR(100),
                         data_ultima_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE usuario (
                         id SERIAL PRIMARY KEY,
                         username VARCHAR(50) UNIQUE NOT NULL,
                         senha VARCHAR(255) NOT NULL,
                         nivel_acesso VARCHAR(20) DEFAULT 'USUARIO' CHECK (nivel_acesso IN ('ADMIN', 'USUARIO', 'OPERADOR')),
                         funcionario_id INTEGER UNIQUE NOT NULL,
                         data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                         ativo BOOLEAN DEFAULT true
);


CREATE TABLE pedido_compra (
                               id SERIAL PRIMARY KEY,
                               numero_pedido VARCHAR(20) UNIQUE NOT NULL,
                               fornecedor_id INTEGER NOT NULL,
                               data_pedido DATE NOT NULL,
                               data_entrega_prevista DATE,
                               data_entrega_real DATE,
                               status VARCHAR(20) DEFAULT 'PENDENTE' CHECK (status IN ('PENDENTE', 'APROVADO', 'RECEBIDO', 'CANCELADO')),
                               total DECIMAL(10,2) NOT NULL CHECK (total >= 0),
                               observacao TEXT
);


CREATE TABLE item_pedido_compra (
                                    id SERIAL PRIMARY KEY,
                                    pedido_id INTEGER NOT NULL,
                                    produto_id INTEGER NOT NULL,
                                    quantidade INTEGER NOT NULL CHECK (quantidade > 0),
                                    preco_unitario DECIMAL(10,2) NOT NULL CHECK (preco_unitario >= 0),
                                    subtotal DECIMAL(10,2) NOT NULL CHECK (subtotal >= 0)
);


CREATE TABLE movimentacao_estoque (
                                      id SERIAL PRIMARY KEY,
                                      produto_id INTEGER NOT NULL,
                                      tipo_movimentacao VARCHAR(20) NOT NULL CHECK (tipo_movimentacao IN ('ENTRADA', 'SAIDA', 'AJUSTE')),
                                      quantidade INTEGER NOT NULL,
                                      data_movimentacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                      documento_referencia VARCHAR(100),
                                      observacao TEXT,
                                      funcionario_id INTEGER NOT NULL
);


CREATE TABLE endereco (
                          id SERIAL PRIMARY KEY,
                          cliente_id INTEGER NOT NULL,
                          tipo_endereco VARCHAR(20) DEFAULT 'RESIDENCIAL' CHECK (tipo_endereco IN ('RESIDENCIAL', 'COMERCIAL', 'ENTREGA')),
                          logradouro VARCHAR(200) NOT NULL,
                          numero VARCHAR(10),
                          complemento VARCHAR(100),
                          bairro VARCHAR(100),
                          cidade VARCHAR(100),
                          estado CHAR(2),
                          cep VARCHAR(9),
                          principal BOOLEAN DEFAULT false
);


CREATE TABLE produto_fornecedor (
                                    id SERIAL PRIMARY KEY,
                                    produto_id INTEGER NOT NULL,
                                    fornecedor_id INTEGER NOT NULL,
                                    preco_compra DECIMAL(10,2) CHECK (preco_compra >= 0),
                                    prazo_entrega INTEGER DEFAULT 7 CHECK (prazo_entrega >= 0),
                                    ativo BOOLEAN DEFAULT true,
                                    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                    UNIQUE(produto_id, fornecedor_id)
);


CREATE INDEX idx_produto_nome_trgm ON produto USING gin (nome gin_trgm_ops);
CREATE INDEX idx_cliente_nome_trgm ON cliente USING gin (nome gin_trgm_ops);
CREATE INDEX idx_fornecedor_nome_trgm ON fornecedor USING gin (nome gin_trgm_ops);


CREATE INDEX idx_venda_data_desc ON venda (data_venda DESC);
CREATE INDEX idx_movimentacao_data_desc ON movimentacao_estoque (data_movimentacao DESC);


CREATE INDEX idx_produto_ativos ON produto (id) WHERE ativo = true;
CREATE INDEX idx_usuario_ativos ON usuario (id) WHERE ativo = true;
CREATE INDEX idx_produto_fornecedor_ativos ON produto_fornecedor (id) WHERE ativo = true;

CREATE UNIQUE INDEX idx_cliente_cpf_unique ON cliente (cpf) WHERE cpf IS NOT NULL;
CREATE UNIQUE INDEX idx_fornecedor_cnpj_unique ON fornecedor (cnpj) WHERE cnpj IS NOT NULL;
CREATE UNIQUE INDEX idx_funcionario_cpf_unique ON funcionario (cpf) WHERE cpf IS NOT NULL;

SELECT setval('categoria_id_seq', 100, false);
SELECT setval('fornecedor_id_seq', 100, false);
SELECT setval('produto_id_seq', 100, false);
SELECT setval('cliente_id_seq', 100, false);
SELECT setval('funcionario_id_seq', 100, false);
SELECT setval('venda_id_seq', 1000, false);

COMMENT ON TABLE categoria IS 'Tabela de categorias de produtos para organização do estoque';
COMMENT ON COLUMN produto.estoque_minimo IS 'Quantidade mínima para alerta de reposição';
COMMENT ON COLUMN movimentacao_estoque.tipo_movimentacao IS 'ENTRADA=compra, SAIDA=venda, AJUSTE=inventário';

