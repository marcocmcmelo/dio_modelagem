-- Criação do banco de dados para cenário do e-commerce
create database ecommerce;
use ecommerce;

-- Criação das tabelas banco de dados ecommerce
create table clientes (
idcliente int auto_increment primary key,
pnome varchar(15) not null,
nomemeio varchar(10),
sobrenome varchar(30) not null,
cpf varchar(11) not null unique,
datanascimento date not null,
rua varchar(45) not null,
numrua varchar(10) not null,
complemento varchar(20),
bairro varchar(30) not null,
cidade varchar(30) not null,
uf varchar(20) not null,
telefone varchar(15) not null,
email varchar(100) unique,
datacadastro date not null,
situacao enum('Ativo','Inativo') default 'Ativo'
);

alter table clientes
add ididentificacao int,
add constraint fk_identificacao
foreign key (ididentificacao) references identificacao_cliente (ididentificacao);

select * from clientes;

describe clientes;

create table identificacao_cliente (
ididentificacao int auto_increment primary key,
tipo enum('CPF', 'CNPJ') not null,
identificacao VARCHAR(14) NOT NULL UNIQUE
);
describe identificacao_cliente;


create table categorias (
idcategoria int auto_increment primary key,
nome varchar(30) not null,
descricao text
);

create table produtos (
idproduto int auto_increment primary key,  
nome varchar(45) not null,
descricao text,
preco decimal(10, 2) not null,
idcategoria int,
dataCadastro DATE,
situacao enum('Ativo','Inativo'),
constraint fk_categoria foreign key(idcategoria) 
references categorias (idcategoria) -- chave estrangeira referente tabela categorias idcategoria
on delete set null on update cascade -- se excluir uma categoria o campo idcategoria na tabela produtos
                                     -- será definido como NULL, para evitar a exclusão automática 
                                     -- os produtos associados.
                                     -- se o valor de idcategoria sofrer alteração na tabela Categoria, 
                                     -- ele será atualizado automaticamente na tabela Produto.
);

create table pedidos(
idpedido int auto_increment primary key,
idcliente int not null,
descricao varchar(255),
dataPedido DATETIME DEFAULT CURRENT_TIMESTAMP,    
statuspedido enum('Em Andamento', 'Processando', 'Enviado', 'Entregue') DEFAULT 'Processando', 
frete decimal(10, 2), 
constraint fk_cliente_pedido foreign key (idcliente) references clientes (idcliente)
on delete cascade on update cascade
);

create table pagamentos (
idpagto int auto_increment primary key,
idpedido int,
tipo enum('Boleto', 'Cartão Débito', 'Cartão Crádito', 'Pix', 'Dinehiro'),
stauspagto enum('Pendente', 'Concluído', 'Cancelado'),
datapagto datetime,
valorpagto decimal(10,2),
foreign key(idpedido) references pedidos(idpedido)
);

create table cartao_credito (
idcartao int auto_increment primary key,
idpagto int,
nometitular varchar(100) not null,
ultimosquatrodigitos varchar(4) not null,
bandeira varchar(50),
token varchar(255),
foreign key(idpagto) references pagamentos(idpagto)
);

create table fornecedores (
idfornecedor int auto_increment primary key,
razaosocial varchar(100) not null,
cnpj varchar(14) not null,
f_rua varchar(45) not null,
f_numrua varchar(10) not null,
f_complemento varchar(20),
f_bairro varchar(30) not null,
f_cidade varchar(30) not null,
f_uf varchar(20) not null,
f_telefone varchar(15) not null,
f_email varchar(100) unique,
f_datacadastro date not null,
f_situacao enum('Ativo','Inativo') default 'Ativo'
);

create table terceiros_vendedor (
idterceiros int auto_increment primary key,
razaosocial varchar(100) not null,
cnpj_cpf varchar(14) not null unique,
endereco varchar(255) not null,
email varchar(100),
telefone varchar(15) not null
);


CREATE TABLE estoque (
idestoque int auto_increment primary key,
localizacao varchar(50),
quantidade int not null
);


create table entregas (
identrega int auto_increment primary key,
idpedido int,
endereco_entrega varchar(255) not null,
statusentrega enum('PENDENTE', 'EM_TRANSPORTE', 'ENTREGUE', 'CANCELADO') default 'PENDENTE',
data_envio datetime,
data_entrega datetime,
foreign key (idpedido) references pedidos (idpedido)
);

