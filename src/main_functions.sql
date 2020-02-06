---------------------------------------------------------------------------------------------------------------------------------------------------------------------
                      --        ####################################### FUNCTIONS PRINCIPAIS ########################################        --
                      -- ################################################################################################################### --
---------------------------------------------------------------------------------------------------------------------------------------------------------------------



--*****************************************************************************************************************************************************************--
----------------------------*******************************************  << SUPER USUÁRIO >>  *******************************************----------------------------
--*****************************************************************************************************************************************************************--


--|-------------------------------------------------------------------------------------------------|--
--|--- ############################### INSERIR_ALUNO_E_PROFESSOR ############################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| INSERE UM USUÁRIO NA SUA TABELA (EXISTEM AS POSSIBILIDADES DE INSERIR ALUNO E PROFESSOR).       |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [TEXT] NOME DO USUÁRIO; [TEXT] CPF DO USUÁRIO; [DATE] DATA DE NASCIMENTO DO USUÁRIO;   |--
--| [TEXT] EMAIL DO USUÁRIO; [TEXT] SENHA DO USUÁRIO; [TEXT] TABELA DO USUÁRIO.                     |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION INSERIR_ALUNO_E_PROFESSOR(NOME TEXT, CPF TEXT, DATA_NASCIMENTO DATE, EMAIL TEXT, SENHA TEXT, TABELA TEXT)
RETURNS VOID
AS $$
BEGIN
	IF TABELA = 'ALUNO' THEN
		INSERT INTO ALUNO VALUES (DEFAULT, NOME, CPF, DATA_NASCIMENTO, EMAIL, SENHA, DEFAULT);
		
	END IF;
 
	IF TABELA = 'PROFESSOR' THEN
		INSERT INTO PROFESSOR VALUES (DEFAULT, NOME, CPF, DATA_NASCIMENTO, EMAIL, SENHA, DEFAULT, DEFAULT);
		
	END IF;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ############################### REMOVER_ALUNO_E_PROFESSOR ############################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| REMOVE UM USUÁRIO DA SUA TABELA (EXISTEM AS POSSIBILIDADES DE REMOVER ALUNO E PROFESSOR).       |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO USUÁRIO DELETADO; [TEXT] NOME DA TABELA DO USUÁRIO DELETADO.           |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: CÓDIGO DE USUÁRIO INVÁLIDO.                                                  |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION REMOVER_ALUNO_E_PROFESSOR(COD_USUARIO_DELETADO INT, TABELA TEXT)
RETURNS VOID
AS $$
BEGIN
	IF TABELA = 'ALUNO' THEN
		IF VERIFICAR_SE_REGISTRO_EXISTE(COD_USUARIO_DELETADO, 'ALUNO') IS FALSE THEN
			RAISE EXCEPTION 'ESSE ALUNO NÃO EXISTE, INSIRA UM COD_ALUNO VÁLIDO!';

		END IF;
		
		DELETE FROM ALUNO WHERE COD_ALUNO = COD_USUARIO_DELETADO;
		
	END IF;
 
	IF TABELA = 'PROFESSOR' THEN
		IF VERIFICAR_SE_REGISTRO_EXISTE(COD_USUARIO_DELETADO, 'PROFESSOR') IS FALSE THEN
			RAISE EXCEPTION 'ESSE PROFESSOR NÃO EXISTE, INSIRA UM COD_PROFESSOR VÁLIDO!';

		END IF;

		DELETE FROM PROFESSOR WHERE COD_PROFESSOR = COD_USUARIO_DELETADO;
		
	END IF;
END
$$ LANGUAGE plpgsql;



--*****************************************************************************************************************************************************************--
----------------------------*****************************************  << ALUNO # PROFESSOR >>  *****************************************----------------------------
--*****************************************************************************************************************************************************************--


--|-------------------------------------------------------------------------------------------------|--
--|--- #################################### CONSULTAR_SALDO #################################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SELECIONA O SALDO DE UM USUÁRIO A PARTIR DO SEU CÓDIGO E TABELA.                                |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO USUÁRIO; [TEXT] NOME DA TABELA DO USUÁRIO.                             |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: CÓDIGO DE USUÁRIO INVÁLIDO.                                                  |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [TEXT] INFORMAÇÃO DO SALDO DO USUÁRIO.                                                   |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION CONSULTAR_SALDO(CODIGO INT, TABELA TEXT)
RETURNS TEXT
AS $$
DECLARE
	SALDO_CONSULTADO FLOAT;
