
/* DELETANDO FUNCTION INSERIR_ALUNO */
DROP FUNCTION INSERIR_ALUNO(INT,TEXT,TEXT,DATE,TEXT,TEXT,FLOAT)

/* DELETANDO FUNCTION ALUNO_EXISTENTE */
DROP FUNCTION USUARIO_EXISTENTE(TEXT, TEXT)

/* DELETANDO FUNCTION EMAIL_EXISTENTE */
DROP FUNCTION EMAIL_EXISTENTE(TEXT, TEXT)

/* DELETANDO VERIFICAR_INSERCAO */
DROP FUNCTION VERIFICA_INSERCAO()

/* CRIANDO FUNCTION INSERIR ALUNO E PROFESSOR */
CREATE OR REPLACE FUNCTION INSERIR_ALUNO_E_PROFESSOR(COD_USUARIO INT, NOME TEXT, CPF TEXT, DATA_NASCIMENTO DATE, EMAIL TEXT, SENHA TEXT, SALDO FLOAT, TABELA TEXT)
RETURNS VOID
AS $$
BEGIN
    IF TABELA = 'ALUNO' THEN
        INSERT INTO ALUNO VALUES (COD_USUARIO, NOME, CPF, DATA_NASCIMENTO, EMAIL, SENHA, SALDO);
    END IF;

    IF TABELA = 'PROFESSOR' THEN
        INSERT INTO PROFESSOR VALUES (COD_USUARIO, NOME, CPF, DATA_NASCIMENTO, EMAIL, SENHA, SALDO);
    END IF;
END
$$ LANGUAGE plpgsql

/* RETORNA IDADE */
CREATE OR REPLACE FUNCTION RETORNA_IDADE(DATA_NASCIMENTO DATE)
RETURNS INT
AS $$
BEGIN
	RETURN EXTRACT(YEAR FROM AGE(DATA_NASCIMENTO));
END
$$ LANGUAGE plpgsql

/* USUARIO EXISTENTE NO BD DEPENDENDO DA TABELA */
CREATE OR REPLACE FUNCTION USUARIO_EXISTENTE(CPF_USUARIO TEXT, TABELA TEXT)
RETURNS TABLE (CPF VARCHAR(11))
AS $$
BEGIN
	IF TABELA = 'ALUNO' THEN
		RETURN QUERY SELECT A_L.CPF FROM ALUNO A_L WHERE A_L.CPF = CPF_USUARIO;
	END IF;
	
	IF TABELA = 'PROFESSOR' THEN
		RETURN QUERY SELECT P_F.CPF FROM PROFESSOR P_F WHERE P_F.CPF = CPF_USUARIO;
	END IF;
END
$$ LANGUAGE plpgsql

/* EMAIL EXISTENTE NO BD DEPENDENDO DA TABELA */
CREATE OR REPLACE FUNCTION EMAIL_USUARIO_EXISTENTE(EMAIL_USUARIO TEXT, TABELA TEXT)
RETURNS TABLE (EMAIL VARCHAR(30))
AS $$
BEGIN
	IF TABELA = 'ALUNO' THEN
		RETURN QUERY SELECT A_L.EMAIL FROM ALUNO A_L WHERE A_L.EMAIL = EMAIL_USUARIO;
	END IF;
	
	IF TABELA = 'PROFESSOR' THEN
		RETURN QUERY SELECT P_F.EMAIL FROM PROFESSOR P_F WHERE P_F.EMAIL = EMAIL_USUARIO;
	END IF;
END
$$ LANGUAGE plpgsql

/* FUNCTION REGRA DE NEGOCIO DA INSERÇÃO DA TABELA ALUNO */
CREATE OR REPLACE FUNCTION VERIFICA_INSERCAO()
RETURNS TRIGGER
AS $$
DECLARE
	IDADE INT := RETORNA_IDADE(NEW.DATA_NASCIMENTO);
	CPF_ALUNO_EXISTENTE TEXT := USUARIO_EXISTENTE(NEW.CPF, 'ALUNO');
	EMAIL_ALUNO_EXISTENTE TEXT := EMAIL_USUARIO_EXISTENTE(NEW.EMAIL, 'ALUNO');
	CPF_PROFESSOR_EXISTENTE TEXT := USUARIO_EXISTENTE(NEW.CPF, 'PROFESSOR');
	EMAIL_PROFESSOR_EXISTENTE TEXT := EMAIL_USUARIO_EXISTENTE(NEW.EMAIL, 'PROFESSOR');
BEGIN
	
	IF IDADE < 18 THEN
		RAISE EXCEPTION 'VOCÊ É MENOR DE IDADE CADASTRO REJEITADO!';
	END IF;
	
	IF NEW.CPF = CPF_ALUNO_EXISTENTE THEN
		RAISE EXCEPTION 'JÁ EXISTE UM ALUNO CADASTRADO COM ESSE CPF, INSIRA UM CPF VALIDO.';
	END IF;
	
	IF NEW.EMAIL = EMAIL_ALUNO_EXISTENTE THEN
		RAISE EXCEPTION 'ESSE EMAIL JÁ CONSTA EM UM CADASTRO ALUNO, INSIRA UM EMAIL VALIDO.';
	END IF;
	
	IF NEW.CPF = CPF_PROFESSOR_EXISTENTE THEN
		RAISE EXCEPTION 'JÁ EXISTE UM PROFESSOR CADASTRADO COM ESSE CPF, INSIRA UM CPF VALIDO.';
	END IF;
	
	IF NEW.EMAIL = EMAIL_PROFESSOR_EXISTENTE THEN
		RAISE EXCEPTION 'ESSE EMAIL JÁ CONSTA EM UM CADASTRO PROFESSOR, INSIRA UM EMAIL VALIDO.';
	END IF;
	
	RETURN NEW;

END
$$ LANGUAGE plpgsql

/* TREGGES INSERT ALUNO */
CREATE TRIGGER EVENTOS_DE_INSERCAO_ALUNO
BEFORE INSERT ON ALUNO
FOR EACH ROW 
EXECUTE PROCEDURE VERIFICA_INSERCAO();

/* TREGGES INSERT PROFESSOR */
CREATE TRIGGER EVENTOS_DE_INSERCAO_PROFESSOR
BEFORE INSERT ON PROFESSOR
FOR EACH ROW 
EXECUTE PROCEDURE VERIFICA_INSERCAO();