-- Tabela N:N entre terceiros e produtos
create table terceiros_produto(
idterceiros int,
idproduto int,
quantidade decimal(10,2),
primary key(idterceiros, idproduto),
foreign key(idterceiros) references terceiros_vendedor(idterceiros)
);

-- Tabela N:N entre fornecedores e produtos
create table fornecedor_produto (
idfornecedor int,
idproduto int,
primary key(idfornecedor, idproduto),
foreign key(idfornecedor) references fornecedores(idfornecedor),
foreign key(idproduto) references produtos(idproduto)
);

-- Tabela N:N entre produtos e estoque
create table produto_estoque(
idproduto int,
idestoque int,
primary key(idproduto, idestoque),
foreign key(idproduto) references produtos(idproduto),
foreign key(idestoque) references estoque(idestoque)
);

-- Tabela N:N entre produtos e pedidos
create table produto_pedido(
idproduto int,
idpedido int,
quantidade int not null,
primary key(idproduto, idpedido),
foreign key(idproduto) references produtos(idproduto),
foreign key(idpedido) references pedidos(idpedido)
);
-- inserindo dados na tabela cliente
insert into clientes (pnome, nomemeio, sobrenome, cpf, datanascimento, rua, numrua, complemento, bairro, cidade, uf, telefone, email, datacadastro, situacao)
values
('João', 'Carlos', 'Silva', '12345678901', '1985-03-15', 'Rua das Flores', '123', 'Apto 201', 'Centro', 'São Paulo', 'SP', '(11)91234-5678', 'joao.silva@email.com', '2025-01-05', 'Ativo'),
('Maria', 'Luiza', 'Oliveira', '98765432100', '1990-07-20', 'Av. Paulista', '567', NULL, 'Bela Vista', 'São Paulo', 'SP', '(11)99876-5432', 'maria.oliveira@email.com', '2025-01-05', 'Ativo'),
('Carlos', NULL, 'Santos', '45678912345', '1988-11-30', 'Rua do Comércio', '789', 'Casa', 'Vila Nova', 'Campinas', 'SP', '(19)91234-1234', 'carlos.santos@email.com', '2025-01-05', 'Ativo'),
('Ana', 'Clara', 'Souza', '32165498700', '1995-02-15', 'Travessa dos Lírios', '54B', 'Casa 2', 'Jardim América', 'Rio de Janeiro', 'RJ', '(21)99812-3412', 'ana.souza@email.com', '2025-01-05', 'Ativo'),
('Pedro', 'Henrique', 'Almeida', '78912345678', '1982-05-10', 'Alameda das Palmeiras', '101', NULL, 'Parque Verde', 'Curitiba', 'PR', '(41)91345-6789', 'pedro.almeida@email.com', '2025-01-05', 'Ativo'),
('Juliana', 'M.', 'Ferreira', '65432178900', '1991-09-25', 'Rua dos Ipês', '33', 'Apto 15', 'Boa Vista', 'Porto Alegre', 'RS', '(51)99987-6543', 'juliana.ferreira@email.com', '2025-01-05', 'Ativo'),
('Rafael', NULL, 'Martins', '14785236900', '1980-06-18', 'Av. Independência', '500', NULL, 'Centro', 'Salvador', 'BA', '(71)98123-4567', 'rafael.martins@email.com', '2025-01-05', 'Ativo'),
('Fernanda', 'A.', 'Lima', '96385274100', '1987-12-03', 'Rua da Paz', '89', 'Fundos', 'Jardim Botânico', 'Florianópolis', 'SC', '(48)99456-7890', 'fernanda.lima@email.com', '2025-01-05', 'Ativo'),
('Marcos', 'P.', 'Gomes', '75395185245', '1992-08-15', 'Rua São João', '12', 'Apto 10', 'Santa Cecília', 'Belo Horizonte', 'MG', '(31)98123-1122', 'marcos.gomes@email.com', '2025-01-05', 'Inativo'),
('Gabriela', 'L.', 'Barbosa', '95175345689', '1993-03-07', 'Rua das Acácias', '77', 'Bloco B', 'Cidade Alta', 'Recife', 'PE', '(81)99678-2345', 'gabriela.barbosa@email.com', '2025-01-05', 'Ativo'),
('Felipe', NULL, 'Rocha', '32178965432', '1989-01-21', 'Av. Brasil', '401', NULL, 'Centro', 'Fortaleza', 'CE', '(85)91234-5678', 'felipe.rocha@email.com', '2025-01-05', 'Ativo'),
('Bianca', 'S.', 'Carvalho', '85296374125', '1996-04-11', 'Rua das Hortênsias', '45', NULL, 'Jardim Europa', 'Goiânia', 'GO', '(62)99765-4321', 'bianca.carvalho@email.com', '2025-01-05', 'Ativo'),
('Thiago', 'M.', 'Ribeiro', '15975325845', '1984-10-30', 'Travessa do Sol', '89', NULL, 'Vila Rica', 'Natal', 'RN', '(84)91234-1111', 'thiago.ribeiro@email.com', '2025-01-05', 'Inativo'),
('Larissa', 'K.', 'Moraes', '45632178954', '1997-12-14', 'Rua dos Jacarandás', '23A', 'Sobrado', 'Jardim Imperial', 'Manaus', 'AM', '(92)99123-6789', 'larissa.moraes@email.com', '2025-01-05', 'Ativo'),
('Gustavo', 'R.', 'Teixeira', '78945612300', '1986-07-19', 'Alameda dos Pinhais', '11', NULL, 'Centro', 'Vitória', 'ES', '(27)99876-1122', 'gustavo.teixeira@email.com', '2025-01-05', 'Ativo');