BEGIN       
	IF TABELA = 'ALUNO' THEN
		IF VERIFICAR_SE_REGISTRO_EXISTE(CODIGO, 'ALUNO') IS FALSE THEN
			RAISE EXCEPTION 'ESSE ALUNO NÃO EXISTE, INSIRA UM COD_ALUNO VÁLIDO!';

		ELSE
			SELECT SALDO INTO SALDO_CONSULTADO FROM ALUNO WHERE CODIGO = COD_ALUNO;
			
		END IF;
		
	ELSIF TABELA = 'PROFESSOR' THEN
		IF VERIFICAR_SE_REGISTRO_EXISTE(CODIGO, 'PROFESSOR') IS FALSE THEN
			RAISE EXCEPTION 'ESSE PROFESSOR NÃO EXISTE, INSIRA UM COD_PROFESSOR VÁLIDO!';
			
		ELSE
			SELECT SALDO INTO SALDO_CONSULTADO FROM PROFESSOR WHERE CODIGO = COD_PROFESSOR;
			
		END IF;
		
	ELSE
		RAISE EXCEPTION 'APENAS AS TABELAS ALUNO E PROFESSOR SÃO ACEITAS NESSA FUNÇÃO!';
		
	END IF;
   
	IF SALDO_CONSULTADO = 0 THEN
		RETURN 'SEM SALDO!';
		
	ELSE
		RETURN 'SEU SALDO É DE R$ ' || CAST(SALDO_CONSULTADO AS TEXT) || '!';
		
	END IF;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- #################################### ATUALIZAR_SALDO #################################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ATUALIZA O SALDO DE UM USUÁRIO A PARTIR DO VALOR A SER ALTERADO, SEU CÓDIGO E TABELA.           |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [FLOAT] VALOR A SER ALTERADO NO SALDO DO USUÁRIO; [INT] CÓDIGO DO USUÁRIO; [TEXT] NOME |--
--| DA TABELA DO USUÁRIO.                                                                           |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: NOME DA TABELA INVÁLIDO; CÓDIGO DE USUÁRIO INVÁLIDO.                         |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION ATUALIZAR_SALDO(VALOR_SALDO_A_ALTERAR FLOAT, CODIGO INT, TABELA TEXT)
RETURNS VOID
AS $$
DECLARE
	SALDO_USUARIO INT;
BEGIN

	IF TABELA = 'ALUNO' THEN
		IF VERIFICAR_SE_REGISTRO_EXISTE(CODIGO, 'ALUNO') IS FALSE THEN
			RAISE EXCEPTION 'ESSE ALUNO NÃO EXISTE, INSIRA UM COD_ALUNO VÁLIDO!';
			
		ELSE
			SELECT SALDO INTO SALDO_USUARIO FROM ALUNO WHERE COD_ALUNO = CODIGO;

			UPDATE ALUNO SET SALDO = SALDO + VALOR_SALDO_A_ALTERAR WHERE COD_ALUNO = CODIGO;
			
		END IF;
		
	ELSIF TABELA = 'PROFESSOR' THEN
		IF VERIFICAR_SE_REGISTRO_EXISTE(CODIGO, 'PROFESSOR') IS FALSE THEN
			RAISE EXCEPTION 'ESSE PROFESSOR NÃO EXISTE, INSIRA UM COD_PROFESSOR VÁLIDO!';
			
		ELSE
			SELECT SALDO INTO SALDO_USUARIO FROM PROFESSOR WHERE COD_PROFESSOR = CODIGO;

			UPDATE PROFESSOR SET SALDO = SALDO + VALOR_SALDO_A_ALTERAR WHERE COD_PROFESSOR = CODIGO;
			
		END IF;
		
	ELSE
		RAISE EXCEPTION 'APENAS AS TABELAS ALUNO E PROFESSOR SÃO ACEITAS NESSA FUNÇÃO!';
		
	END IF;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ###################################### SACAR_SALDO ###################################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SACA TODO O SALDO DE UM USUÁRIO A PARTIR DO SEU CÓDIGO E TABELA.                                |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO USUÁRIO; [TEXT] NOME DA TABELA DO USUÁRIO.                             |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: NOME DA TABELA INVÁLIDO; CÓDIGO DE USUÁRIO INVÁLIDO.                         |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [TEXT] INFORMAÇÃO DO SALDO SACADO.                                                       |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION SACAR_SALDO(CODIGO INT, TABELA TEXT)
