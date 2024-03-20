
-- PROCEDURES auxiliares 
CREATE OR REPLACE PROCEDURE PROC_CADASTRAR_HOSPEDE (CPF_HOSPEDE VARCHAR2, NOME_HOSPEDE VARCHAR2) IS
BEGIN
    INSERT INTO HOSPEDE VALUES (
        CPF_HOSPEDE,
        NOME_HOSPEDE
    );
    DBMS_OUTPUT.PUT_LINE('Hospede cadastrado');
END;

CREATE OR REPLACE PROCEDURE PROC_CADASTRAR_TELEFONE_HOSPEDES (CPF_HOSPEDE VARCHAR2, NUM_TELEFONE_HOSPEDE VARCHAR2) IS
BEGIN
    INSERT INTO TELEFONE_HOSPEDES VALUES (
        CPF_HOSPEDE,
        NUM_TELEFONE_HOSPEDE
    );
    DBMS_OUTPUT.PUT_LINE('Telefone de hospede cadastrado');
END;


CREATE OR REPLACE PROCEDURE PROC_CADASTRAR_RESPONSAVEL (CPF_HOSPEDE VARCHAR2, CONTA_RESPONSAVEL VARCHAR2) IS
BEGIN
    INSERT INTO RESPONSAVEL VALUES (
        CPF_HOSPEDE,
        CONTA_RESPONSAVEL
    );
    DBMS_OUTPUT.PUT_LINE('Responsavel cadastrado');
END;


CREATE OR REPLACE PROCEDURE PROC_CADASTRAR_HOSPEDAGEM (COD_HOTEL NUMBER, NUM_FLAT NUMBER, DT_INIC VARCHAR2, DT_FIM VARCHAR2) IS
BEGIN
    INSERT INTO HOSPEDAGEM VALUES (
        SEQ_HOSPEDAGENS.nextval,
        COD_HOTEL,
        NUM_FLAT,
        DT_INIC,
        DT_FIM
    );
    DBMS_OUTPUT.PUT_LINE('Hospedagem cadastrada');
END;


CREATE OR REPLACE PROCEDURE PROC_CADASTRAR_HOSPEDE_OCUPA_HOSPEDAGEM (CPF_HOSPEDE VARCHAR2, COD_HOSPEDAGENS NUMBER) IS
BEGIN
    INSERT INTO HOSPEDE_OCUPA_HOSPEDAGEM VALUES (
        CPF_HOSPEDE,
        COD_HOSPEDAGENS
    );
    DBMS_OUTPUT.PUT_LINE('Ocupação cadastrado');
END;


CREATE OR REPLACE PROCEDURE PROC_CADASTRAR_PEDE (CPF_HOSPEDE VARCHAR2, COD_SERVICOS_ADICIONAIS NUMBER, CPF_FUNCIONARIO VARCHAR2) IS
BEGIN
    INSERT INTO PEDE VALUES (
        CPF_HOSPEDE,
        COD_SERVICOS_ADICIONAIS,
        SYSDATE,
        CPF_FUNCIONARIO
    );
    DBMS_OUTPUT.PUT_LINE('Pedido de serviço emitido');
END;


CREATE OR REPLACE PROCEDURE PROC_CADASTRAR_RESPONSAVEL_PAGA_HOSPEDAGEM (CPF_HOSPEDE VARCHAR2, COD_HOSPEDAGENS NUMBER, COD_PROMOCAO NUMBER) IS
BEGIN
    INSERT INTO PROMOCAO VALUES (
        CPF_HOSPEDE,
        COD_HOSPEDAGENS,
        COD_PROMOCAO
    );
    DBMS_OUTPUT.PUT_LINE('Pagamento de hospedagem cadastrado');
END;


-- PROCEDURES do sistema