select * from clientes;

-- inserindo dados na tabela identificação
insert into identificacao_cliente (tipo, identificacao)
values
('CPF', '12345678901'),
('CPF', '98765432100'),
('CPF', '45678912345'),
('CPF', '32165498700'),
('CPF', '78912345678'),
('CPF', '65432178900'),
('CPF', '14785236900'),
('CPF', '96385274100'),
('CPF', '75395185245'),
('CPF', '95175345689'),
('CNPJ', '12345678000101'),
('CNPJ', '98765432000122'),
('CNPJ', '45678912000133'),
('CNPJ', '32165498000144'),
('CNPJ', '78912345000155');

select * from identificacao_cliente;

-- inseridno dados na tabela categorias
insert into categorias (nome, descricao)
values
('Eletrônicos', 'Produtos relacionados a tecnologia, como celulares, tablets e computadores.'),
('Roupas', 'Vestuário masculino, feminino e infantil para diferentes ocasiões.'),
('Calçados', 'Calçados esportivos, sociais e casuais para todas as idades.'),
('Móveis', 'Móveis para casa, escritório e jardim.'),
('Alimentos', 'Produtos alimentícios perecíveis e não perecíveis.'),
('Bebidas', 'Bebidas alcoólicas e não alcoólicas.'),
('Livros', 'Livros de ficção, não-ficção, acadêmicos e técnicos.'),
('Brinquedos', 'Brinquedos e jogos educativos para crianças de todas as idades.'),
('Ferramentas', 'Ferramentas manuais e elétricas para construção e reparos.'),
('Esportes', 'Artigos esportivos para diferentes modalidades e práticas.'),
('Beleza e Cuidados Pessoais', 'Produtos de beleza, higiene e cuidados pessoais.'),
('Papelaria', 'Material de escritório e escolar.'),
('Automotivo', 'Produtos e acessórios para veículos.'),
('Decoração', 'Artigos para decorar ambientes residenciais e comerciais.'),
('Jardinagem', 'Ferramentas, plantas e acessórios para jardinagem.');

select * from categorias;

-- inserindo dados na tabela produtos
insert into produtos (nome, descricao, preco, idcategoria, dataCadastro, situacao)
values
('Smartphone X', 'Celular com tela de 6.5 polegadas, 128GB de armazenamento.', 2999.90, 1, '2025-01-05', 'Ativo'),
('Notebook Pro', 'Notebook com processador Intel i7, 16GB RAM, SSD 512GB.', 5599.90, 1, '2025-01-05', 'Ativo'),
('Camiseta Básica', 'Camiseta de algodão disponível em diversas cores.', 49.90, 2, '2025-01-05', 'Ativo'),
('Tênis Esportivo', 'Tênis confortável para atividades físicas.', 199.90, 3, '2025-01-05', 'Ativo'),
('Sofá 3 Lugares', 'Sofá confortável em tecido, ideal para salas de estar.', 1899.90, 4, '2025-01-05', 'Ativo'),
('Cadeira de Escritório', 'Cadeira ergonômica com ajuste de altura.', 399.90, 4, '2025-01-05', 'Ativo'),
('Arroz 5kg', 'Pacote de arroz branco tipo 1, 5kg.', 23.90, 5, '2025-01-05', 'Ativo'),
('Refrigerante Cola 2L', 'Refrigerante sabor cola, garrafa de 2 litros.', 7.50, 6, '2025-01-05', 'Ativo'),
('Livro de Ficção', 'Romance best-seller com mais de 500 páginas.', 39.90, 7, '2025-01-05', 'Ativo'),
('Quebra-Cabeça 1000 Peças', 'Quebra-cabeça temático para adultos.', 59.90, 8, '2025-01-05', 'Ativo'),
('Furadeira Elétrica', 'Furadeira elétrica com 500W de potência.', 299.90, 9, '2025-01-05', 'Ativo'),
('Bola de Futebol', 'Bola oficial para partidas de futebol.', 129.90, 10, '2025-01-05', 'Ativo'),
('Shampoo Anticaspa', 'Shampoo anticaspa para todos os tipos de cabelo.', 25.90, 11, '2025-01-05', 'Ativo'),
('Lápis de Cor 24 Cores', 'Conjunto de lápis de cor de alta qualidade.', 19.90, 12, '2025-01-05', 'Ativo'),
('Suporte para Celular Automotivo', 'Suporte ajustável para fixar o celular no carro.', 39.90, 13, '2025-01-05', 'Ativo');

