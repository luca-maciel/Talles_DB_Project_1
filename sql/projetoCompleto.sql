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




CREATE EXTENSION IF NOT EXISTS pg_trgm;




CREATE TABLE IF NOT EXISTS categoria (
                                         id SERIAL PRIMARY KEY,
                                         nome VARCHAR(100) NOT NULL UNIQUE,
                                         descricao TEXT,
                                         data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);




CREATE TABLE IF NOT EXISTS fornecedor (
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




CREATE TABLE IF NOT EXISTS produto (
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




CREATE TABLE IF NOT EXISTS cliente (
                                       id SERIAL PRIMARY KEY,
                                       nome VARCHAR(200) NOT NULL,
                                       cpf VARCHAR(14) UNIQUE,
                                       telefone VARCHAR(20),
                                       email VARCHAR(100),
                                       data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);




CREATE TABLE IF NOT EXISTS funcionario (
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




CREATE TABLE IF NOT EXISTS venda (
                                     id SERIAL PRIMARY KEY,
                                     numero_venda VARCHAR(20) UNIQUE NOT NULL,
                                     data_venda TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                     total DECIMAL(10,2) NOT NULL CHECK (total >= 0),
                                     status VARCHAR(20) DEFAULT 'FINALIZADA' CHECK (status IN ('PENDENTE', 'FINALIZADA', 'CANCELADA')),
                                     cliente_id INTEGER,
                                     funcionario_id INTEGER NOT NULL,
                                     observacao TEXT
);




CREATE TABLE IF NOT EXISTS item_venda (
                                          id SERIAL PRIMARY KEY,
                                          venda_id INTEGER NOT NULL,
                                          produto_id INTEGER NOT NULL,
                                          quantidade INTEGER NOT NULL CHECK (quantidade > 0),
                                          preco_unitario DECIMAL(10,2) NOT NULL CHECK (preco_unitario >= 0),
                                          subtotal DECIMAL(10,2) NOT NULL CHECK (subtotal >= 0)
);




CREATE TABLE IF NOT EXISTS estoque (
                                       id SERIAL PRIMARY KEY,
                                       produto_id INTEGER UNIQUE NOT NULL, -- RELACIONAMENTO 1:1 com Produto
                                       quantidade INTEGER DEFAULT 0 CHECK (quantidade >= 0),
                                       estoque_minimo INTEGER DEFAULT 5 CHECK (estoque_minimo >= 0),
                                       estoque_maximo INTEGER DEFAULT 100 CHECK (estoque_maximo >= 0),
                                       localizacao VARCHAR(100),
                                       data_ultima_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);




CREATE TABLE IF NOT EXISTS usuario (
                                       id SERIAL PRIMARY KEY,
                                       username VARCHAR(50) UNIQUE NOT NULL,
                                       senha VARCHAR(255) NOT NULL,
                                       nivel_acesso VARCHAR(20) DEFAULT 'USUARIO' CHECK (nivel_acesso IN ('ADMIN', 'USUARIO', 'OPERADOR')),
                                       funcionario_id INTEGER UNIQUE NOT NULL,
                                       data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                       ativo BOOLEAN DEFAULT true
);




CREATE TABLE IF NOT EXISTS pedido_compra (
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




CREATE TABLE IF NOT EXISTS item_pedido_compra (
                                                  id SERIAL PRIMARY KEY,
                                                  pedido_id INTEGER NOT NULL,
                                                  produto_id INTEGER NOT NULL,
                                                  quantidade INTEGER NOT NULL CHECK (quantidade > 0),
                                                  preco_unitario DECIMAL(10,2) NOT NULL CHECK (preco_unitario >= 0),
                                                  subtotal DECIMAL(10,2) NOT NULL CHECK (subtotal >= 0)
);




CREATE TABLE IF NOT EXISTS movimentacao_estoque (
                                                    id SERIAL PRIMARY KEY,
                                                    produto_id INTEGER NOT NULL,
                                                    tipo_movimentacao VARCHAR(20) NOT NULL CHECK (tipo_movimentacao IN ('ENTRADA', 'SAIDA', 'AJUSTE')),
                                                    quantidade INTEGER NOT NULL,
                                                    data_movimentacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                                    documento_referencia VARCHAR(100),
                                                    observacao TEXT,
                                                    funcionario_id INTEGER NOT NULL
);




CREATE TABLE IF NOT EXISTS endereco (
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




CREATE TABLE IF NOT EXISTS produto_fornecedor (
                                                  id SERIAL PRIMARY KEY,
                                                  produto_id INTEGER NOT NULL,
                                                  fornecedor_id INTEGER NOT NULL,
                                                  preco_compra DECIMAL(10,2) CHECK (preco_compra >= 0),
                                                  prazo_entrega INTEGER DEFAULT 7 CHECK (prazo_entrega >= 0),
                                                  ativo BOOLEAN DEFAULT true,
                                                  data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                                  UNIQUE(produto_id, fornecedor_id)
);




INSERT INTO categoria (nome, descricao, data_cadastro) VALUES
                                                           ('Presentes Românticos','Itens para casais, kits e lembranças románticas','2024-01-05 09:00:00'),
                                                           ('Presentes Infantis','Brinquedos e artigos para crianças','2024-01-06 09:15:00'),
                                                           ('Presentes Corporativos','Kits e brindes corporativos','2024-01-07 09:30:00'),
                                                           ('Decoração','Peças decorativas para casa','2024-01-08 09:45:00'),
                                                           ('Velas e Aromas','Velas, difusores e essências','2024-01-09 10:00:00'),
                                                           ('Jóias e Acessórios','Bijuterias e acessórios','2024-01-10 10:15:00'),
                                                           ('Papelaria Criativa','Cadernos, canetas e itens de papelaria','2024-01-11 10:30:00'),
                                                           ('Brinquedos Educativos','Brinquedos com propósito pedagógico','2024-01-12 10:45:00'),
                                                           ('Relógios','Relógios de pulso e de parede','2024-01-13 11:00:00'),
                                                           ('Kits Presente','Conjuntos prontos para presente','2024-01-14 11:15:00'),
                                                           ('Cosméticos','Produtos de beleza e cuidados pessoais','2024-01-15 11:20:00'),
                                                           ('Cama Mesa Banho','Artigos para cama, mesa e banho','2024-01-16 11:25:00'),
                                                           ('Perfumaria','Perfumes e colônias','2024-01-17 11:30:00'),
                                                           ('Eletrônicos','Aparelhos eletrônicos e acessórios','2024-01-18 11:35:00'),
                                                           ('Casa e Jardim','Produtos para casa e jardim','2024-01-19 11:40:00')
ON CONFLICT (nome) DO NOTHING;




INSERT INTO fornecedor (nome, cnpj, telefone, email, endereco, cidade, estado, data_cadastro) VALUES
                                                                                                  ('Presentes Elegantes Ltda','12.345.678/0001-01','11999990001','vendas@presenteselegantes.com.br','Av. Central, 100','São Paulo','SP','2024-01-05 08:00:00'),
                                                                                                  ('Brinquedos Educa Mais','22.444.555/0001-02','11999990002','contato@educamais.com','R. das Flores, 200','São Paulo','SP','2024-01-06 08:05:00'),
                                                                                                  ('Decora Home Presentes','33.333.444/0001-03','11999990003','pedidos@decorahome.com','Av. do Lar, 50','Belo Horizonte','MG','2024-01-07 08:10:00'),
                                                                                                  ('Aromas e Velas Finas','44.444.555/0001-04','11999990004','atendimento@aromasevelas.com','R. Perfume, 10','Curitiba','PR','2024-01-08 08:15:00'),
                                                                                                  ('Jóias Prata & Cia','55.555.666/0001-05','11999990005','joias@pratacia.com','Av. Joias, 400','Fortaleza','CE','2024-01-09 08:20:00'),
                                                                                                  ('Papelaria Criativa Art','66.666.777/0001-06','11999990006','criativa@papelariaart.com','R. Papel, 77','Porto Alegre','RS','2024-01-10 08:25:00'),
                                                                                                  ('Relógios Precision','77.777.888/0001-07','11999990007','precision@relogios.com','Av. Tempo, 900','Recife','PE','2024-01-11 08:30:00'),
                                                                                                  ('Personaliza Fácil','88.888.999/0001-08','11999990008','personaliza@facil.com','R. Arte, 33','Manaus','AM','2024-01-12 08:35:00'),
                                                                                                  ('Kits Presente Premium','99.111.222/0001-09','11999990009','premium@kitspresente.com','Av. Gourmet, 12','Salvador','BA','2024-01-13 08:40:00'),
                                                                                                  ('Artigos Religiosos Fé','10.222.333/0001-10','11999990010','fe@artigosreligiosos.com','R. Fé, 101','Brasília','DF','2024-01-14 08:45:00'),
                                                                                                  ('Lembrancinhas Festa','11.222.333/0001-11','11999990011','festa@lembrancinhas.com','R. Alegria, 5','São Paulo','SP','2024-01-15 08:50:00'),
                                                                                                  ('Cosméticos Natureza','12.222.333/0001-12','11999990012','natureza@cosmeticos.com','Av. Beleza, 77','Belo Horizonte','MG','2024-01-16 08:55:00'),
                                                                                                  ('Casa Conforto','13.222.333/0001-13','11999990013','conforto@casa.com','R. Lar, 66','Curitiba','PR','2024-01-17 09:00:00'),
                                                                                                  ('Livros Inspiradores','14.222.333/0001-14','11999990014','inspiradores@livros.com','Av. Letras, 9','Porto Alegre','RS','2024-01-18 09:05:00'),
                                                                                                  ('Tech Presentes','15.222.333/0001-15','11999990015','tech@presentes.com','R. Bits, 404','Recife','PE','2024-01-19 09:10:00'),
                                                                                                  ('Moda Presente','16.222.333/0001-16','11999990016','moda@presente.com','Av. Moda, 300','Fortaleza','CE','2024-01-20 09:15:00'),
                                                                                                  ('Import Presentes','17.222.333/0001-17','11999990017','import@presentes.com','R. Mundo, 1','Salvador','BA','2024-01-21 09:20:00'),
                                                                                                  ('Presentes Nacional','18.222.333/0001-18','11999990018','nacional@presentes.com','Av. Brasil, 900','Manaus','AM','2024-01-22 09:25:00'),
                                                                                                  ('Artesanato Brasil','19.222.333/0001-19','11999990019','brasil@artesanato.com','R. Tradição, 23','Brasília','DF','2024-01-23 09:30:00'),
                                                                                                  ('Luxo Presentes','20.222.333/0001-20','11999990020','luxo@presentes.com','Av. Ouro, 10','São Paulo','SP','2024-01-24 09:35:00')
ON CONFLICT (cnpj) DO NOTHING;




INSERT INTO produto (nome, descricao, codigo_barras, preco_custo, preco_venda, estoque_atual, estoque_minimo, categoria_id, data_cadastro, ativo) VALUES
                                                                                                                                                      ('Caixa Chocolate Premium','Caixa 12 chocolates finos','7890000000001',30.00,89.90,2,10,1,'2024-01-05 10:00:00',true),
                                                                                                                                                      ('Urso Pelúcia Grande','Urso 50cm cor marrom','7890000000002',20.00,79.90,3,8,1,'2024-01-06 10:05:00',true),
                                                                                                                                                      ('Vela Aromática Lavanda','Vela aromática 200g','7890000000003',5.00,29.90,1,15,5,'2024-01-07 10:10:00',true),
                                                                                                                                                      ('Colar Coração Prata','Colar prata 925 pingente','7890000000004',50.00,159.90,2,5,6,'2024-01-08 10:15:00',true),
                                                                                                                                                      ('Kit Velas Aromáticas','Kit 3 velas aromáticas','7890000000005',18.00,49.90,12,20,5,'2024-01-09 10:20:00',true),
                                                                                                                                                      ('Caneca Térmica','Caneca térmica 350ml','7890000000006',12.00,39.90,8,15,10,'2024-01-10 10:25:00',true),
                                                                                                                                                      ('Pulseira Prata','Pulseira prata 925','7890000000007',40.00,129.90,6,10,6,'2024-01-11 10:30:00',true),
                                                                                                                                                      ('Perfume Importado','Perfume francês 100ml','7890000000008',120.00,299.00,4,8,13,'2024-01-12 10:35:00',true),
                                                                                                                                                      ('Relógio de Pulso','Relógio analógico couro','7890000000009',80.00,199.00,25,10,9,'2024-01-13 10:40:00',true),
                                                                                                                                                      ('Álbum de Fotos','Álbum casamento capa couro','7890000000010',30.00,89.90,30,15,7,'2024-01-14 10:45:00',true),
                                                                                                                                                      ('Caneta Tinteiro','Caneta tinteiro premium','7890000000011',40.00,129.90,18,8,7,'2024-01-15 10:50:00',true),
                                                                                                                                                      ('Caderno Decorado','Caderno capa dura floral','7890000000012',10.00,34.90,45,20,7,'2024-01-16 10:55:00',true),
                                                                                                                                                      ('Quebra-Cabeça 1000pç','Quebra-cabeça paisagem','7890000000013',20.00,59.90,22,10,8,'2024-01-17 11:00:00',true),
                                                                                                                                                      ('Boneca de Pano','Boneca artesanal de pano','7890000000014',12.00,45.90,28,12,2,'2024-01-18 11:05:00',true),
                                                                                                                                                      ('Carrinho Madeira','Carrinho madeira educativo','7890000000015',10.00,39.90,20,8,8,'2024-01-19 11:10:00',true),
                                                                                                                                                      ('Kit Pintura','Kit pintura aquarela','7890000000016',25.00,79.90,15,6,8,'2024-01-20 11:15:00',true),
                                                                                                                                                      ('Caneca Cerâmica','Caneca 300ml estampa','7890000000017',8.00,29.90,85,30,10,'2024-01-21 11:20:00',true),
                                                                                                                                                      ('Camiseta Estampada','Camiseta algodão personalizada','7890000000018',15.00,49.90,120,40,10,'2024-01-22 11:25:00',true),
                                                                                                                                                      ('Porta-retratos Digital','Porta-retratos digital 7"','7890000000019',60.00,149.90,35,12,4,'2024-01-23 11:30:00',true),
                                                                                                                                                      ('Luminária Mesa LED','Luminária LED USB color','7890000000020',30.00,79.90,42,15,4,'2024-01-24 11:35:00',true),
                                                                                                                                                      ('Vaso Decorativo','Vaso cerâmica pintado mão','7890000000021',25.00,69.90,38,12,4,'2024-01-25 11:40:00',true),
                                                                                                                                                      ('Kit Chá Gourmet','Kit 6 chás especiais','7890000000022',20.00,59.90,55,20,10,'2024-01-26 11:45:00',true),
                                                                                                                                                      ('Cesta Café Manhã','Cesta produtos café','7890000000023',60.00,129.90,25,8,10,'2024-01-27 11:50:00',true),
                                                                                                                                                      ('Livro Poemas','Livro capa dura romântico','7890000000024',18.00,45.90,65,25,7,'2024-01-28 11:55:00',true),
                                                                                                                                                      ('Agenda 2024','Agenda executiva couro','7890000000025',40.00,89.90,48,18,7,'2024-01-29 12:00:00',true),
                                                                                                                                                      ('Fone Bluetooth','Fone bluetooth over-ear','7890000000026',90.00,199.00,32,12,14,'2024-01-30 12:05:00',true),
                                                                                                                                                      ('Caixa Som JBL','Caixa som bluetooth','7890000000027',120.00,299.00,18,6,14,'2024-01-31 12:10:00',true),
                                                                                                                                                      ('Kit Barbear','Kit barbear madeira','7890000000028',50.00,159.90,22,8,11,'2024-02-01 12:15:00',true),
                                                                                                                                                      ('Pijama Casal','Pijama algodão matching','7890000000029',40.00,129.90,16,6,1,'2024-02-02 12:20:00',true),
                                                                                                                                                      ('Toalha Banho','Toalha algodão 70x140cm','7890000000030',15.00,49.90,75,25,12,'2024-02-03 12:25:00',true),
                                                                                                                                                      ('Jogo Cama Queen','Jogo cama algodão','7890000000031',120.00,199.00,12,4,12,'2024-02-04 12:30:00',true),
                                                                                                                                                      ('Tapete Decorativo','Tapete lã 120x170cm','7890000000032',70.00,149.90,8,3,4,'2024-02-05 12:35:00',true),
                                                                                                                                                      ('Abajur Quarto','Abajur madeira tecido','7890000000033',25.00,89.90,15,5,4,'2024-02-06 12:40:00',true),
                                                                                                                                                      ('Kit Jardim','Kit jardinagem 8 peças','7890000000034',30.00,79.90,10,4,15,'2024-02-07 12:45:00',true),
                                                                                                                                                      ('Vela de Soja','Vela natural 150g','7890000000035',8.00,24.90,60,20,5,'2024-02-08 12:50:00',true),
                                                                                                                                                      ('Difusor Ambiente','Difusor bambu 200ml','7890000000036',15.00,49.90,35,15,5,'2024-02-09 12:55:00',true),
                                                                                                                                                      ('Brinquedo Montar','Brinquedo educativo madeira','7890000000037',18.00,59.90,28,10,8,'2024-02-10 13:00:00',true),
                                                                                                                                                      ('Quebra-Cabeça 500pç','Quebra-cabeça infantil','7890000000038',12.00,39.90,42,15,8,'2024-02-11 13:05:00',true),
                                                                                                                                                      ('Livro Infantil','Livro capa dura colorido','7890000000039',10.00,29.90,85,30,2,'2024-02-12 13:10:00',true),
                                                                                                                                                      ('Boneco Articulado','Boneco 30cm articulado','7890000000040',15.00,49.90,38,12,2,'2024-02-13 13:15:00',true),
                                                                                                                                                      ('Jogo Tabuleiro','Jogo estratégia familiar','7890000000041',25.00,79.90,22,8,8,'2024-02-14 13:20:00',true),
                                                                                                                                                      ('Puzzle 3D','Puzzle arquitetura 216pç','7890000000042',30.00,99.90,18,6,8,'2024-02-15 13:25:00',true),
                                                                                                                                                      ('Kit Maquiagem','Kit básico maquiagem','7890000000043',35.00,119.90,25,8,11,'2024-02-16 13:30:00',true),
                                                                                                                                                      ('Perfume Nacional','Perfume 50ml fragrância suave','7890000000044',40.00,129.90,32,10,13,'2024-02-17 13:35:00',true),
                                                                                                                                                      ('Creme Hidratante','Creme corporal 200ml','7890000000045',12.00,39.90,55,20,11,'2024-02-18 13:40:00',true),
                                                                                                                                                      ('Shampoo Natural','Shampoo 300ml orgânico','7890000000046',8.00,29.90,68,25,11,'2024-02-19 13:45:00',true),
                                                                                                                                                      ('Sabonete Líquido','Sabonete 500ml neutro','7890000000047',6.00,19.90,90,30,11,'2024-02-20 13:50:00',true),
                                                                                                                                                      ('Desodorante Roll','Desodorante 50ml','7890000000048',5.00,16.90,120,40,11,'2024-02-21 13:55:00',true),
                                                                                                                                                      ('Creme Dental','Creme dental 90g','7890000000049',3.00,9.90,200,50,11,'2024-02-22 14:00:00',true),
                                                                                                                                                      ('Escova Dental','Escova dental macia','7890000000050',4.00,12.90,150,40,11,'2024-02-23 14:05:00',true)
ON CONFLICT (codigo_barras) DO NOTHING;




INSERT INTO cliente (nome, cpf, telefone, email, data_cadastro) VALUES
                                                                    ('Ana Silva', '000.000.000-01', '11999990021', 'ana.silva@email.com', '2024-01-05 13:00:00'),
                                                                    ('Carlos Santos', '000.000.000-02', '11999990022', 'carlos.santos@email.com', '2024-01-06 13:05:00'),
                                                                    ('Mariana Oliveira', '000.000.000-03', '11999990023', 'mariana.oliveira@email.com', '2024-01-07 13:10:00'),
                                                                    ('João Pereira', '000.000.000-04', '11999990024', 'joao.pereira@email.com', '2024-01-08 13:15:00'),
                                                                    ('Juliana Costa', '000.000.000-05', '11999990025', 'juliana.costa@email.com', '2024-01-09 13:20:00'),
                                                                    ('Pedro Rodrigues', '000.000.000-06', '11999990026', 'pedro.rodrigues@email.com', '2024-01-10 13:25:00'),
                                                                    ('Fernanda Alves', '000.000.000-07', '11999990027', 'fernanda.alves@email.com', '2024-01-11 13:30:00'),
                                                                    ('Ricardo Lima', '000.000.000-08', '11999990028', 'ricardo.lima@email.com', '2024-01-12 13:35:00'),
                                                                    ('Amanda Souza', '000.000.000-09', '11999990029', 'amanda.souza@email.com', '2024-01-13 13:40:00'),
                                                                    ('Bruno Martins', '000.000.000-10', '11999990030', 'bruno.martins@email.com', '2024-01-14 13:45:00'),
                                                                    ('Patrícia Ferreira', '000.000.000-11', '11999990031', 'patricia.ferreira@email.com', '2024-01-15 13:50:00'),
                                                                    ('Roberto Ribeiro', '000.000.000-12', '11999990032', 'roberto.ribeiro@email.com', '2024-01-16 13:55:00'),
                                                                    ('Carla Carvalho', '000.000.000-13', '11999990033', 'carla.carvalho@email.com', '2024-01-17 14:00:00'),
                                                                    ('Daniel Dias', '000.000.000-14', '11999990034', 'daniel.dias@email.com', '2024-01-18 14:05:00'),
                                                                    ('Luciana Barbosa', '000.000.000-15', '11999990035', 'luciana.barbosa@email.com', '2024-01-19 14:10:00'),
                                                                    ('Eduardo Nunes', '000.000.000-16', '11999990036', 'eduardo.nunes@email.com', '2024-01-20 14:15:00'),
                                                                    ('Sandra Rocha', '000.000.000-17', '11999990037', 'sandra.rocha@email.com', '2024-01-21 14:20:00'),
                                                                    ('Marcos Moreira', '000.000.000-18', '11999990038', 'marcos.moreira@email.com', '2024-01-22 14:25:00'),
                                                                    ('Tatiane Cardoso', '000.000.000-19', '11999990039', 'tatiane.cardoso@email.com', '2024-01-23 14:30:00'),
                                                                    ('Felipe Correia', '000.000.000-20', '11999990040', 'felipe.correia@email.com', '2024-01-24 14:35:00'),
                                                                    ('Vanessa Teixeira', '000.000.000-21', '11999990041', 'vanessa.teixeira@email.com', '2024-01-25 14:40:00'),
                                                                    ('Rafael Melo', '000.000.000-22', '11999990042', 'rafael.melo@email.com', '2024-01-26 14:45:00'),
                                                                    ('Larissa Castro', '000.000.000-23', '11999990043', 'larissa.castro@email.com', '2024-01-27 14:50:00'),
                                                                    ('Diego Monteiro', '000.000.000-24', '11999990044', 'diego.monteiro@email.com', '2024-01-28 14:55:00'),
                                                                    ('Priscila Lopes', '000.000.000-25', '11999990045', 'priscila.lopes@email.com', '2024-01-29 15:00:00'),
                                                                    ('Gustavo Vieira', '000.000.000-26', '11999990046', 'gustavo.vieira@email.com', '2024-01-30 15:05:00'),
                                                                    ('Simone Duarte', '000.000.000-27', '11999990047', 'simone.duarte@email.com', '2024-01-31 15:10:00'),
                                                                    ('Leonardo Campos', '000.000.000-28', '11999990048', 'leonardo.campos@email.com', '2024-02-01 15:15:00'),
                                                                    ('Elaine Santana', '000.000.000-29', '11999990049', 'elaine.santana@email.com', '2024-02-02 15:20:00'),
                                                                    ('Roberto Moraes', '000.000.000-30', '11999990050', 'roberto.moraes@email.com', '2024-02-03 15:25:00'),
                                                                    ('Cristina Pires', '000.000.000-31', '11999990051', 'cristina.pires@email.com', '2024-02-04 15:30:00'),
                                                                    ('Alexandre Fonseca', '000.000.000-32', '11999990052', 'alexandre.fonseca@email.com', '2024-02-05 15:35:00'),
                                                                    ('Renata Machado', '000.000.000-33', '11999990053', 'renata.machado@email.com', '2024-02-06 15:40:00'),
                                                                    ('André Guimarães', '000.000.000-34', '11999990054', 'andre.guimaraes@email.com', '2024-02-07 15:45:00'),
                                                                    ('Viviane Abreu', '000.000.000-35', '11999990055', 'viviane.abreu@email.com', '2024-02-08 15:50:00'),
                                                                    ('Sérgio Tavares', '000.000.000-36', '11999990056', 'sergio.tavares@email.com', '2024-02-09 15:55:00'),
                                                                    ('Lilian Dantas', '000.000.000-37', '11999990057', 'lilian.dantas@email.com', '2024-02-10 16:00:00'),
                                                                    ('Paulo Peixoto', '000.000.000-38', '11999990058', 'paulo.peixoto@email.com', '2024-02-11 16:05:00'),
                                                                    ('Mônica Farias', '000.000.000-39', '11999990059', 'monica.farias@email.com', '2024-02-12 16:10:00'),
                                                                    ('Hugo Maciel', '000.000.000-40', '11999990060', 'hugo.maciel@email.com', '2024-02-13 16:15:00'),
                                                                    ('Clara Mendes', '000.000.000-41', '11999990061', 'clara.mendes@email.com', '2024-02-14 16:20:00'),
                                                                    ('Igor Rocha', '000.000.000-42', '11999990062', 'igor.rocha@email.com', '2024-02-15 16:25:00'),
                                                                    ('Sofia Nunes', '000.000.000-43', '11999990063', 'sofia.nunes@email.com', '2024-02-16 16:30:00'),
                                                                    ('Mateus Alves', '000.000.000-44', '11999990064', 'mateus.alves@email.com', '2024-02-17 16:35:00'),
                                                                    ('Bianca Ramos', '000.000.000-45', '11999990065', 'bianca.ramos@email.com', '2024-02-18 16:40:00'),
                                                                    ('Bruna Melo', '000.000.000-46', '11999990066', 'bruna.melo@email.com', '2024-02-19 16:45:00'),
                                                                    ('Rogério Pinto', '000.000.000-47', '11999990067', 'rogerio.pinto@email.com', '2024-02-20 16:50:00'),
                                                                    ('Vanessa Lima', '000.000.000-48', '11999990068', 'vanessa.lima@email.com', '2024-02-21 16:55:00'),
                                                                    ('Célia Freitas', '000.000.000-49', '11999990069', 'celia.freitas@email.com', '2024-02-22 17:00:00'),
                                                                    ('Tiago Fernandes', '000.000.000-50', '11999990070', 'tiago.fernandes@email.com', '2024-02-23 17:05:00'),
                                                                    ('Elisa Moreira', '000.000.000-51', '11999990071', 'elisa.moreira@email.com', '2024-02-24 17:10:00'),
                                                                    ('Fábio Sampaio', '000.000.000-52', '11999990072', 'fabio.sampaio@email.com', '2024-02-25 17:15:00'),
                                                                    ('Graça Pinto', '000.000.000-53', '11999990073', 'graca.pinto@email.com', '2024-02-26 17:20:00'),
                                                                    ('Neto Carvalho', '000.000.000-54', '11999990074', 'neto.carvalho@email.com', '2024-02-27 17:25:00'),
                                                                    ('Priscila Maia', '000.000.000-55', '11999990075', 'priscila.maia@email.com', '2024-02-28 17:30:00'),
                                                                    ('Rita Lobo', '000.000.000-56', '11999990076', 'rita.lobo@email.com', '2024-02-29 17:35:00'),
                                                                    ('Vítor Gomes', '000.000.000-57', '11999990077', 'vitor.gomes@email.com', '2024-03-01 17:40:00'),
                                                                    ('Lara Pinto', '000.000.000-58', '11999990078', 'lara.pinto@email.com', '2024-03-02 17:45:00'),
                                                                    ('Heitor Rocha', '000.000.000-59', '11999990079', 'heitor.rocha@email.com', '2024-03-03 17:50:00'),
                                                                    ('Marina Castro', '000.000.000-60', '11999990080', 'marina.castro@email.com', '2024-03-04 17:55:00')
ON CONFLICT (cpf) DO NOTHING;




INSERT INTO funcionario (nome, cpf, telefone, email, cargo, salario, data_admissao, data_cadastro) VALUES
                                                                                                       ('Carlos Oliveira', '111.111.111-01', '11999990101', 'carlos.oliveira@loja.com', 'Gerente Estoque', 3500.00, '2022-01-15', '2024-01-05 08:00:00'),
                                                                                                       ('Ana Costa', '111.111.111-02', '11999990102', 'ana.costa@loja.com', 'Vendedor', 2500.00, '2022-03-20', '2024-01-06 08:05:00'),
                                                                                                       ('Paulo Santos', '111.111.111-03', '11999990103', 'paulo.santos@loja.com', 'Estoquista', 2200.00, '2022-05-10', '2024-01-07 08:10:00'),
                                                                                                       ('Juliana Lima', '111.111.111-04', '11999990104', 'juliana.lima@loja.com', 'Caixa', 2000.00, '2022-08-25', '2024-01-08 08:15:00'),
                                                                                                       ('Ricardo Alves', '111.111.111-05', '11999990105', 'ricardo.alves@loja.com', 'Estoquista', 2200.00, '2022-02-28', '2024-01-09 08:20:00'),
                                                                                                       ('Fernanda Souza', '111.111.111-06', '11999990106', 'fernanda.souza@loja.com', 'Vendedor', 2400.00, '2022-04-15', '2024-01-10 08:25:00'),
                                                                                                       ('Roberto Silva', '111.111.111-07', '11999990107', 'roberto.silva@loja.com', 'Supervisor', 3200.00, '2021-11-30', '2024-01-11 08:30:00'),
                                                                                                       ('Patrícia Rocha', '111.111.111-08', '11999990108', 'patricia.rocha@loja.com', 'Vendedor', 2450.00, '2022-06-20', '2024-01-12 08:35:00'),
                                                                                                       ('Marcos Ferreira', '111.111.111-09', '11999990109', 'marcos.ferreira@loja.com', 'Estoquista', 2150.00, '2022-03-05', '2024-01-13 08:40:00'),
                                                                                                       ('Amanda Dias', '111.111.111-10', '11999990110', 'amanda.dias@loja.com', 'Caixa', 2050.00, '2022-07-12', '2024-01-14 08:45:00'),
                                                                                                       ('Bruno Martins', '111.111.111-11', '11999990111', 'bruno.martins@loja.com', 'Vendedor', 2300.00, '2022-09-18', '2024-01-15 08:50:00'),
                                                                                                       ('Carla Ribeiro', '111.111.111-12', '11999990112', 'carla.ribeiro@loja.com', 'Gerente Vendas', 3800.00, '2021-12-10', '2024-01-16 08:55:00'),
                                                                                                       ('Daniel Oliveira', '111.111.111-13', '11999990113', 'daniel.oliveira@loja.com', 'Vendedor', 2350.00, '2022-10-22', '2024-01-17 09:00:00'),
                                                                                                       ('Luciana Santos', '111.111.111-14', '11999990114', 'luciana.santos@loja.com', 'Caixa', 2100.00, '2022-11-05', '2024-01-18 09:05:00'),
                                                                                                       ('Eduardo Costa', '111.111.111-15', '11999990115', 'eduardo.costa@loja.com', 'Estoquista', 2250.00, '2022-12-15', '2024-01-19 09:10:00'),
                                                                                                       ('Mariana Ribeiro', '111.111.111-16', '11999990116', 'mariana.ribeiro@loja.com', 'Vendedor', 2420.00, '2023-01-20', '2024-01-20 09:15:00'),
                                                                                                       ('Felipe Souza', '111.111.111-17', '11999990117', 'felipe.souza@loja.com', 'Estoquista', 2180.00, '2023-02-28', '2024-01-21 09:20:00'),
                                                                                                       ('Gisele Martins', '111.111.111-18', '11999990118', 'gisele.martins@loja.com', 'Caixa', 2080.00, '2023-03-15', '2024-01-22 09:25:00'),
                                                                                                       ('Rafael Almeida', '111.111.111-19', '11999990119', 'rafael.almeida@loja.com', 'Vendedor', 2380.00, '2023-04-10', '2024-01-23 09:30:00'),
                                                                                                       ('Sonia Pereira', '111.111.111-20', '11999990120', 'sonia.pereira@loja.com', 'Supervisor', 3350.00, '2021-10-05', '2024-01-24 09:35:00')
ON CONFLICT (cpf) DO NOTHING;




ALTER TABLE produto ADD CONSTRAINT fk_produto_categoria FOREIGN KEY (categoria_id) REFERENCES categoria(id);
ALTER TABLE venda ADD CONSTRAINT fk_venda_cliente FOREIGN KEY (cliente_id) REFERENCES cliente(id);
ALTER TABLE venda ADD CONSTRAINT fk_venda_funcionario FOREIGN KEY (funcionario_id) REFERENCES funcionario(id);
ALTER TABLE item_venda ADD CONSTRAINT fk_item_venda_venda FOREIGN KEY (venda_id) REFERENCES venda(id);
ALTER TABLE item_venda ADD CONSTRAINT fk_item_venda_produto FOREIGN KEY (produto_id) REFERENCES produto(id);
ALTER TABLE estoque ADD CONSTRAINT fk_estoque_produto FOREIGN KEY (produto_id) REFERENCES produto(id);
ALTER TABLE usuario ADD CONSTRAINT fk_usuario_funcionario FOREIGN KEY (funcionario_id) REFERENCES funcionario(id);
ALTER TABLE pedido_compra ADD CONSTRAINT fk_pedido_fornecedor FOREIGN KEY (fornecedor_id) REFERENCES fornecedor(id);
ALTER TABLE item_pedido_compra ADD CONSTRAINT fk_item_pedido_produto FOREIGN KEY (produto_id) REFERENCES produto(id);
ALTER TABLE item_pedido_compra ADD CONSTRAINT fk_item_pedido_compra FOREIGN KEY (pedido_id) REFERENCES pedido_compra(id);
ALTER TABLE movimentacao_estoque ADD CONSTRAINT fk_movimentacao_produto FOREIGN KEY (produto_id) REFERENCES produto(id);
ALTER TABLE movimentacao_estoque ADD CONSTRAINT fk_movimentacao_funcionario FOREIGN KEY (funcionario_id) REFERENCES funcionario(id);
ALTER TABLE endereco ADD CONSTRAINT fk_endereco_cliente FOREIGN KEY (cliente_id) REFERENCES cliente(id);
ALTER TABLE produto_fornecedor ADD CONSTRAINT fk_produto_fornecedor_produto FOREIGN KEY (produto_id) REFERENCES produto(id);
ALTER TABLE produto_fornecedor ADD CONSTRAINT fk_produto_fornecedor_fornecedor FOREIGN KEY (fornecedor_id) REFERENCES fornecedor(id);




INSERT INTO usuario (username, senha, nivel_acesso, funcionario_id, data_cadastro, ativo) VALUES
                                                                                              ('carlos.oliveira', 'senha123', 'ADMIN', 1, '2024-01-05 09:00:00', true),
                                                                                              ('ana.costa', 'senha123', 'USUARIO', 2, '2024-01-06 09:05:00', true),
                                                                                              ('paulo.santos', 'senha123', 'OPERADOR', 3, '2024-01-07 09:10:00', true),
                                                                                              ('juliana.lima', 'senha123', 'USUARIO', 4, '2024-01-08 09:15:00', true),
                                                                                              ('ricardo.alves', 'senha123', 'OPERADOR', 5, '2024-01-09 09:20:00', true),
                                                                                              ('fernanda.souza', 'senha123', 'USUARIO', 6, '2024-01-10 09:25:00', true),
                                                                                              ('roberto.silva', 'senha123', 'ADMIN', 7, '2024-01-11 09:30:00', true),
                                                                                              ('patricia.rocha', 'senha123', 'USUARIO', 8, '2024-01-12 09:35:00', true),
                                                                                              ('marcos.ferreira', 'senha123', 'OPERADOR', 9, '2024-01-13 09:40:00', true),
                                                                                              ('amanda.dias', 'senha123', 'USUARIO', 10, '2024-01-14 09:45:00', true),
                                                                                              ('bruno.martins', 'senha123', 'USUARIO', 11, '2024-01-15 09:50:00', true),
                                                                                              ('carla.ribeiro', 'senha123', 'ADMIN', 12, '2024-01-16 09:55:00', true),
                                                                                              ('daniel.oliveira', 'senha123', 'USUARIO', 13, '2024-01-17 10:00:00', true),
                                                                                              ('luciana.santos', 'senha123', 'USUARIO', 14, '2024-01-18 10:05:00', true),
                                                                                              ('eduardo.costa', 'senha123', 'OPERADOR', 15, '2024-01-19 10:10:00', true),
                                                                                              ('mariana.ribeiro', 'senha123', 'USUARIO', 16, '2024-01-20 10:15:00', true),
                                                                                              ('felipe.souza', 'senha123', 'OPERADOR', 17, '2024-01-21 10:20:00', true),
                                                                                              ('gisele.martins', 'senha123', 'USUARIO', 18, '2024-01-22 10:25:00', true),
                                                                                              ('rafael.almeida', 'senha123', 'USUARIO', 19, '2024-01-23 10:30:00', true),
                                                                                              ('sonia.pereira', 'senha123', 'ADMIN', 20, '2024-01-24 10:35:00', true)
ON CONFLICT (username) DO NOTHING;




INSERT INTO estoque (produto_id, quantidade, estoque_minimo, estoque_maximo, localizacao, data_ultima_atualizacao) VALUES
                                                                                                                       (1, 2, 10, 100, 'A1', '2024-01-10 08:00:00'),
                                                                                                                       (2, 3, 8, 100, 'A1', '2024-01-10 08:05:00'),
                                                                                                                       (3, 1, 15, 100, 'A2', '2024-01-10 08:10:00'),
                                                                                                                       (4, 2, 5, 100, 'A2', '2024-01-10 08:15:00'),
                                                                                                                       (5, 12, 20, 100, 'B1', '2024-01-10 08:20:00'),
                                                                                                                       (6, 8, 15, 100, 'B1', '2024-01-10 08:25:00'),
                                                                                                                       (7, 6, 10, 100, 'B2', '2024-01-10 08:30:00'),
                                                                                                                       (8, 25, 10, 100, 'C1', '2024-01-10 08:35:00'),
                                                                                                                       (9, 30, 15, 100, 'C1', '2024-01-10 08:40:00'),
                                                                                                                       (10, 18, 8, 100, 'C2', '2024-01-10 08:45:00'),
                                                                                                                       (11, 45, 20, 100, 'C2', '2024-01-10 08:50:00'),
                                                                                                                       (12, 22, 10, 100, 'D1', '2024-01-10 08:55:00'),
                                                                                                                       (13, 28, 12, 100, 'D1', '2024-01-10 09:00:00'),
                                                                                                                       (14, 15, 6, 100, 'D2', '2024-01-10 09:05:00'),
                                                                                                                       (15, 85, 30, 100, 'D2', '2024-01-10 09:10:00'),
                                                                                                                       (16, 120, 40, 100, 'E1', '2024-01-10 09:15:00'),
                                                                                                                       (17, 35, 12, 100, 'E1', '2024-01-10 09:20:00'),
                                                                                                                       (18, 55, 20, 100, 'E2', '2024-01-10 09:25:00'),
                                                                                                                       (19, 25, 8, 100, 'E2', '2024-01-10 09:30:00'),
                                                                                                                       (20, 65, 25, 100, 'F1', '2024-01-10 09:35:00'),
                                                                                                                       (21, 48, 18, 100, 'F1', '2024-01-10 09:40:00'),
                                                                                                                       (22, 32, 12, 100, 'F2', '2024-01-10 09:45:00'),
                                                                                                                       (23, 14, 5, 100, 'F2', '2024-01-10 09:50:00'),
                                                                                                                       (24, 75, 25, 100, 'G1', '2024-01-10 09:55:00'),
                                                                                                                       (25, 12, 4, 100, 'G1', '2024-01-10 10:00:00'),
                                                                                                                       (26, 35, 12, 100, 'G2', '2024-01-10 10:05:00'),
                                                                                                                       (27, 18, 6, 100, 'G2', '2024-01-10 10:10:00'),
                                                                                                                       (28, 20, 7, 100, 'H1', '2024-01-10 10:15:00'),
                                                                                                                       (29, 48, 18, 100, 'H1', '2024-01-10 10:20:00'),
                                                                                                                       (30, 30, 10, 100, 'H2', '2024-01-10 10:25:00'),
                                                                                                                       (31, 22, 8, 100, 'H2', '2024-01-10 10:30:00'),
                                                                                                                       (32, 14, 5, 100, 'I1', '2024-01-10 10:35:00'),
                                                                                                                       (33, 6, 2, 100, 'I1', '2024-01-10 10:40:00'),
                                                                                                                       (34, 42, 15, 100, 'I2', '2024-01-10 10:45:00'),
                                                                                                                       (35, 16, 6, 100, 'I2', '2024-01-10 10:50:00'),
                                                                                                                       (36, 32, 12, 100, 'J1', '2024-01-10 10:55:00'),
                                                                                                                       (37, 25, 8, 100, 'J1', '2024-01-10 11:00:00'),
                                                                                                                       (38, 60, 20, 100, 'J2', '2024-01-10 11:05:00'),
                                                                                                                       (39, 18, 6, 100, 'J2', '2024-01-10 11:10:00'),
                                                                                                                       (40, 85, 30, 100, 'K1', '2024-01-10 11:15:00'),
                                                                                                                       (41, 42, 15, 100, 'K1', '2024-01-10 11:20:00'),
                                                                                                                       (42, 28, 10, 100, 'K2', '2024-01-10 11:25:00'),
                                                                                                                       (43, 55, 20, 100, 'K2', '2024-01-10 11:30:00'),
                                                                                                                       (44, 32, 12, 100, 'L1', '2024-01-10 11:35:00'),
                                                                                                                       (45, 68, 25, 100, 'L1', '2024-01-10 11:40:00'),
                                                                                                                       (46, 90, 30, 100, 'L2', '2024-01-10 11:45:00'),
                                                                                                                       (47, 120, 40, 100, 'L2', '2024-01-10 11:50:00'),
                                                                                                                       (48, 150, 50, 100, 'M1', '2024-01-10 11:55:00'),
                                                                                                                       (49, 200, 50, 100, 'M1', '2024-01-10 12:00:00'),
                                                                                                                       (50, 150, 40, 100, 'M2', '2024-01-10 12:05:00')
ON CONFLICT (produto_id) DO NOTHING;




INSERT INTO endereco (cliente_id, tipo_endereco, logradouro, numero, complemento, bairro, cidade, estado, cep, principal) VALUES
                                                                                                                              (1, 'RESIDENCIAL', 'Av. Paulista', '100', 'Apto 101', 'Bela Vista', 'São Paulo', 'SP', '01311-000', true),
                                                                                                                              (2, 'RESIDENCIAL', 'R. das Flores', '200', '', 'Centro', 'Rio de Janeiro', 'RJ', '20010-000', true),
                                                                                                                              (3, 'RESIDENCIAL', 'R. A', '50', '', 'Savassi', 'Belo Horizonte', 'MG', '30140-000', true),
                                                                                                                              (4, 'RESIDENCIAL', 'Av. Central', '123', '', 'Centro', 'Porto Alegre', 'RS', '90010-000', true),
                                                                                                                              (5, 'RESIDENCIAL', 'R. B', '77', '', 'Asa Norte', 'Brasília', 'DF', '70040-000', true),
                                                                                                                              (6, 'RESIDENCIAL', 'Av. do Comércio', '10', '', 'Pelourinho', 'Salvador', 'BA', '40020-000', true),
                                                                                                                              (7, 'RESIDENCIAL', 'R. C', '15', '', 'Meireles', 'Fortaleza', 'CE', '60110-000', true),
                                                                                                                              (8, 'RESIDENCIAL', 'R. D', '88', '', 'Boa Viagem', 'Recife', 'PE', '51010-000', true),
                                                                                                                              (9, 'RESIDENCIAL', 'R. E', '9', '', 'Ponta Negra', 'Manaus', 'AM', '69098-000', true),
                                                                                                                              (10, 'RESIDENCIAL', 'R. F', '300', '', 'Centro', 'Curitiba', 'PR', '80010-000', true),
                                                                                                                              (11, 'COMERCIAL', 'Av. Expo', '55', '', 'Ibirapuera', 'São Paulo', 'SP', '04000-000', false),
                                                                                                                              (12, 'RESIDENCIAL', 'R. G', '44', '', 'Savassi', 'Belo Horizonte', 'MG', '30140-001', true),
                                                                                                                              (13, 'RESIDENCIAL', 'R. H', '33', '', 'Centro', 'Porto Alegre', 'RS', '90010-001', true),
                                                                                                                              (14, 'RESIDENCIAL', 'Av. I', '22', '', 'Asa Sul', 'Brasília', 'DF', '70200-000', true),
                                                                                                                              (15, 'RESIDENCIAL', 'R. J', '11', '', 'Barra', 'Salvador', 'BA', '40140-000', true),
                                                                                                                              (16, 'RESIDENCIAL', 'R. K', '66', '', 'Aldeota', 'Fortaleza', 'CE', '60150-000', true),
                                                                                                                              (17, 'RESIDENCIAL', 'Av. L', '9', '', 'Boa Viagem', 'Recife', 'PE', '51010-001', true),
                                                                                                                              (18, 'RESIDENCIAL', 'R. M', '77', '', 'Centro', 'Manaus', 'AM', '69010-000', true),
                                                                                                                              (19, 'RESIDENCIAL', 'R. N', '88', '', 'Centro', 'Curitiba', 'PR', '80010-001', true),
                                                                                                                              (20, 'RESIDENCIAL', 'R. O', '100', '', 'Centro', 'São Paulo', 'SP', '01010-000', true),
                                                                                                                              (21, 'ENTREGA', 'R. P', '5', '', 'Centro', 'Belo Horizonte', 'MG', '30140-002', false),
                                                                                                                              (22, 'ENTREGA', 'Av. Q', '2', '', 'Centro', 'Porto Alegre', 'RS', '90010-002', false),
                                                                                                                              (23, 'COMERCIAL', 'R. R', '123', '', 'Centro', 'Brasília', 'DF', '70300-000', false),
                                                                                                                              (24, 'RESIDENCIAL', 'R. S', '44', '', 'Graça', 'Salvador', 'BA', '40260-000', true),
                                                                                                                              (25, 'RESIDENCIAL', 'R. T', '66', '', 'Varjota', 'Fortaleza', 'CE', '60160-000', true),
                                                                                                                              (26, 'RESIDENCIAL', 'R. U', '33', '', 'Boa Vista', 'Manaus', 'AM', '69005-000', true),
                                                                                                                              (27, 'RESIDENCIAL', 'R. V', '88', '', 'Centro', 'Curitiba', 'PR', '80020-000', true),
                                                                                                                              (28, 'RESIDENCIAL', 'R. W', '101', '', 'Moema', 'São Paulo', 'SP', '04500-000', true),
                                                                                                                              (29, 'RESIDENCIAL', 'Av. X', '2', '', 'Santo Antônio', 'Belo Horizonte', 'MG', '30150-000', true),
                                                                                                                              (30, 'RESIDENCIAL', 'R. Y', '17', '', 'Centro', 'Porto Alegre', 'RS', '90020-000', true),
                                                                                                                              (31, 'RESIDENCIAL', 'R. Z', '50', '', 'Asa Norte', 'Brasília', 'DF', '70050-000', true),
                                                                                                                              (32, 'RESIDENCIAL', 'R. AA', '60', '', 'Piatã', 'Salvador', 'BA', '40300-000', true),
                                                                                                                              (33, 'RESIDENCIAL', 'R. BB', '70', '', 'Aldeota', 'Fortaleza', 'CE', '60170-000', true),
                                                                                                                              (34, 'RESIDENCIAL', 'R. CC', '80', '', 'Boa Viagem', 'Recife', 'PE', '51020-000', true),
                                                                                                                              (35, 'RESIDENCIAL', 'R. DD', '90', '', 'Centro', 'Manaus', 'AM', '69015-000', true),
                                                                                                                              (36, 'RESIDENCIAL', 'R. EE', '100', '', 'Batel', 'Curitiba', 'PR', '80030-000', true),
                                                                                                                              (37, 'RESIDENCIAL', 'R. FF', '110', '', 'Vila Mariana', 'São Paulo', 'SP', '04010-000', true),
                                                                                                                              (38, 'COMERCIAL', 'Av. GG', '120', '', 'Savassi', 'Belo Horizonte', 'MG', '30160-000', false),
                                                                                                                              (39, 'RESIDENCIAL', 'R. HH', '130', '', 'Centro', 'Porto Alegre', 'RS', '90030-000', true),
                                                                                                                              (40, 'RESIDENCIAL', 'Av. II', '140', '', 'Lago Norte', 'Brasília', 'DF', '70700-000', true),
                                                                                                                              (41, 'RESIDENCIAL', 'R. JJ', '150', '', 'Itaigara', 'Salvador', 'BA', '40350-000', true),
                                                                                                                              (42, 'RESIDENCIAL', 'R. KK', '160', '', 'Messejana', 'Fortaleza', 'CE', '60180-000', true),
                                                                                                                              (43, 'RESIDENCIAL', 'R. LL', '170', '', 'Casa Amarela', 'Recife', 'PE', '51030-000', true),
                                                                                                                              (44, 'RESIDENCIAL', 'R. MM', '180', '', 'Cachoeirinha', 'Manaus', 'AM', '69020-000', true),
                                                                                                                              (45, 'RESIDENCIAL', 'R. NN', '190', '', 'Santa Felicidade', 'Curitiba', 'PR', '80040-000', true),
                                                                                                                              (46, 'RESIDENCIAL', 'R. OO', '200', '', 'Pinheiros', 'São Paulo', 'SP', '05010-000', true),
                                                                                                                              (47, 'RESIDENCIAL', 'R. PP', '210', '', 'Funcionários', 'Belo Horizonte', 'MG', '30170-000', true),
                                                                                                                              (48, 'RESIDENCIAL', 'R. QQ', '220', '', 'Moinhos de Vento', 'Porto Alegre', 'RS', '90040-000', true),
                                                                                                                              (49, 'RESIDENCIAL', 'R. RR', '230', '', 'Lago Sul', 'Brasília', 'DF', '70750-000', true),
                                                                                                                              (50, 'RESIDENCIAL', 'R. SS', '240', '', 'Pituba', 'Salvador', 'BA', '40400-000', true),
                                                                                                                              (51, 'RESIDENCIAL', 'R. TT', '250', '', 'Cocó', 'Fortaleza', 'CE', '60190-000', true),
                                                                                                                              (52, 'RESIDENCIAL', 'R. UU', '260', '', 'Boa Viagem', 'Recife', 'PE', '51040-000', true),
                                                                                                                              (53, 'RESIDENCIAL', 'R. VV', '270', '', 'Adrianópolis', 'Manaus', 'AM', '69025-000', true),
                                                                                                                              (54, 'RESIDENCIAL', 'R. WW', '280', '', 'Portão', 'Curitiba', 'PR', '80050-000', true),
                                                                                                                              (55, 'RESIDENCIAL', 'R. XX', '290', '', 'Perdizes', 'São Paulo', 'SP', '05020-000', true),
                                                                                                                              (56, 'RESIDENCIAL', 'R. YY', '300', '', 'Santo Agostinho', 'Belo Horizonte', 'MG', '30180-000', true),
                                                                                                                              (57, 'RESIDENCIAL', 'R. ZZ', '310', '', 'Petrópolis', 'Porto Alegre', 'RS', '90050-000', true),
                                                                                                                              (58, 'RESIDENCIAL', 'R. AAA', '320', '', 'Asa Sul', 'Brasília', 'DF', '70200-001', true),
                                                                                                                              (59, 'RESIDENCIAL', 'R. BBB', '330', '', 'Ondina', 'Salvador', 'BA', '40150-000', true),
                                                                                                                              (60, 'RESIDENCIAL', 'R. CCC', '340', '', 'Dionísio Torres', 'Fortaleza', 'CE', '60200-000', true)
ON CONFLICT (id) DO NOTHING;




INSERT INTO produto_fornecedor (produto_id, fornecedor_id, preco_compra, prazo_entrega, ativo, data_cadastro) VALUES
                                                                                                                  (1, 1, 45.00, 7, true, '2024-01-05 08:00:00'),
                                                                                                                  (1, 2, 44.00, 10, true, '2024-01-06 08:00:00'),
                                                                                                                  (2, 2, 30.00, 7, true, '2024-01-06 08:05:00'),
                                                                                                                  (3, 4, 7.00, 5, true, '2024-01-07 08:10:00'),
                                                                                                                  (4, 5, 80.00, 12, true, '2024-01-08 08:15:00'),
                                                                                                                  (5, 4, 15.00, 8, true, '2024-01-09 08:20:00'),
                                                                                                                  (6, 10, 9.00, 6, true, '2024-01-10 08:25:00'),
                                                                                                                  (7, 5, 50.00, 10, true, '2024-01-11 08:30:00'),
                                                                                                                  (8, 12, 100.00, 14, true, '2024-01-12 08:35:00'),
                                                                                                                  (9, 7, 70.00, 7, true, '2024-01-13 08:40:00'),
                                                                                                                  (10, 11, 18.00, 9, true, '2024-01-14 08:45:00'),
                                                                                                                  (11, 7, 85.00, 10, true, '2024-01-15 08:50:00'),
                                                                                                                  (12, 7, 20.00, 8, true, '2024-01-16 08:55:00'),
                                                                                                                  (13, 8, 22.00, 12, true, '2024-01-17 09:00:00'),
                                                                                                                  (14, 8, 18.00, 10, true, '2024-01-18 09:05:00'),
                                                                                                                  (15, 14, 40.00, 7, true, '2024-01-19 09:10:00'),
                                                                                                                  (16, 10, 6.00, 6, true, '2024-01-20 09:15:00'),
                                                                                                                  (17, 16, 12.00, 7, true, '2024-01-21 09:20:00'),
                                                                                                                  (18, 9, 60.00, 8, true, '2024-01-22 09:25:00'),
                                                                                                                  (19, 4, 28.00, 10, true, '2024-01-23 09:30:00'),
                                                                                                                  (20, 11, 25.00, 9, true, '2024-01-24 09:35:00'),
                                                                                                                  (21, 13, 30.00, 12, true, '2024-01-25 09:40:00'),
                                                                                                                  (22, 11, 22.00, 9, true, '2024-01-26 09:45:00'),
                                                                                                                  (23, 15, 10.00, 7, true, '2024-01-27 09:50:00'),
                                                                                                                  (24, 7, 45.00, 8, true, '2024-01-28 09:55:00'),
                                                                                                                  (25, 9, 110.00, 12, true, '2024-01-29 10:00:00'),
                                                                                                                  (26, 9, 70.00, 10, true, '2024-01-30 10:05:00'),
                                                                                                                  (27, 3, 18.00, 7, true, '2024-01-31 10:10:00'),
                                                                                                                  (28, 3, 8.00, 6, true, '2024-02-01 10:15:00'),
                                                                                                                  (29, 6, 9.00, 9, true, '2024-02-02 10:20:00'),
                                                                                                                  (30, 6, 14.00, 8, true, '2024-02-03 10:25:00'),
                                                                                                                  (31, 2, 65.00, 11, true, '2024-02-04 10:30:00'),
                                                                                                                  (32, 2, 55.00, 10, true, '2024-02-05 10:35:00'),
                                                                                                                  (33, 18, 20.00, 9, true, '2024-02-06 10:40:00'),
                                                                                                                  (34, 18, 35.00, 10, true, '2024-02-07 10:45:00'),
                                                                                                                  (35, 13, 25.00, 8, true, '2024-02-08 10:50:00'),
                                                                                                                  (36, 14, 45.00, 12, true, '2024-02-09 10:55:00'),
                                                                                                                  (37, 15, 52.00, 10, true, '2024-02-10 11:00:00'),
                                                                                                                  (38, 15, 28.00, 9, true, '2024-02-11 11:05:00'),
                                                                                                                  (39, 20, 15.00, 7, true, '2024-02-12 11:10:00'),
                                                                                                                  (40, 20, 40.00, 14, true, '2024-02-13 11:15:00')
ON CONFLICT (produto_id, fornecedor_id) DO NOTHING;




INSERT INTO venda (numero_venda, data_venda, total, status, cliente_id, funcionario_id, observacao) VALUES
                                                                                                        ('VND-0001', '2024-01-15 11:00:00', 258.90, 'FINALIZADA', 1, 1, 'Compra presencial'),
                                                                                                        ('VND-0002', '2024-01-20 12:00:00', 89.90, 'FINALIZADA', 2, 2, 'Compra online'),
                                                                                                        ('VND-0003', '2024-02-05 13:15:00', 129.00, 'FINALIZADA', 3, 1, 'Retirada loja'),
                                                                                                        ('VND-0004', '2024-02-18 14:30:00', 299.00, 'FINALIZADA', 4, 3, 'Pagamento cartão'),
                                                                                                        ('VND-0005', '2024-03-10 15:45:00', 179.00, 'FINALIZADA', 5, 2, 'Promoção'),
                                                                                                        ('VND-0006', '2024-03-25 10:30:00', 499.00, 'FINALIZADA', 6, 1, 'Combo kits'),
                                                                                                        ('VND-0007', '2024-04-05 11:20:00', 79.00, 'FINALIZADA', 7, 3, 'Compra rápida'),
                                                                                                        ('VND-0008', '2024-04-20 12:10:00', 159.00, 'FINALIZADA', 8, 2, 'Gift card'),
                                                                                                        ('VND-0009', '2024-05-12 13:00:00', 349.00, 'FINALIZADA', 9, 1, 'Compra online'),
                                                                                                        ('VND-0010', '2024-05-28 14:00:00', 129.90, 'FINALIZADA', 10, 3, 'Retirada loja'),
                                                                                                        ('VND-0011', '2024-06-15 15:00:00', 89.00, 'FINALIZADA', 11, 2, ''),
                                                                                                        ('VND-0012', '2024-06-30 16:00:00', 199.00, 'FINALIZADA', 12, 1, ''),
                                                                                                        ('VND-0013', '2024-07-10 17:00:00', 59.00, 'FINALIZADA', 13, 3, ''),
                                                                                                        ('VND-0014', '2024-07-25 10:10:00', 139.00, 'FINALIZADA', 14, 2, ''),
                                                                                                        ('VND-0015', '2024-08-08 11:11:00', 299.00, 'FINALIZADA', 15, 1, ''),
                                                                                                        ('VND-0016', '2024-08-22 12:12:00', 89.90, 'FINALIZADA', 16, 3, ''),
                                                                                                        ('VND-0017', '2024-09-05 13:13:00', 169.00, 'FINALIZADA', 17, 2, ''),
                                                                                                        ('VND-0018', '2024-09-18 14:14:00', 399.00, 'FINALIZADA', 18, 1, ''),
                                                                                                        ('VND-0019', '2024-10-02 15:15:00', 79.00, 'FINALIZADA', 19, 3, ''),
                                                                                                        ('VND-0020', '2024-10-20 16:16:00', 129.90, 'FINALIZADA', 20, 2, ''),
                                                                                                        ('VND-0021', '2024-11-10 10:10:00', 189.00, 'FINALIZADA', 21, 1, ''),
                                                                                                        ('VND-0022', '2024-11-25 11:11:00', 499.00, 'FINALIZADA', 22, 3, ''),
                                                                                                        ('VND-0023', '2024-12-15 12:12:00', 89.00, 'FINALIZADA', 23, 2, ''),
                                                                                                        ('VND-0024', '2024-12-28 13:13:00', 199.00, 'FINALIZADA', 24, 1, ''),
                                                                                                        ('VND-0025', '2025-01-10 14:14:00', 159.00, 'FINALIZADA', 25, 3, ''),
                                                                                                        ('VND-0026', '2025-01-25 15:15:00', 349.00, 'FINALIZADA', 26, 2, ''),
                                                                                                        ('VND-0027', '2025-02-08 16:16:00', 129.90, 'FINALIZADA', 27, 1, ''),
                                                                                                        ('VND-0028', '2025-02-20 17:17:00', 79.00, 'FINALIZADA', 28, 3, ''),
                                                                                                        ('VND-0029', '2025-03-05 10:10:00', 139.00, 'PENDENTE', 29, 2, 'Aguardando pagamento'),
                                                                                                        ('VND-0030', '2025-03-18 11:11:00', 299.00, 'FINALIZADA', 30, 1, '')
ON CONFLICT (numero_venda) DO NOTHING;




INSERT INTO item_venda (venda_id, produto_id, quantidade, preco_unitario, subtotal) VALUES
                                                                                        (1, 1, 1, 89.90, 89.90),
                                                                                        (1, 3, 3, 29.90, 89.70),
                                                                                        (2, 6, 2, 39.90, 79.80),
                                                                                        (3, 9, 1, 199.00, 199.00),
                                                                                        (4, 27, 1, 159.90, 159.90),
                                                                                        (5, 21, 1, 299.00, 299.00),
                                                                                        (6, 25, 1, 129.90, 129.90),
                                                                                        (7, 3, 1, 29.90, 29.90),
                                                                                        (8, 10, 1, 89.90, 89.90),
                                                                                        (9, 16, 1, 29.90, 29.90),
                                                                                        (10, 12, 1, 34.90, 34.90),
                                                                                        (11, 31, 1, 149.90, 149.90),
                                                                                        (12, 2, 2, 79.90, 159.80),
                                                                                        (13, 13, 1, 59.90, 59.90),
                                                                                        (14, 5, 1, 49.90, 49.90),
                                                                                        (15, 26, 1, 199.00, 199.00),
                                                                                        (16, 4, 1, 159.90, 159.90),
                                                                                        (17, 8, 1, 79.90, 79.90),
                                                                                        (18, 33, 1, 399.00, 399.00),
                                                                                        (19, 30, 1, 149.90, 149.90),
                                                                                        (20, 7, 1, 129.90, 129.90),
                                                                                        (21, 14, 2, 45.90, 91.80),
                                                                                        (22, 28, 1, 159.90, 159.90),
                                                                                        (23, 11, 1, 129.90, 129.90),
                                                                                        (24, 19, 1, 149.90, 149.90),
                                                                                        (25, 22, 2, 59.90, 119.80),
                                                                                        (26, 29, 1, 129.90, 129.90),
                                                                                        (27, 15, 1, 39.90, 39.90),
                                                                                        (28, 18, 1, 49.90, 49.90),
                                                                                        (29, 20, 1, 79.90, 79.90),
                                                                                        (30, 23, 1, 129.90, 129.90),
                                                                                        (1, 5, 1, 49.90, 49.90),
                                                                                        (2, 7, 1, 129.90, 129.90),
                                                                                        (3, 11, 1, 129.90, 129.90),
                                                                                        (4, 14, 1, 45.90, 45.90),
                                                                                        (5, 17, 1, 29.90, 29.90),
                                                                                        (6, 19, 1, 149.90, 149.90),
                                                                                        (7, 22, 1, 59.90, 59.90),
                                                                                        (8, 24, 1, 45.90, 45.90),
                                                                                        (9, 27, 1, 159.90, 159.90),
                                                                                        (10, 29, 1, 129.90, 129.90),
                                                                                        (11, 32, 1, 149.90, 149.90),
                                                                                        (12, 34, 1, 79.90, 79.90),
                                                                                        (13, 36, 1, 49.90, 49.90),
                                                                                        (14, 38, 1, 59.90, 59.90),
                                                                                        (15, 40, 1, 39.90, 39.90),
                                                                                        (16, 42, 1, 99.90, 99.90),
                                                                                        (17, 44, 1, 129.90, 129.90),
                                                                                        (18, 46, 1, 29.90, 29.90),
                                                                                        (19, 48, 1, 16.90, 16.90),
                                                                                        (20, 50, 1, 12.90, 12.90),
                                                                                        (21, 35, 2, 24.90, 49.80),
                                                                                        (22, 37, 1, 59.90, 59.90),
                                                                                        (23, 39, 1, 29.90, 29.90),
                                                                                        (24, 41, 1, 79.90, 79.90),
                                                                                        (25, 43, 1, 119.90, 119.90),
                                                                                        (26, 45, 1, 39.90, 39.90),
                                                                                        (27, 47, 1, 19.90, 19.90),
                                                                                        (28, 49, 1, 9.90, 9.90)
ON CONFLICT (id) DO NOTHING;




INSERT INTO pedido_compra (numero_pedido, fornecedor_id, data_pedido, data_entrega_prevista, data_entrega_real, status, total, observacao) VALUES
                                                                                                                                               ('PC-0001', 1, '2024-01-05', '2024-01-12', '2024-01-12', 'RECEBIDO', 5000.00, 'Pedido inicial de estoque'),
                                                                                                                                               ('PC-0002', 2, '2024-01-10', '2024-01-17', '2024-01-18', 'RECEBIDO', 3000.00, 'Reforço de brinquedos'),
                                                                                                                                               ('PC-0003', 3, '2024-02-15', '2024-02-22', NULL, 'PENDENTE', 2000.00, 'Aguardando confirmação'),
                                                                                                                                               ('PC-0004', 4, '2024-03-20', '2024-03-27', '2024-03-27', 'RECEBIDO', 1500.00, 'Velas e aromas'),
                                                                                                                                               ('PC-0005', 5, '2024-04-25', '2024-05-02', NULL, 'CANCELADO', 800.00, 'Cancelado pelo fornecedor'),
                                                                                                                                               ('PC-0006', 6, '2024-05-10', '2024-05-17', '2024-05-17', 'RECEBIDO', 2500.00, 'Papelaria criativa'),
                                                                                                                                               ('PC-0007', 7, '2024-06-05', '2024-06-12', '2024-06-12', 'RECEBIDO', 1800.00, 'Relógios e acessórios'),
                                                                                                                                               ('PC-0008', 8, '2024-07-15', '2024-07-22', NULL, 'APROVADO', 1200.00, 'Personalização'),
                                                                                                                                               ('PC-0009', 9, '2024-08-20', '2024-08-27', '2024-08-27', 'RECEBIDO', 3500.00, 'Kits premium'),
                                                                                                                                               ('PC-0010', 10, '2024-09-10', '2024-09-17', '2024-09-17', 'RECEBIDO', 2800.00, 'Artigos religiosos'),
                                                                                                                                               ('PC-0011', 11, '2024-10-05', '2024-10-12', NULL, 'PENDENTE', 1600.00, 'Lembrancinhas'),
                                                                                                                                               ('PC-0012', 12, '2024-11-15', '2024-11-22', '2024-11-22', 'RECEBIDO', 2200.00, 'Cosméticos'),
                                                                                                                                               ('PC-0013', 13, '2024-12-10', '2024-12-17', '2024-12-17', 'RECEBIDO', 1900.00, 'Casa e conforto'),
                                                                                                                                               ('PC-0014', 14, '2025-01-08', '2025-01-15', NULL, 'APROVADO', 2100.00, 'Livros'),
                                                                                                                                               ('PC-0015', 15, '2025-02-12', '2025-02-19', '2025-02-19', 'RECEBIDO', 3200.00, 'Tech presentes')
ON CONFLICT (numero_pedido) DO NOTHING;




INSERT INTO item_pedido_compra (pedido_id, produto_id, quantidade, preco_unitario, subtotal) VALUES
                                                                                                 (1, 1, 50, 45.00, 2250.00),
                                                                                                 (1, 2, 30, 40.00, 1200.00),
                                                                                                 (1, 3, 100, 7.00, 700.00),
                                                                                                 (2, 5, 80, 20.00, 1600.00),
                                                                                                 (2, 6, 60, 9.00, 540.00),
                                                                                                 (3, 8, 25, 70.00, 1750.00),
                                                                                                 (4, 3, 100, 7.00, 700.00),
                                                                                                 (4, 5, 40, 15.00, 600.00),
                                                                                                 (5, 4, 10, 80.00, 800.00),
                                                                                                 (6, 11, 30, 85.00, 2550.00),
                                                                                                 (6, 12, 50, 20.00, 1000.00),
                                                                                                 (7, 8, 20, 70.00, 1400.00),
                                                                                                 (7, 9, 25, 18.00, 450.00),
                                                                                                 (8, 17, 100, 12.00, 1200.00),
                                                                                                 (9, 22, 40, 22.00, 880.00),
                                                                                                 (9, 23, 30, 10.00, 300.00),
                                                                                                 (10, 27, 15, 18.00, 270.00),
                                                                                                 (10, 28, 20, 8.00, 160.00),
                                                                                                 (11, 31, 25, 65.00, 1625.00),
                                                                                                 (12, 35, 80, 25.00, 2000.00),
                                                                                                 (12, 36, 50, 45.00, 2250.00),
                                                                                                 (13, 39, 100, 15.00, 1500.00),
                                                                                                 (13, 40, 80, 40.00, 3200.00),
                                                                                                 (14, 42, 30, 30.00, 900.00),
                                                                                                 (14, 43, 40, 35.00, 1400.00),
                                                                                                 (15, 45, 100, 12.00, 1200.00),
                                                                                                 (15, 46, 80, 8.00, 640.00),
                                                                                                 (15, 47, 120, 6.00, 720.00),
                                                                                                 (15, 48, 150, 5.00, 750.00),
                                                                                                 (15, 49, 200, 3.00, 600.00)
ON CONFLICT (id) DO NOTHING;




INSERT INTO movimentacao_estoque (produto_id, tipo_movimentacao, quantidade, data_movimentacao, documento_referencia, observacao, funcionario_id) VALUES
                                                                                                                                                      (1, 'ENTRADA', 50, '2024-01-05 08:00:00', 'PC-0001', 'Recebimento pedido inicial', 1),
                                                                                                                                                      (2, 'ENTRADA', 30, '2024-01-05 08:10:00', 'PC-0001', 'Recebimento pedido inicial', 1),
                                                                                                                                                      (3, 'ENTRADA', 100, '2024-01-05 08:20:00', 'PC-0001', 'Recebimento pedido inicial', 1),
                                                                                                                                                      (4, 'ENTRADA', 20, '2024-01-05 08:30:00', 'PC-0001', 'Recebimento pedido inicial', 1),
                                                                                                                                                      (5, 'ENTRADA', 80, '2024-01-05 08:40:00', 'PC-0001', 'Recebimento pedido inicial', 1),
                                                                                                                                                      (6, 'SAIDA', 5, '2024-01-15 11:05:00', 'VND-0002', 'Venda loja física', 2),
                                                                                                                                                      (1, 'SAIDA', 2, '2024-01-15 11:10:00', 'VND-0001', 'Venda kit presente', 2),
                                                                                                                                                      (3, 'SAIDA', 5, '2024-01-25 14:00:00', 'VND-0001', 'Saída por venda', 3),
                                                                                                                                                      (2, 'SAIDA', 3, '2024-02-05 13:45:00', 'VND-0004', 'Venda online', 2),
                                                                                                                                                      (4, 'SAIDA', 1, '2024-02-10 10:30:00', 'VND-0006', 'Venda promocional', 3),
                                                                                                                                                      (5, 'AJUSTE', -5, '2024-02-15 09:00:00', NULL, 'Quebra/perda inventário', 1),
                                                                                                                                                      (3, 'AJUSTE', -2, '2024-02-20 09:15:00', NULL, 'Quebra/perda inventário', 1),
                                                                                                                                                      (5, 'AJUSTE', 10, '2024-02-25 10:00:00', 'PC-0002', 'Ajuste entrada não contabilizada', 1),
                                                                                                                                                      (7, 'ENTRADA', 40, '2024-03-01 08:30:00', 'PC-0002', 'Reposição de jóias', 4),
                                                                                                                                                      (8, 'ENTRADA', 60, '2024-03-02 09:00:00', 'PC-0002', 'Reposição eletrônicos', 4),
                                                                                                                                                      (9, 'SAIDA', 7, '2024-03-10 12:20:00', 'VND-0009', 'Vendas diversos', 5),
                                                                                                                                                      (10, 'SAIDA', 3, '2024-03-25 16:10:00', 'VND-0015', 'Venda especial', 5),
                                                                                                                                                      (11, 'ENTRADA', 100, '2024-04-05 08:00:00', 'PC-0003', 'Compra brinquedos educativos', 6),
                                                                                                                                                      (12, 'SAIDA', 20, '2024-04-15 14:30:00', 'VND-0018', 'Venda estação', 7),
                                                                                                                                                      (13, 'ENTRADA', 50, '2024-05-01 09:00:00', 'PC-0004', 'Reforço produtos decoração', 1),
                                                                                                                                                      (14, 'AJUSTE', -3, '2024-06-10 10:30:00', NULL, 'Ajuste contagem ciclo', 2),
                                                                                                                                                      (15, 'ENTRADA', 30, '2024-07-15 09:00:00', 'PC-0005', 'Pedido sazonal recebido', 1),
                                                                                                                                                      (16, 'SAIDA', 15, '2024-08-20 11:45:00', 'VND-0022', 'Venda corporativa', 8),
                                                                                                                                                      (17, 'ENTRADA', 80, '2024-09-10 08:30:00', 'PC-0006', 'Reposição papelaria', 9),
                                                                                                                                                      (18, 'SAIDA', 25, '2024-10-05 14:20:00', 'VND-0025', 'Venda festa', 10),
                                                                                                                                                      (19, 'ENTRADA', 40, '2024-11-15 09:15:00', 'PC-0007', 'Novos produtos', 11),
                                                                                                                                                      (20, 'SAIDA', 18, '2024-12-20 16:30:00', 'VND-0028', 'Venda natalina', 12),
                                                                                                                                                      (21, 'ENTRADA', 60, '2025-01-10 08:45:00', 'PC-0008', 'Início ano novo', 13),
                                                                                                                                                      (22, 'SAIDA', 12, '2025-02-14 13:15:00', 'VND-0030', 'Venda dia dos namorados', 14),
                                                                                                                                                      (23, 'ENTRADA', 45, '2025-03-05 10:00:00', 'PC-0009', 'Reposição pós-carnaval', 15)
ON CONFLICT (id) DO NOTHING;




CREATE INDEX IF NOT EXISTS idx_produto_nome_trgm ON produto USING gin (nome gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_cliente_nome_trgm ON cliente USING gin (nome gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_fornecedor_nome_trgm ON fornecedor USING gin (nome gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_venda_data_desc ON venda (data_venda DESC);
CREATE INDEX IF NOT EXISTS idx_movimentacao_data_desc ON movimentacao_estoque (data_movimentacao DESC);
CREATE INDEX IF NOT EXISTS idx_produto_ativos ON produto (id) WHERE ativo = true;
CREATE INDEX IF NOT EXISTS idx_usuario_ativos ON usuario (id) WHERE ativo = true;
CREATE INDEX IF NOT EXISTS idx_produto_fornecedor_ativos ON produto_fornecedor (id) WHERE ativo = true;
CREATE UNIQUE INDEX IF NOT EXISTS idx_cliente_cpf_unique ON cliente (cpf) WHERE cpf IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS idx_fornecedor_cnpj_unique ON fornecedor (cnpj) WHERE cnpj IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS idx_funcionario_cpf_unique ON funcionario (cpf) WHERE cpf IS NOT NULL;




SELECT ' VERIFICAÇÃO COMPLETA - ATENDENDO AOS REQUISITOS ' as info;


SELECT 'Total de Tabelas: 14' as requisitos
UNION ALL SELECT 'Relacionamentos 1:1: 2 (Estoque-Produto, Usuario-Funcionario)'
UNION ALL SELECT 'Relacionamento N:N: 1 (Produto-Fornecedor via produto_fornecedor)'
UNION ALL SELECT 'Período dos dados: 2024-2025'
UNION ALL SELECT 'Total de INSERTS: 335+' as total_inserts;


SELECT ' CONTAGEM POR TABELA ' as info;
SELECT 'Categorias: ' || COUNT(*)::text FROM categoria
UNION ALL SELECT 'Fornecedores: ' || COUNT(*)::text FROM fornecedor
UNION ALL SELECT 'Produtos: ' || COUNT(*)::text FROM produto
UNION ALL SELECT 'Clientes: ' || COUNT(*)::text FROM cliente
UNION ALL SELECT 'Funcionários: ' || COUNT(*)::text FROM funcionario
UNION ALL SELECT 'Usuários: ' || COUNT(*)::text FROM usuario
UNION ALL SELECT 'Estoque: ' || COUNT(*)::text FROM estoque
UNION ALL SELECT 'Endereços: ' || COUNT(*)::text FROM endereco
UNION ALL SELECT 'Produto_Fornecedor: ' || COUNT(*)::text FROM produto_fornecedor
UNION ALL SELECT 'Vendas: ' || COUNT(*)::text FROM venda
UNION ALL SELECT 'Itens Venda: ' || COUNT(*)::text FROM item_venda
UNION ALL SELECT 'Pedidos Compra: ' || COUNT(*)::text FROM pedido_compra
UNION ALL SELECT 'Itens Pedido: ' || COUNT(*)::text FROM item_pedido_compra
UNION ALL SELECT 'Movimentações: ' || COUNT(*)::text FROM movimentacao_estoque;


SELECT ' SISTEMA COMPLETO CRIADO COM SUCESSO!' as status_final;
SELECT ' 14 TABELAS |  2 RELACIONAMENTOS 1:1 |  1 RELACIONAMENTO N:N' as estrutura;
SELECT ' 335+ INSERTS |  PERÍODO 2024-2025' as dados;