-- Proc de nova reserva
CREATE OR REPLACE PROCEDURE PROC_RESERVAR_FLAT (V_CPF_RESPONSAVEL VARCHAR2, NOME_RESPONSAVEL VARCHAR2, NUM_TELEFONE VARCHAR2, V_COD_HOTEL NUMBER, V_DT_FIM DATE) IS
DECLARE
    V_NUM_FLAT_DISP NUMBER := NULL;
    V_COUNT NUMBER := NULL;
    V_COD_NEW_HOSPEDAGEM := NULL;
BEGIN
    -- Busca um flat disponivel
    SELECT NUM_FLAT INTO V_NUM_FLAT_DISP FROM FLATS
    WHERE STATUS_FLAT = 'Disponível'
    FETCH FIRST 1 ROWS ONLY;

    -- Verifica se responsável já está cadastrado no hotel
    SELECT COUNT(*) INTO V_COUNT FROM HOSPEDE WHERE CPF_HOSPEDE = V_CPF_RESPONSAVEL;
    IF V_COUNT = 0 THEN
        CALL PROC_CADASTRAR_HOSPEDE(V_CPF_RESPONSAVEL, NOME_RESPONSAVEL);
        CALL PROC_CADASTRAR_TELEFONE_HOSPEDES(V_CPF_RESPONSAVEL, NUM_TELEFONE);
        CALL PROC_CADASTRAR_RESPONSAVEL(V_CPF_RESPONSAVEL)
    END IF;

    -- Registra hospedagem
    CALL PROC_CADASTRAR_HOSPEDAGEM(V_COD_HOTEL, V_NUM_FLAT_DISP, SYSDATE, V_DT_FIM);
    
    -- Atualiza o status do flat
    UPDATE FLATS
    SET STATUS_FLAT = 'Ocupado'
    WHERE COD_HOTEL = V_COD_HOTEL AND NUM_FLAT = V_NUM_FLAT_DISP;

    -- Pega o cod da hospedagem e registra a ocupação do hospede
    SELECT COD_HOSPEDAGENS INTO V_COD_NEW_HOSPEDAGEM FROM HOSPEDAGENS
    WHERE COD_HOTEL = V_COD_HOTEL AND NUM_FLAT = V_NUM_FLAT_DISP AND DT_FIM = V_DT_FIM;

    CALL PROC_CADASTRAR_HOSPEDE_OCUPA_HOSPEDAGEM(V_CPF_RESPONSAVEL, V_COD_NEW_HOSPEDAGEM);
    
    DBMS_OUTPUT.PUT_LINE('Reserva de flat realizada, por favor realize o cadastro dos demais hospedes, se houver.');

END;

-- Proc inserir responsaveis no pagamento 
CREATE OR REPLACE PROC_INSERIR_RESPONSAVEL_NO_PAGAMENTO (V_CPF_NEW_RESPONSAVEL VARCHAR2, V_NUM_FLAT NUMBER, V_COD_HOTEL NUMBER, V_DT_INIC DATE, V_DT_FIM DATE) IS
DECLARE 
    V_COD_HOSPEDAGEM NUMBER := NULL;
    V_COUNT NUMBER := NULL;
BEGIN  
    -- busca cod_hospedagem para pagamento
    SELECT COD_HOSPEDAGENS INTO V_COD_HOSPEDAGEM FROM HOSPEDAGENS
    WHERE NUM_FLAT = V_NUM_FLAT AND COD_HOTEL = V_COD_HOTEL AND DT_INIC = V_DT_INIC AND DT_FIM = V_DT_FIM

    -- verifica se o responsável já foi cadastrado
    SELECT COUNT(*) INTO V_COUNT FROM RESPONSAVEL WHERE CPF_HOSPEDE = V_CPF_NEW_RESPONSAVEL;
    IF V_COUNT = 0 THEN
        CALL PROC_CADASTRAR_RESPONSAVEL(V_CPF_NEW_RESPONSAVEL);
    END IF;

    -- Insere o responsável na conta do responsável
    CALL PROC_CADASTRAR_RESPONSAVEL_PAGA_HOSPEDAGEM(V_CPF_NEW_RESPONSAVEL, V_COD_HOSPEDAGEM);
    DBMS_OUTPUT.PUT_LINE('Novo responsável adicionado ao pagamento da hospedagem!');
