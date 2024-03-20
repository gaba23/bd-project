-- Criação tabela HOSPEDE
CREATE TABLE HOSPEDE(
    CPF_HOSPEDE VARCHAR2(11) NOT NULL,
    NOME_HOSPEDE VARCHAR2(100) NULL,
    CONSTRAINT PK_HOSPEDE PRIMARY KEY(CPF_HOSPEDE)
);

-- Criação tabela HOTEL
CREATE TABLE HOTEL(
    COD_HOTEL NUMBER NOT NULL,
    NUM_HOTEL NUMBER NULL,
    CEP_HOTEL VARCHAR2(8) NULL,
    CONSTRAINT PK_QUARTO PRIMARY KEY(COD_HOTEL)
);

-- Criação tabela FLATS
CREATE TABLE FLATS(
    COD_HOTEL NUMBER NOT NULL,
    NUM_FLAT NUMBER NOT NULL,
    STATUS_FLAT VARCHAR2(50) NULL,
    CONSTRAINT FK_FLAT_HOTEL FOREIGN KEY(COD_HOTEL) REFERENCES HOTEL(COD_HOTEL),
    CONSTRAINT PK_FLAT PRIMARY KEY(COD_HOTEL, NUM_FLAT)
);

-- Criação tabela TELEFONE_HOSPEDES
CREATE TABLE TELEFONE_HOSPEDES(
    CPF_HOSPEDE VARCHAR2(11) NOT NULL,
    NUM_TELEFONE_HOSPEDE VARCHAR2(9) NOT NULL,
    CONSTRAINT FK_TELEFONE_HOSPEDES FOREIGN KEY(CPF_HOSPEDE) REFERENCES HOSPEDE(CPF_HOSPEDE),
    CONSTRAINT PK_TELEFONE_HOSPEDES PRIMARY KEY(CPF_HOSPEDE, NUM_TELEFONE_HOSPEDE)
);

-- Criação tabela RESPONSAVEL
CREATE TABLE RESPONSAVEL(
    CPF_HOSPEDE VARCHAR2(11) NOT NULL,
    CONTA_RESPONSAVEL VARCHAR2(50) NULL,
    CONSTRAINT FK_RESPONSAVEL_HOSPEDE FOREIGN KEY(CPF_HOSPEDE) REFERENCES HOSPEDE(CPF_HOSPEDE),
    CONSTRAINT PK_RESPONSAVEL PRIMARY KEY(CPF_HOSPEDE)
);

-- Criação tabela HOSPEDAGENS
CREATE TABLE HOSPEDAGENS(
    COD_HOSPEDAGENS NUMBER NOT NULL,
    COD_HOTEL NUMBER NOT NULL,
    NUM_FLAT NUMBER NOT NULL,
    DT_INIC DATE NULL,
    DT_FIM DATE NULL,
    CONSTRAINT FK_HOSPEDAGENS_FLATS FOREIGN KEY(COD_HOTEL, NUM_FLAT) REFERENCES FLATS(COD_HOTEL, NUM_FLAT),
    CONSTRAINT PK_HOSPEDAGENS PRIMARY KEY(COD_HOSPEDAGENS)
);

-- Criação tabela HOSPEDE_OCUPA_HOSPEDAGEM
CREATE TABLE HOSPEDE_OCUPA_HOSPEDAGEM(
    CPF_HOSPEDE VARCHAR2(11) NOT NULL,
    COD_HOSPEDAGENS NUMBER NOT NULL,
    CONSTRAINT FK_HOSPEDE_OCUPA_HOSPEDAGEM_CPF_HOSPEDE FOREIGN KEY(CPF_HOSPEDE) REFERENCES HOSPEDE(CPF_HOSPEDE),
    CONSTRAINT FK_HOSPEDE_OCUPA_HOSPEDAGEM_COD_HOSPEDAGENS FOREIGN KEY(COD_HOSPEDAGENS) REFERENCES HOSPEDAGENS(COD_HOSPEDAGENS),
    CONSTRAINT PK_HOSPEDE_OCUPA_HOSPEDAGEM PRIMARY KEY(CPF_HOSPEDE, COD_HOSPEDAGENS)
);

-- Criação tabela SERVICOS_ADICIONAIS
CREATE TABLE SERVICOS_ADICIONAIS(
    COD_SERVICOS_ADICIONAIS NUMBER NOT NULL,
    CUSTO_ADICIONAL VARCHAR2(50) NULL,
    CONSTRAINT PK_SERVICOS_ADICIONAIS PRIMARY KEY(COD_SERVICOS_ADICIONAIS)
);