select * from produtos;

-- inserindo dados tabela pedidos
insert into pedidos (idcliente, descricao, dataPedido, statuspedido, frete)
values
('Pedido de Eletrônicos e Roupas', '2025-01-06 10:00:00', 'Em Andamento', 15.50),
('Pedido de Móveis e Decoração', '2025-01-06 12:30:00', 'Processando', 25.00),
('Pedido de Alimentos e Bebidas', '2025-01-06 14:00:00', 'Enviado', 10.00),
('Pedido de Livros e Papelaria', '2025-01-06 16:15:00', 'Entregue', 8.50),
('Pedido de Ferramentas e Esportes', '2025-01-07 09:00:00', 'Processando', 12.00),
('Pedido de Beleza e Cuidados', '2025-01-07 11:20:00', 'Em Andamento', 7.50),
('Pedido de Automotivo e Jardinagem', '2025-01-07 13:40:00', 'Enviado', 18.00),
('Pedido de Eletrônicos', '2025-01-07 15:00:00', 'Entregue', 20.00),
('Pedido de Roupas e Calçados', '2025-01-07 16:50:00', 'Em Andamento', 9.00),
('Pedido de Brinquedos', '2025-01-08 10:30:00', 'Processando', 15.00),
('Pedido de Produtos Diversos', '2025-01-08 12:45:00', 'Enviado', 5.00),
('Pedido de Produtos Automotivos', '2025-01-08 14:15:00', 'Entregue', 22.50),
('Pedido de Produtos Esportivos', '2025-01-08 16:00:00', 'Processando', 18.90),
('Pedido de Decoração e Móveis', '2025-01-08 17:25:00', 'Entregue', 13.00),
('Pedido de Papelaria e Livros', '2025-01-08 19:00:00', 'Em Andamento', 8.70);

select * from pedidos;

-- inserindo dados na tabela pagamentos
insert into pagamentos (tipo, stauspagto, datapagto, valorpagto)
values
('Pix', 'Concluído', '2025-01-06 10:15:00', 1015.50),
('Cartão Crédito', 'Concluído', '2025-01-06 12:45:00', 2025.00),
('Boleto', 'Pendente', '2025-01-06 14:30:00', 610.00),
('Cartão Débito', 'Concluído', '2025-01-06 16:30:00', 508.50),
('Pix', 'Concluído', '2025-01-07 09:20:00', 1012.00),
('Dinehiro', 'Pendente', '2025-01-07 11:30:00', 507.50),
('Boleto', 'Concluído', '2025-01-07 13:50:00', 1018.00),
('Cartão Débito', 'Concluído', '2025-01-07 15:20:00', 1020.00),
('Cartão Crédito', 'Pendente', '2025-01-07 17:00:00', 609.00),
('Pix', 'Concluído', '2025-01-08 10:50:00', 1015.00),
('Dinehiro', 'Concluído', '2025-01-08 13:00:00', 1005.00),
('Boleto', 'Pendente', '2025-01-08 14:30:00', 1022.50),
('Cartão Débito', 'Concluído', '2025-01-08 16:30:00', 1018.90),
('Pix', 'Concluído', '2025-01-08 18:00:00', 1013.00),
('Cartão Crédito', 'Concluído', '2025-01-08 19:15:00', 1008.70);

select * from pagamentos;