RETURNS TEXT
AS $$
DECLARE
	SALDO_SACADO FLOAT;
BEGIN
	IF TABELA = 'ALUNO' THEN
		IF VERIFICAR_SE_REGISTRO_EXISTE(CODIGO, 'ALUNO') IS FALSE THEN
			RAISE EXCEPTION 'ESSE ALUNO NÃO EXISTE, INSIRA UM COD_ALUNO VÁLIDO!';
			
		ELSE
			SELECT SALDO INTO SALDO_SACADO FROM ALUNO WHERE CODIGO = COD_ALUNO;
			
		END IF;
		
	ELSIF TABELA = 'PROFESSOR' THEN
		IF VERIFICAR_SE_REGISTRO_EXISTE(CODIGO, 'PROFESSOR') IS FALSE THEN
			RAISE EXCEPTION 'ESSE PROFESSOR NÃO EXISTE, INSIRA UM COD_PROFESSOR VÁLIDO!';
			
		ELSE
			SELECT SALDO INTO SALDO_SACADO FROM PROFESSOR WHERE CODIGO = COD_PROFESSOR;
			
		END IF;
		
	ELSE
		RAISE EXCEPTION 'APENAS AS TABELAS ALUNO E PROFESSOR SÃO ACEITAS NESSA FUNÇÃO!';
		
	END IF;
	   
	IF SALDO_SACADO != 0 THEN
		PERFORM ATUALIZAR_SALDO(-SALDO_SACADO, CODIGO, TABELA);
		RETURN 'FORAM SACADOS R$ ' || CAST(SALDO_SACADO AS TEXT) || '!';
		
	ELSE
		RETURN 'SEM SALDO!';
		
	END IF;
END
$$ LANGUAGE plpgsql;



--*****************************************************************************************************************************************************************--
----------------------------*********************************************  << PROFESSOR >>  *********************************************----------------------------
--*****************************************************************************************************************************************************************--


--|-------------------------------------------------------------------------------------------------|--
--|--- #################################### RECEBER_SALARIO #################################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| FAZ O PROFESSOR RECEBER O SALÁRIO ADQUIRIDO PELAS VENDAS DOS SEUS CURSO.                        |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO PROFESSOR QUE IRÁ RECEBER O SALÁRIO.                                   |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: CÓDIGO DE USUÁRIO INVÁLIDO.                                                  |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION RECEBER_SALARIO(COD_PROFESSOR_ANALISADO INT)
RETURNS VOID
AS $$
DECLARE
	DATA_ULTIMO_PAGAMENTO_ANALISADO DATE;
	DATA_PAGAMENTO_ATUAL DATE;
	SALARIO_A_PAGAR FLOAT;
BEGIN
	IF VERIFICAR_SE_REGISTRO_EXISTE(COD_PROFESSOR_ANALISADO, 'PROFESSOR') IS FALSE THEN
		RAISE EXCEPTION 'ESSE PROFESSOR NÃO EXISTE, INSIRA UM COD_PROFESSOR VÁLIDO!';
		
	ELSE
		SELECT DATA_ULTIMO_PAGAMENTO INTO DATA_ULTIMO_PAGAMENTO_ANALISADO FROM PROFESSOR WHERE COD_PROFESSOR = COD_PROFESSOR_ANALISADO;

		DATA_PAGAMENTO_ATUAL := CALCULAR_DATA_PAGAMENTO_ATUAL();
	
		SELECT COALESCE(SUM(PRECO), 0) INTO SALARIO_A_PAGAR FROM ALUNO_CURSO INNER JOIN CURSO ON ALUNO_CURSO.COD_CURSO = CURSO.COD_CURSO
		WHERE COD_PROFESSOR = COD_PROFESSOR_ANALISADO AND DATA_COMPRA < DATA_PAGAMENTO_ATUAL AND DATA_COMPRA >= DATA_ULTIMO_PAGAMENTO_ANALISADO;

		UPDATE PROFESSOR SET SALDO = SALDO + SALARIO_A_PAGAR, DATA_ULTIMO_PAGAMENTO = DATA_PAGAMENTO_ATUAL WHERE COD_PROFESSOR = COD_PROFESSOR_ANALISADO;
		
	END IF;
END
$$ LANGUAGE plpgsql;



--*****************************************************************************************************************************************************************--
----------------------------************************************  << ALUNO_CURSO # CURSO # ALUNO >>  ************************************----------------------------
--*****************************************************************************************************************************************************************--