END;

-- Proc de pedir um serviço adicional
CREATE OR REPLACE PROC_PEDIR_SERVICO_ADICIONAL (V_CPF_RESPONSAVEL VARCHAR2, V_COD_SERVICO_ADICIONAL NUMBER, V_CPF_FUNCIONARIO_PEDIDO VARCHAR2) IS
DECLARE
    V_CUSTO_ADICIONAL VARCHAR2 := NULL;
BEGIN  

    -- Registra o pedido
    CALL PROC_CADASTRAR_PEDE(V_CPF_RESPONSAVEL, V_COD_SERVICO_ADICIONAL, V_CPF_FUNCIONARIO_PEDIDO);

    -- Busca custo do serviço
    SELECT CUSTO_ADICIONAL INTO V_CUSTO_ADICIONAL FROM SERVICOS_ADICIONAIS
    WHERE COD_SERVICOS_ADICIONAIS = V_COD_SERVICO_ADICIONAL;

    -- Print do custo do serviço pedido
    DBMS_OUTPUT.PUT_LINE('Um serviço adicional foi pedido no custo de R$'|| REPLACE(V_CUSTO_ADICIONAL, '.', ',')||'');
END;

-- FUNÇÕES
CREATE FUNCTION FC_VALIDAR_CPF(CPF IN VARCHAR2) RETURN INTEGER
IS
    TYPE CPF_INVALIDO_ARRAY IS TABLE OF VARCHAR2(11);

    CPFS_INVALIDOS CPF_INVALIDO_ARRAY := CPF_INVALIDO_ARRAY('00000000000', '11111111111',
                                          '22222222222', '33333333333',
                                          '44444444444', '55555555555',
                                          '66666666666', '77777777777',
                                          '88888888888', '99999999999');
BEGIN
    IF CPF IS NULL OR LENGTH(CPF) <> 11 OR CPF MEMBER OF CPFS_INVALIDOS THEN
        DBMS_OUTPUT.PUT_LINE('O CPF é inválido');
        RETURN 0;
    END IF;

    DBMS_OUTPUT.PUT_LINE('O CPF é válido!');
    RETURN 1; 
END;

-- TRIGGERs

CREATE OR REPLACE TRIGGER VALIDAR_CPF_HOSPEDE
BEFORE INSERT ON HOSPEDE
FOR EACH ROW
DECLARE
    V_COUNT NUMBER := NULL;
BEGIN
    -- Verifica se o CPF já existe na tabela HOSPEDE
    SELECT COUNT(*) INTO V_COUNT FROM HOSPEDE WHERE CPF_HOSPEDE = :NEW.CPF_HOSPEDE;
    IF V_COUNT > 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'CPF já existe na tabela HOSPEDE');
    END IF;

    IF FC_VALIDAR_CPF(:NEW.CPF_HOSPEDE) = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'CPF inválido');
    END IF;

END;

CREATE OR REPLACE TRIGGER VALIDAR_CPF_FUNCIONARIO
BEFORE INSERT ON FUNCIONARIO
FOR EACH ROW
DECLARE
    V_COUNT NUMBER := NULL;
BEGIN
    -- Verifica se o CPF já existe na tabela FUNCIONARIO
    SELECT COUNT(*) INTO V_COUNT FROM FUNCIONARIO WHERE CPF_FUNCIONARIO = :NEW.CPF_FUNCIONARIO;
    IF V_COUNT > 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'CPF já existe na tabela FUNCIONARIO');
    END IF;

    IF FC_VALIDAR_CPF(:NEW.CPF_FUNCIONARIO) = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'CPF inválido');
    END IF;

END;