-- inserindo dados tabela cartão crédito
insert into cartao_credito (idpagto, nometitular, ultimosquatrodigitos, bandeira, token)
values
(2, 'João Carlos Silva', '1234', 'Visa', 'ABC123TOKEN'),
(9, 'Maria Luiza Oliveira', '5678', 'MasterCard', 'DEF456TOKEN'),
(15, 'Carlos Henrique Santos', '9876', 'Elo', 'GHI789TOKEN');

select * from cartao_credito;

-- inserindo dados tabela fornecedores
insert into fornecedores (razaosocial, cnpj, f_rua, f_numrua, f_complemento, f_bairro, f_cidade, f_uf, f_telefone, f_email, f_datacadastro, f_situacao)
values
('Tech Eletrônicos Ltda', '12345678000123', 'Av. Paulista', '100', 'Bloco A', 'Centro', 'São Paulo', 'SP', '(11)91234-5678', 'tech.eletronicos@email.com', '2025-01-05', 'Ativo'),
('Moda Brasil S.A.', '98765432000122', 'Rua das Flores', '200', NULL, 'Bela Vista', 'São Paulo', 'SP', '(11)99876-5432', 'moda.brasil@email.com', '2025-01-05', 'Ativo'),
('Moveis Conforto ME', '65432178000111', 'Av. Brasil', '300', 'Casa 1', 'Centro', 'Curitiba', 'PR', '(41)91234-1234', 'moveis.conforto@email.com', '2025-01-05', 'Inativo'),
('Alimentos Gourmet LTDA', '32145678000166', 'Rua da Paz', '400', NULL, 'Jardim Botânico', 'Rio de Janeiro', 'RJ', '(21)99812-3412', 'alimentos.gourmet@email.com', '2025-01-05', 'Ativo');

select * from fornecedores;

-- inserindo dados na tabela terceiros vendedor
insert into terceiros_vendedor (razaosocial, cnpj_cpf, endereco, email, telefone)
values
('Distribuidora LTDA', '32145678901', 'Rua dos Cravos, 150, São Paulo - SP', 'distribuidora@email.com', '(11)91234-5678'),
('Representações Santos', '65432198701', 'Av. João Pessoa, 320, Belo Horizonte - MG', 'santos@email.com', '(31)98765-4321');

select * from terceiros_vendedor;

-- inserindo dados na tabela estoque
insert into estoque (localizacao, quantidade)
values
('Armazém A - Setor 1', 100),
('Armazém A - Setor 2', 150),
('Armazém B - Setor 3', 200),
('Armazém B - Setor 4', 300),
('Armazém C - Setor 5', 250),
('Depósito Principal - Norte', 400),
('Depósito Secundário - Sul', 350),
('Armazém D - Setor 6', 180),
('Armazém E - Setor 7', 220),
('Depósito Central - Oeste', 500),
('Armazém F - Setor 8', 130),
('Armazém G - Setor 9', 170),
('Armazém H - Setor 10', 300),
('Depósito Avançado - Leste', 450),
('Armazém I - Setor 11', 280);

select * from estoque;

-- inserindo dados tabela entregas
insert into entregas (idpedido, endereco_entrega, statusentrega, data_envio, data_entrega)
values
(1, 'Rua das Palmeiras, 123, São Paulo - SP', 'EM_TRANSPORTE', '2025-01-06 12:00:00', NULL),
(2, 'Av. Paulista, 456, São Paulo - SP', 'ENTREGUE', '2025-01-06 10:30:00', '2025-01-06 18:00:00'),
(3, 'Rua das Flores, 789, Rio de Janeiro - RJ', 'ENTREGUE', '2025-01-06 09:00:00', '2025-01-07 14:00:00'),
(4, 'Rua da Harmonia, 234, Curitiba - PR', 'CANCELADO', '2025-01-07 11:30:00', NULL),
(5, 'Av. Brasil, 567, Brasília - DF', 'EM_TRANSPORTE', '2025-01-07 15:00:00', NULL),
(6, 'Rua das Amoras, 890, Belo Horizonte - MG', 'ENTREGUE', '2025-01-08 08:00:00', '2025-01-09 16:30:00'),
(7, 'Av. Central, 345, Salvador - BA', 'ENTREGUE', '2025-01-08 10:00:00', '2025-01-10 13:00:00'),
(8, 'Rua Nova, 678, Fortaleza - CE', 'PENDENTE', NULL, NULL),
(9, 'Av. Rio Branco, 912, Recife - PE', 'EM_TRANSPORTE', '2025-01-08 13:30:00', NULL),
(10, 'Rua das Laranjeiras, 456, Porto Alegre - RS', 'ENTREGUE', '2025-01-09 14:00:00', '2025-01-10 20:00:00'),
(11, 'Av. Getúlio Vargas, 321, Manaus - AM', 'PENDENTE', NULL, NULL),
(12, 'Rua São Francisco, 789, Florianópolis - SC', 'CANCELADO', NULL, NULL),
(13, 'Av. João Pessoa, 654, Natal - RN', 'EM_TRANSPORTE', '2025-01-10 08:30:00', NULL),
(14, 'Rua Independência, 987, Vitória - ES', 'ENTREGUE', '2025-01-10 10:00:00', '2025-01-11 19:00:00'),
(15, 'Av. Goiás, 111, Goiânia - GO', 'PENDENTE', NULL, NULL);