--|-------------------------------------------------------------------------------------------------|--
--|--- ##################################### COMPRAR_CURSO ##################################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| REALIZA A COMPRA DO CURSO: INSERE OU ATUALIZA O ALUNO_CURSO, DEPENDENDO SE O ALUNO JÁ CURSOU O  |--
--| CURSO.                                                                                          |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO ALUNO; [INT] CÓDIGO DO CURSO.                                          |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION COMPRAR_CURSO(COD_ALUNO_ANALISADO INT, COD_CURSO_ANALISADO INT)
RETURNS VOID
AS $$
BEGIN
	IF ALUNO_JA_CURSOU(COD_ALUNO_ANALISADO, COD_CURSO_ANALISADO) = TRUE THEN
		UPDATE ALUNO_CURSO SET DATA_COMPRA = DATE(NOW()), NOTA_AVALIACAO = NULL WHERE COD_ALUNO = COD_ALUNO_ANALISADO AND COD_CURSO = COD_CURSO_ANALISADO;
		
        END IF;
        
	INSERT INTO ALUNO_CURSO VALUES (DEFAULT, DATE(NOW()), NULL, COD_ALUNO_ANALISADO, COD_CURSO_ANALISADO);
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ##################################### AVALIAR_CURSO ##################################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| PERMITE A AVALIAÇÃO DO CURSO POR PARTE DO ALUNO.                                                |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO ALUNO_CURSO; [FLOAT] NOTA DE AVALIAÇÃO PARA O CURSO.                   |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION AVALIAR_CURSO(COD_ALUNO_CURSO_ANALISADO INT, NOTA_AVALIACAO_ANALISADA FLOAT)
RETURNS VOID
AS $$
BEGIN
	UPDATE ALUNO_CURSO SET NOTA_AVALIACAO = NOTA_AVALIACAO_ANALISADA WHERE COD_ALUNO_CURSO = COD_ALUNO_CURSO_ANALISADO;
END
$$ LANGUAGE plpgsql;

--*****************************************************************************************************************************************************************--
----------------------------*****************************************  << CURSO # PROFESSOR >>  *****************************************----------------------------
--*****************************************************************************************************************************************************************--

--|-------------------------------------------------------------------------------------------------|--
--|--- ###################################### CRIAR_CURSO ###################################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CRIA UM CURSO UNIDO A UM PROFESSOR.                                                             |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO PROFESSOR; [TEXT] NOME DO CURSO; [TEXT] DESCRIÇÃO DO CURSO; [FLOAT]    |--
--| PREÇO DO CURSO.                                                                                 |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION CRIAR_CURSO(CODIGO_PROFESSOR INT, NOME_CURSO TEXT, DESCRICAO TEXT, PRECO FLOAT)
RETURNS VOID
AS $$
BEGIN
	INSERT INTO CURSO VALUES (DEFAULT, NOME_CURSO, DESCRICAO, DEFAULT, PRECO, DEFAULT, DEFAULT, DEFAULT, CODIGO_PROFESSOR);
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ##################################### DELETAR_CURSO ##################################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| REMOVE O CURSO.                                                                                 |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO CURSO.                                                                 |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: CÓDIGO DO CURSO INVÁLIDO.                                                    |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION DELETAR_CURSO(COD_CURSO_DELETADO INT)
RETURNS VOID
AS $$
BEGIN
	IF VERIFICAR_SE_REGISTRO_EXISTE(COD_CURSO_DELETADO, 'CURSO') IS FALSE THEN
		RAISE EXCEPTION 'ESSE CURSO NÃO EXISTE, INSIRA UM COD_CURSO VÁLIDO!';

	END IF;

	DELETE FROM CURSO WHERE COD_CURSO = COD_CURSO_DELETADO;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- #################################### PUBLICAR_CURSO ##################################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| PUBLICA O CURSO.                                                                                |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO CURSO.                                                                 |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION PUBLICAR_CURSO(CODIGO_CURSO INT)
RETURNS VOID
AS $$
BEGIN
	UPDATE CURSO SET PUBLICADO = TRUE WHERE COD_CURSO = CODIGO_CURSO;
END
$$ LANGUAGE plpgsql;



--*****************************************************************************************************************************************************************--
----------------------------*****************************************  << MODULO # PROFESSOR >>  ****************************************----------------------------
--*****************************************************************************************************************************************************************--