-- Criação tabela FUNCIONARIO
CREATE TABLE FUNCIONARIO (
   CPF_FUNCIONARIO VARCHAR2(11) NOT NULL,
   NOME_FUNCIONARIO VARCHAR2(100) NULL,
   CARGO_FUNCIONARIO VARCHAR2(50) NULL,
   CPF_CHEFE VARCHAR2(11) NULL,
   COD_HOTEL NUMBER NOT NULL,
   CONSTRAINT FK_FUNCIONARIO_CHEFE FOREIGN KEY (CPF_CHEFE) REFERENCES FUNCIONARIO(CPF_FUNCIONARIO),
   CONSTRAINT FK_FUNCIONARIO_HOTEL FOREIGN KEY (COD_HOTEL) REFERENCES HOTEL(COD_HOTEL),
   CONSTRAINT PK_FUNCIONARIO PRIMARY KEY (CPF_FUNCIONARIO)
);

-- Criação tabela CRACHA
CREATE TABLE CRACHA (
   MAT_CRACHA NUMBER NOT NULL,
   DT_EMISSAO_CRACHA DATE NOT NULL,
   CPF_FUNCIONARIO VARCHAR2(11) NOT NULL,
   CONSTRAINT FK_CRACHA_FUNCIONARIO FOREIGN KEY (CPF_FUNCIONARIO) REFERENCES FUNCIONARIO(CPF_FUNCIONARIO),
   CONSTRAINT CRACHA_CPF_FUNCIONARIO_UNIQUE UNIQUE (CPF_FUNCIONARIO),
   CONSTRAINT PK_CRACHA PRIMARY KEY (MAT_CRACHA)
);


-- Criação tabela PEDE
CREATE TABLE PEDE (
   CPF_HOSPEDE VARCHAR2(11) NOT NULL,
   COD_SERVICOS_ADICIONAIS NUMBER NOT NULL,
   INSTANTE DATE NOT NULL,
   CPF_FUNCIONARIO VARCHAR2(11) NOT NULL
   CONSTRAINT FK_PEDE_RESPONSAVEL FOREIGN KEY (CPF_HOSPEDE) REFERENCES RESPONSAVEL(CPF_HOSPEDE),
   CONSTRAINT FK_PEDE_SERVICOS_ADICIONAIS FOREIGN KEY (COD_SERVICOS_ADICIONAIS) REFERENCES SERVICOS_ADICIONAIS(COD_SERVICOS_ADICIONAIS),
   CONSTRAINT FK_PEDE_FUNCIONARIO FOREIGN KEY (CPF_FUNCIONARIO) REFERENCES FUNCIONARIO(CPF_FUNCIONARIO),
   CONSTRAINT PK_PEDE PRIMARY KEY (CPF_HOSPEDE, COD_SERVICOS_ADICIONAIS, INSTANTE, CPF_FUNCIONARIO)
);

-- Criação tabela PROMOCAO
CREATE TABLE PROMOCAO (
   COD_PROMOCAO NUMBER NOT NULL,
   DESCONTO VARCHAR2(50) NULL,
   CONSTRAINT PK_PROMOCAO PRIMARY KEY (COD_PROMOCAO)
);

-- Criação tabela RESPONSAVEL_PAGA_HOSPEDAGEM
CREATE TABLE RESPONSAVEL_PAGA_HOSPEDAGEM (
   CPF_HOSPEDE VARCHAR2(11) NOT NULL,
   COD_HOSPEDAGENS NUMBER NOT NULL,
   COD_PROMOCAO NUMBER,
   CONSTRAINT FK_RESPONSAVEL_PAGA_HOSPEDAGEM_RESPONSAVEL FOREIGN KEY (CPF_HOSPEDE) REFERENCES RESPONSAVEL(CPF_HOSPEDE),
   CONSTRAINT FK_RESPONSAVEL_PAGA_HOSPEDAGEM_HOSPEDAGENS FOREIGN KEY (COD_HOSPEDAGENS) REFERENCES HOSPEDAGENS(COD_HOSPEDAGENS),
   CONSTRAINT FK_RESPONSAVEL_PAGA_HOSPEDAGEM_PROMOCAO FOREIGN KEY (COD_PROMOCAO) REFERENCES PROMOCAO(COD_PROMOCAO),
   CONSTRAINT PK_RESPONSAVEL_PAGA_HOSPEDAGEM PRIMARY KEY (CPF_HOSPEDE, COD_HOSPEDAGENS)
);


CREATE SEQUENCE SEQ_HOTEL INCREMENT BY 1 MINVALUE 1 MAXVALUE 9999999999999999999999999999; 
CREATE SEQUENCE SEQ_HOSPEDAGENS INCREMENT BY 1 MINVALUE 1 MAXVALUE 9999999999999999999999999999;
CREATE SEQUENCE SEQ_CRACHA INCREMENT BY 1 MINVALUE 1 MAXVALUE 9999999999999999999999999999; 
CREATE SEQUENCE SEQ_SERVICOS_ADICIONAIS INCREMENT BY 1 MINVALUE 1 MAXVALUE 9999999999999999999999999999;
CREATE SEQUENCE SEQ_PROMOCAO INCREMENT BY 1 MINVALUE 1 MAXVALUE 9999999999999999999999999999;