select * from entregas;

-- inserindo dados tabela terceiros produto
insert into terceiros_produto (idterceiros, idproduto, quantidade)
values
(1, 1, 50.00),
(2, 3, 40.00);

select * from terceiros_produto;

-- inserindo dados tabela fornecedor produto
insert into fornecedor_produto (idfornecedor, idproduto)
values
(1, 1),
(2, 2),
(3, 3),
(4, 4);

select * from fornecedor_produto;

-- inserindo dados tabela produto estoque
insert into produto_estoque (idproduto, idestoque)
values
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(11, 11),
(12, 12),
(13, 13),
(14, 14),
(15, 15);

select * from produto_estoque;

-- inserindo dados na tabela produto pedido
insert into produto_pedido (idproduto, idpedido, quantidade)
values
(1, 1, 2),
(2, 1, 1),
(3, 2, 3),
(4, 2, 1),
(5, 3, 4),
(6, 3, 2),
(7, 4, 1),
(8, 5, 5),
(9, 6, 2),
(10, 7, 1),
(11, 8, 3),
(12, 9, 4),
(13, 10, 2),
(14, 11, 1),
(15, 12, 3);

select * from produto_pedido;

-- Recuperações simples com SELECT Statement
-- Filtros com WHERE Statement
-- Crie expressões para gerar atributos derivados
-- Defina ordenações dos dados com ORDER BY
-- Condições de filtros aos grupos – HAVING Statement
-- Crie junções entre tabelas para fornecer uma perspectiva mais complexa dos dados

select * from clientes;

select * from produtos;

select * from fornecedores;

select * from pedidos;

select * from clientes where datanascimento > '1990-01-01';

select pnome, cpf, datanascimento from clientes where datanascimento > '1990-01-01';

select * from produtos where preco <= 500.00;

select  nome, descricao, preco from produtos where preco <= 500.00;

select * from fornecedores where f_uf = 'SP';

select razaosocial, f_telefone from fornecedores where f_uf = 'SP';

select * from pagamentos;

select idpedido, tipo, valorpagto, round(valorpagto * 0.05,2) as comissao
from pagamentos where tipo = 'Pix';

select * from produtos;

select nome, preco, round(preco * 0.12,2) as ICMS from produtos;

select * from produtos where preco >= 100.00
order by preco;

select * from produtos where preco <= 2000.00
order by preco desc;

select uf, count(idcliente) as total_clientes from clientes group by uf;

select statusentrega, count(identrega) as total_entrega from entregas group by statusentrega;

select uf, count(idcliente) as total_clientes from clientes group by uf having count(idcliente) > 1;

select uf, count(idcliente) as total_clientes from clientes group by uf having count(idcliente) <= 2;

select idpagto, sum(valorpagto) as total_pagamentos from pagamentos 
group by idpagto having sum(valorpagto) > 1000 order by total_pagamentos;

select f.razaosocial as fornecedor, p.nome as produto, fp.idfornecedor, fp.idproduto
from fornecedor_produto fp
join fornecedores f on fp.idfornecedor = f.idfornecedor
join produtos p on fp.idproduto = p.idproduto;

select p.idpedido as pedido_id, p.descricao as descricao_pedido, pg.tipo as tipo_pagamento,
pg.valorpagto as valor_pagamento, pg.stauspagto as staus_pagamento, c.nometitular as titular_cartao,
c.ultimosquatrodigitos as ultimos_digitos_cartao, c.bandeira as bandeira_cartao
from pedidos p
join pagamentos pg on p.idpedido = pg.idpedido
left join cartao_credito c on pg.idpagto;