--|-------------------------------------------------------------------------------------------------|--
--|--- ##################################### CRIAR_MODULOS ##################################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CRIA MÓDULOS UNIDOS A UM PROFESSOR.                                                             |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO PROFESSOR; [TEXT[]] NOMES DOS MÓDULOS; [TEXT[]] DESCRIÇÕES DOS         |--
--| MÓDULOS.                                                                                        |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION CRIAR_MODULOS(CODIGO_PROFESSOR INT, NOMES_MODULOS TEXT[], DESCRICOES_MODULOS TEXT[])
RETURNS VOID
AS $$
DECLARE
	CONTADOR INT := 1;
BEGIN
	WHILE CONTADOR <= ARRAY_LENGTH(NOMES_MODULOS,1) LOOP
		INSERT INTO MODULO VALUES (DEFAULT, NOMES_MODULOS[CONTADOR], DESCRICOES_MODULOS[CONTADOR], CODIGO_PROFESSOR);
		CONTADOR := CONTADOR + 1;
		
	END LOOP;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- #################################### DELETAR_MODULO ##################################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| REMOVE O MÓDULO.                                                                                |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO MÓDULO.                                                                |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: CÓDIGO DO MÓDULO INVÁLIDO.                                                   |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION DELETAR_MODULO(CODIGO_MODULO INT)
RETURNS VOID
AS $$
BEGIN
	IF VERIFICAR_SE_REGISTRO_EXISTE(CODIGO_MODULO, 'MODULO') IS FALSE THEN
		RAISE EXCEPTION 'ESSE MODULO NÃO EXISTE, INSIRA UM COD_MODULO VÁLIDO!';
		
	ELSE
		DELETE FROM MODULO M_D WHERE M_D.COD_MODULO = CODIGO_MODULO;
		
	END IF;
END
$$ LANGUAGE plpgsql;


--*****************************************************************************************************************************************************************--
----------------------------*************************************  << PRE_REQUISITO # PROFESSOR >>  *************************************----------------------------
--*****************************************************************************************************************************************************************--


--|-------------------------------------------------------------------------------------------------|--
--|--- ################################## CRIAR_PRE_REQUISITO ################################## ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CRIA UM VÍNCULO ENTRE MÓDULOS NA TABELA PRÉ-REQUISITO.                                          |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO MÓDULO; [INT] CÓDIGO DO MÓDULO PRÉ-REQUISITO.                          |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

/* CRIAR PRE_REQUISITO */
CREATE OR REPLACE FUNCTION CRIAR_PRE_REQUISITO(CODIGO_MODULO INT, CODIGO_MODULO_PRE_REQUISITO INT)
RETURNS VOID
AS $$
BEGIN
	INSERT INTO PRE_REQUISITO VALUES (DEFAULT, CODIGO_MODULO, CODIGO_MODULO_PRE_REQUISITO);
END
$$ LANGUAGE plpgsql;



--*****************************************************************************************************************************************************************--
----------------------------***************************************  << DISCIPLINA # PROFESSOR >>  **************************************----------------------------
--*****************************************************************************************************************************************************************--


--|-------------------------------------------------------------------------------------------------|--
--|--- ################################### CRIAR_DISCIPLINAS ################################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CRIA DISCIPLINAS UNIDAS A UM MÓDULO.                                                            |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO MÓDULO; [TEXT[]] NOMES DAS DISCIPLINAS; [TEXT[]] DESCRIÇÕES DAS        |--
--| DISCIPLINAS.                                                                                    |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION CRIAR_DISCIPLINAS(CODIGO_MODULO INT, NOME_DISCIPLINA TEXT[], DESCRICAO_DISCIPLINA TEXT[])
RETURNS VOID
AS $$
DECLARE
	CONTADOR INT := 1;
BEGIN
	WHILE CONTADOR <= ARRAY_LENGTH(NOME_DISCIPLINA,1) LOOP
		INSERT INTO DISCIPLINA VALUES (DEFAULT, NOME_DISCIPLINA[CONTADOR], DESCRICAO_DISCIPLINA[CONTADOR], CODIGO_MODULO);
		CONTADOR := CONTADOR + 1;

	END LOOP;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ################################## DELETAR_DISCIPLINA ################################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| REMOVE A DISCIPLINA.                                                                            |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DA DISCIPLINA.                                                            |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: CÓDIGO DA DISCIPLINA INVÁLIDO.                                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION DELETAR_DISCIPLINA(CODIGO_DISCIPLINA INT)
RETURNS VOID
AS $$
BEGIN
	IF VERIFICAR_SE_REGISTRO_EXISTE(CODIGO_DISCIPLINA, 'DISCIPLINA') IS FALSE THEN
		RAISE EXCEPTION 'ESSA DISCIPLINA NÃO EXISTE, INSIRA UM COD_DISCIPLINA VÁLIDO!';

	ELSE
		DELETE FROM DISCIPLINA D_C WHERE D_C.COD_DISCIPLINA = CODIGO_DISCIPLINA;

	END IF;
END
$$ LANGUAGE plpgsql;



--*****************************************************************************************************************************************************************--
----------------------------***************************************  << VIDEO_AULA # PROFESSOR >>  **************************************----------------------------
--*****************************************************************************************************************************************************************--


--|-------------------------------------------------------------------------------------------------|--
--|--- ################################### CRIAR_VIDEO_AULAS ################################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CRIA VIDEOAULAS UNIDAS A DISCIPLINAS.                                                           |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DA DISCIPLINA; [TEXT[]] TÍTULOS DAS VIDEOAULAS; [TEXT[]] DESCRIÇÕES DAS   |--
--| VIDEOAULAS; [INT[]] DURAÇÕES DAS VIDEOAULAS.                                                    |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION CRIAR_VIDEO_AULAS(CODIGO_DISCIPLINA INT, TITULO_VIDEO TEXT[], DESCRICAO TEXT[], DURACAO INT[])
RETURNS VOID
AS $$
DECLARE
	CONTADOR INT := 1;
BEGIN
	WHILE CONTADOR <= ARRAY_LENGTH(TITULO_VIDEO,1) LOOP -- NO ARRAY LENGHT, ESSE "1" SIGNIFICA A QUANTIDADE DE COLUNAS DA ARRAY.
		INSERT INTO VIDEO_AULA VALUES (DEFAULT, TITULO_VIDEO[CONTADOR], DESCRICAO[CONTADOR], DURACAO[CONTADOR], CODIGO_DISCIPLINA);
		CONTADOR := CONTADOR + 1;
			
	END LOOP;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ################################## DELETAR_VIDEO_AULA ################################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| REMOVE A VIDEOAULA.                                                                             |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DA VIDEOAULA.                                                             |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: CÓDIGO DA VIDEOAULA INVÁLIDO.                                                |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION DELETAR_VIDEO_AULA(CODIGO_VIDEO_AULA INT)
RETURNS VOID
AS $$
BEGIN
	IF VERIFICAR_SE_REGISTRO_EXISTE(CODIGO_VIDEO_AULA, 'VIDEO_AULA') IS FALSE THEN
		RAISE EXCEPTION 'ESSE VIDEO NÃO EXISTE, INSIRA UM COD_VIDEO_AULA VÁLIDO!';

	ELSE
		DELETE FROM VIDEO_AULA V_A WHERE V_A.COD_VIDEO_AULA = CODIGO_VIDEO_AULA;

	END IF;
END
$$ LANGUAGE plpgsql;



--*****************************************************************************************************************************************************************--
----------------------------***************************************  << ALUNO_VIDEO_ASSISTIDO >>  ***************************************----------------------------
--*****************************************************************************************************************************************************************--


--|-------------------------------------------------------------------------------------------------|--
--|--- ################################## ASSISTIR_VIDEO_AULA ################################## ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| FAZ O ALUNO ASSISTIR À VIDEOAULA (FAZ UM VÍNCULO ALUNO_VIDEO_ASSISTIDO)                         |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO ALUNO; [INT] CÓDIGO DA VIDEOAULA.                                      |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION ASSISTIR_VIDEO_AULA(CODIGO_ALUNO INT, CODIGO_VIDEO_AULA INT)
RETURNS VOID
AS $$
BEGIN
	IF ALUNO_JA_ASSISTIU(CODIGO_ALUNO, CODIGO_VIDEO_AULA) IS FALSE THEN
		INSERT INTO ALUNO_VIDEO_ASSISTIDO VALUES (DEFAULT, CODIGO_ALUNO, CODIGO_VIDEO_AULA);

	END IF;
END
$$ LANGUAGE plpgsql;



--*****************************************************************************************************************************************************************--
----------------------------****************************************  << QUESTAO # PROFESSOR >>  ****************************************----------------------------
--*****************************************************************************************************************************************************************--


--|-------------------------------------------------------------------------------------------------|--
--|--- ##################################### CRIAR_QUESTAO ##################################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CRIA UMA QUESTÃO UNIDA A UMA DISCIPLINA.                                                        |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DA DISCIPLINA; [TEXT] TEXTO DA QUESTÃO.                                   |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION CRIAR_QUESTAO(CODIGO_DISCIPLINA INT, TEXTO_INSERIDO TEXT)
RETURNS VOID
AS $$
BEGIN
	INSERT INTO QUESTAO VALUES (DEFAULT, TEXTO_INSERIDO, CODIGO_DISCIPLINA);
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- #################################### DELETAR_QUESTAO #################################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| REMOVE A QUESTÃO.                                                                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DA QUESTÃO.                                                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: CÓDIGO DA QUESTÃO INVÁLIDO.                                                  |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION DELETAR_QUESTAO(CODIGO_QUESTAO INT)
RETURNS VOID
AS $$
BEGIN
	IF VERIFICAR_SE_REGISTRO_EXISTE(CODIGO_QUESTAO, 'QUESTAO') IS FALSE THEN
		RAISE EXCEPTION 'ESSA QUESTAO NÃO EXISTE, INSIRA UM COD_QUESTAO VÁLIDO!';

	ELSE
		DELETE FROM QUESTAO WHERE COD_QUESTAO = CODIGO_QUESTAO;

	END IF;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ############################## LISTAR_QUESTOES_DOS_ALUNOS ############################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| LISTA AS QUESTÕES RESPONDIDAS POR ALUNOS EM CURSOS DO PROFESSOR.                                |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DA QUESTÃO.                                                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [TABLE(COD_QUESTAO_ALUNO INT, RESPOSTA_CORRETA VARCHAR(13), TEXTO VARCHAR(500),          |--
--| RESPOSTA_ALUNO VARCHAR(500))] TABELA COM INFORMAÇÕES ÚTEIS EM UMA LISTAGEM.                     |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION LISTAR_QUESTOES_DOS_ALUNOS(CODIGO_PROFESSOR INT)
RETURNS TABLE(COD_QUESTAO_ALUNO INT, RESPOSTA_CORRETA VARCHAR(13), TEXTO VARCHAR(500), RESPOSTA_ALUNO VARCHAR(500))
AS $$
BEGIN
	RETURN QUERY SELECT Q_A.COD_QUESTAO_ALUNO, Q_A.RESPOSTA_CORRETA, Q.TEXTO, Q_A.RESPOSTA_ALUNO FROM QUESTAO_ALUNO Q_A
	       INNER JOIN QUESTAO Q ON Q_A.COD_QUESTAO = Q.COD_QUESTAO INNER JOIN DISCIPLINA D_C ON Q.COD_DISCIPLINA = D_C.COD_DISCIPLINA
	       INNER JOIN MODULO M_D ON D_C.COD_MODULO = M_D.COD_MODULO INNER JOIN CURSO C_R ON M_D.COD_CURSO = C_R.COD_CURSO
	       WHERE C_R.COD_PROFESSOR = CODIGO_PROFESSOR
	       ORDER BY C_R.COD_CURSO, M_D.COD_MODULO, D_C.COD_DISCIPLINA, Q_A.COD_QUESTAO_ALUNO;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- #################################### CORRIGIR_QUESTAO #################################### --|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CORRIGE UMA QUESTAO_ALUNO COM UM TEXTO QUE REPRESENTA SE A RESPOSTA ESTÁ CORRETA.               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO VÍNCULO QUESTAO_ALUNO CORRIGIDO; [TEXT] RESPOSTA CORRETA INSERIDA.     |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION CORRIGIR_QUESTAO(COD_QUESTAO_ALUNO_CORRIGIDA INT, RESPOSTA_CORRETA_INSERIDA TEXT)
RETURNS VOID
AS $$
BEGIN
	UPDATE QUESTAO_ALUNO SET RESPOSTA_CORRETA = RESPOSTA_CORRETA_INSERIDA WHERE COD_QUESTAO_ALUNO = COD_QUESTAO_ALUNO_CORRIGIDA;
END
$$ LANGUAGE plpgsql;



--*****************************************************************************************************************************************************************--
----------------------------*************************************  << QUESTIONARIO # PROFESSOR >>  **************************************----------------------------
--*****************************************************************************************************************************************************************--


--|-------------------------------------------------------------------------------------------------|--
--|--- ################################## CRIAR_QUESTIONARIO ################################### ---|------------------====------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CRIA UM QUESTIONÁRIO UNIDO A UMA DISCIPLINA.                                                    |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] NOME DO QUESTIONÁRIO; [INT] CÓDIGO DA DISCIPLINA.                                |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION CRIAR_QUESTIONARIO(NOME_INSERIDO TEXT, COD_DISCIPLINA_INSERIDA INT)
RETURNS VOID
AS $$
BEGIN
	INSERT INTO QUESTIONARIO VALUES (DEFAULT, NOME_INSERIDO, COD_DISCIPLINA_INSERIDA);
END
$$ LANGUAGE plpgsql;
 
--|-------------------------------------------------------------------------------------------------|--
--|--- ################################# DELETAR_QUESTIONARIO ################################## ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| REMOVE UM QUESTIONÁRIO.                                                                         |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO QUESTIONÁRIO.                                                          |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: CÓDIGO DO QUESTIONÁRIO INVÁLIDO.                                             |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION DELETAR_QUESTIONARIO(COD_QUESTIONARIO_DELETADO INT)
RETURNS VOID
AS $$
BEGIN
	IF VERIFICAR_SE_REGISTRO_EXISTE(COD_QUESTIONARIO_DELETADO, 'QUESTIONARIO') IS FALSE THEN
		RAISE EXCEPTION 'ESSE QUESTIONARIO NÃO EXISTE, INSIRA UM COD_QUESTIONARIO VÁLIDO!';

	ELSE
		DELETE FROM QUESTIONARIO WHERE COD_QUESTIONARIO = COD_QUESTIONARIO_DELETADO;

	END IF;
END
$$ LANGUAGE plpgsql;



--*****************************************************************************************************************************************************************--
----------------------------*********************************  << QUESTAO_QUESTIONARIO # PROFESSOR >>  **********************************----------------------------
--*****************************************************************************************************************************************************************--


--|-------------------------------------------------------------------------------------------------|--
--|--- ############################ VINCULAR_QUESTAO_A_QUESTIONARIO ############################ ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CRIA UM VÍNCULO ENTRE A QUESTÃO E O QUESTIONÁRIO NA TABELA QUESTAO_QUESTIONARIO.                |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO QUESTIONÁRIO VÍNCULADO; [INT] CÓDIGO DA QUESTÃO VINCULADA.             |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION VINCULAR_QUESTAO_A_QUESTIONARIO(COD_QUESTIONARIO_VINCULADO INT, COD_QUESTAO_VINCULADA INT)
RETURNS VOID
AS $$
BEGIN
	INSERT INTO QUESTAO_QUESTIONARIO VALUES (DEFAULT, COD_QUESTAO_VINCULADA, COD_QUESTIONARIO_VINCULADO);
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ############################# SUBMETER_RESPOSTA_DE_QUESTAO ############################## ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| FAZ O ALUNO SUBMETER UMA RESPOSTA PARA UMA QUESTÃO POR MEIO DO ALUNO_QUESTAO.                   |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO ALUNO; [INT] CÓDIGO DA QUESTÃO; [TEXT] RESPOSTA PARA A QUESTÃO.        |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION SUBMETER_RESPOSTA_DE_QUESTAO(COD_ALUNO_ANALISADO INT, COD_QUESTAO_SUBMETIDA INT, RESPOSTA_ALUNO_SUBMETIDA TEXT)
RETURNS VOID
AS $$
DECLARE
	COD_QUESTAO_ALUNO_ANALISADO INT := (SELECT COD_QUESTAO_ALUNO FROM QUESTAO_ALUNO
	                                    WHERE COD_QUESTAO = COD_QUESTAO_SUBMETIDA AND COD_ALUNO = COD_ALUNO_ANALISADO);
BEGIN
	IF COD_QUESTAO_ALUNO_ANALISADO IS NOT NULL THEN
		UPDATE QUESTAO_ALUNO SET RESPOSTA_ALUNO = RESPOSTA_ALUNO_SUBMETIDA, RESPOSTA_CORRETA = DEFAULT
		WHERE COD_QUESTAO_ALUNO = COD_QUESTAO_SUBMETIDA;

	ELSE
		INSERT INTO QUESTAO_ALUNO VALUES(DEFAULT, RESPOSTA_ALUNO_SUBMETIDA, DEFAULT, COD_QUESTAO_SUBMETIDA, COD_ALUNO_ANALISADO);

	END IF;
END
$$ LANGUAGE plpgsql;
