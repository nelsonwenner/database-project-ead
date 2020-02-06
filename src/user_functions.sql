---------------------------------------------------------------------------------------------------------------------------------------------------------------------
                      --        ####################################### FUNCTIONS DE USUÁRIOS #######################################        --
                      -- ################################################################################################################### --
---------------------------------------------------------------------------------------------------------------------------------------------------------------------


--*****************************************************************************************************************************************************************--
----------------------------*****************************************  << ALUNO # PROFESSOR >>  *****************************************----------------------------
--*****************************************************************************************************************************************************************--


--|-------------------------------------------------------------------------------------------------|--
--|--- ################################ USUARIO_CONSULTAR_SALDO ################################ ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SELECIONA O SALDO DE UM USUÁRIO.                                                                |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [TEXT] INFORMAÇÃO DO SALDO DO USUÁRIO.                                                   |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION USUARIO_CONSULTAR_SALDO()
RETURNS TEXT
AS $$
DECLARE
	TABELA_USUARIO VARCHAR(13);
	CODIGO_USUARIO INT;
BEGIN
	PERFORM VERIFICAR_PERMISSAO_DA_TABELA_DO_USUARIO('ALUNO_OU_PROFESSOR');
	
	TABELA_USUARIO := RETORNAR_TABELA_DO_USUARIO();
	CODIGO_USUARIO := RETORNAR_CODIGO_DO_USUARIO();
	
	RETURN CONSULTAR_SALDO(CODIGO_USUARIO, TABELA_USUARIO);
END
$$ LANGUAGE plpgsql;


--|-------------------------------------------------------------------------------------------------|--
--|--- ################################ USUARIO_ATUALIZAR_SALDO ################################ ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ATUALIZA O SALDO DE UM USUÁRIO A PARTIR DO VALOR A SER ALTERADO                                 |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [FLOAT] VALOR A SER ALTERADO NO SALDO DO USUÁRIO.                                      |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION USUARIO_ATUALIZAR_SALDO(VALOR_SALDO_A_ALTERAR FLOAT)
RETURNS VOID
AS $$
DECLARE
	TABELA_USUARIO VARCHAR(13);
	CODIGO_USUARIO INT;
BEGIN
	PERFORM VERIFICAR_PERMISSAO_DA_TABELA_DO_USUARIO('ALUNO_OU_PROFESSOR');
	
	TABELA_USUARIO := RETORNAR_TABELA_DO_USUARIO();
	CODIGO_USUARIO := RETORNAR_CODIGO_DO_USUARIO();
	
	PERFORM ATUALIZAR_SALDO(VALOR_SALDO_A_ALTERAR, CODIGO_USUARIO, TABELA_USUARIO);
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ################################## USUARIO_SACAR_SALDO ################################## ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SACA TODO O SALDO DE UM USUÁRIO A PARTIR DO SEU CÓDIGO E TABELA.                                |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO USUÁRIO.                                                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [TEXT] INFORMAÇÃO DO SALDO SACADO.                                                       |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION USUARIO_SACAR_SALDO(CODIGO INT)
RETURNS TEXT
AS $$
DECLARE
	TABELA_USUARIO VARCHAR(13);
	CODIGO_USUARIO INT;
BEGIN
	PERFORM VERIFICAR_PERMISSAO_DA_TABELA_DO_USUARIO('ALUNO_OU_PROFESSOR');
	
	TABELA_USUARIO := RETORNAR_TABELA_DO_USUARIO();
	CODIGO_USUARIO := RETORNAR_CODIGO_DO_USUARIO();
	
	RETURN SACAR_SALDO(CODIGO_USUARIO, TABELA_USUARIO);
END
$$ LANGUAGE plpgsql;



--*****************************************************************************************************************************************************************--
----------------------------*********************************************  << PROFESSOR >>  *********************************************----------------------------
--*****************************************************************************************************************************************************************--


--|-------------------------------------------------------------------------------------------------|--
--|--- ############################### PROFESSOR_RECEBER_SALARIO ############################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| FAZ O PROFESSOR RECEBER O SALÁRIO ADQUIRIDO PELAS VENDAS DOS SEUS CURSO.                        |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION PROFESSOR_RECEBER_SALARIO()
RETURNS VOID
AS $$
DECLARE
	CODIGO_USUARIO INT;
BEGIN
	PERFORM VERIFICAR_PERMISSAO_DA_TABELA_DO_USUARIO('PROFESSOR');

	CODIGO_USUARIO := RETORNAR_CODIGO_DO_USUARIO();
	
	PERFORM RECEBER_SALARIO(CODIGO_USUARIO);
END
$$ LANGUAGE plpgsql;



--*****************************************************************************************************************************************************************--
----------------------------************************************  << ALUNO_CURSO # CURSO # ALUNO >>  ************************************----------------------------
--*****************************************************************************************************************************************************************--


--|-------------------------------------------------------------------------------------------------|--
--|--- ################################## ALUNO_COMPRAR_CURSO ################################## ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| REALIZA A COMPRA DO CURSO: INSERE OU ATUALIZA O ALUNO_CURSO, DEPENDENDO SE O ALUNO JÁ CURSOU O  |--
--| CURSO.                                                                                          |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO ALUNO; [INT] CÓDIGO DO CURSO.                                          |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION ALUNO_COMPRAR_CURSO(COD_CURSO_ANALISADO INT)
RETURNS VOID
AS $$
DECLARE
	CODIGO_USUARIO INT;
BEGIN
	PERFORM VERIFICAR_PERMISSAO_DA_TABELA_DO_USUARIO('ALUNO');
	
	CODIGO_USUARIO := RETORNAR_CODIGO_DO_USUARIO();

	PERFORM COMPRAR_CURSO(CODIGO_USUARIO, COD_CURSO_ANALISADO);
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ################################## ALUNO_AVALIAR_CURSO ################################## ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| PERMITE A AVALIAÇÃO DO CURSO POR PARTE DO ALUNO.                                                |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO ALUNO_CURSO; [FLOAT] NOTA DE AVALIAÇÃO PARA O CURSO.                   |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION ALUNO_AVALIAR_CURSO(COD_ALUNO_CURSO_ANALISADO INT, NOTA_AVALIACAO_ANALISADA FLOAT)
RETURNS VOID
AS $$
BEGIN
	PERFORM VERIFICAR_PERMISSAO_DA_TABELA_DO_USUARIO('ALUNO');
	
	PERFORM AVALIAR_CURSO(COD_ALUNO_CURSO_ANALISADO, NOTA_AVALIACAO_ANALISADA);
END
$$ LANGUAGE plpgsql;



--*****************************************************************************************************************************************************************--
----------------------------*****************************************  << CURSO # PROFESSOR >>  *****************************************----------------------------
--*****************************************************************************************************************************************************************--


--|-------------------------------------------------------------------------------------------------|--
--|--- ################################# PROFESSOR_CRIAR_CURSO ################################# ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CRIA UM CURSO UNIDO A UM PROFESSOR.                                                             |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [TEXT] NOME DO CURSO; [TEXT] DESCRIÇÃO DO CURSO; [FLOAT] PREÇO DO CURSO.               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION PROFESSOR_CRIAR_CURSO(NOME_CURSO TEXT, DESCRICAO TEXT, PRECO FLOAT)
RETURNS VOID
AS $$
DECLARE
	CODIGO_USUARIO INT;
BEGIN
	PERFORM VERIFICAR_PERMISSAO_DA_TABELA_DO_USUARIO('PROFESSOR');
	
	CODIGO_USUARIO := RETORNAR_CODIGO_DO_USUARIO();

	PERFORM CRIAR_CURSO(CODIGO_USUARIO, NOME_CURSO, DESCRICAO, PRECO);
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ################################ PROFESSOR_DELETAR_CURSO ################################ ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| REMOVE O CURSO.                                                                                 |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO CURSO.                                                                 |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: PROFESSOR NÃO TEM PERMISSÃO SOBRE O CURSO.                                   |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION PROFESSOR_DELETAR_CURSO(COD_CURSO_DELETADO INT)
RETURNS VOID
AS $$
BEGIN
	PERFORM VERIFICAR_PERMISSAO_DA_TABELA_DO_USUARIO('PROFESSOR');
	
	IF VERIFICAR_PERMISSAO_DO_USUARIO(COD_CURSO_DELETADO, 'CURSO') = FALSE THEN
		RAISE EXCEPTION 'NÃO É PERMITIDO QUE UM PROFESSOR DELETE O CURSO DE OUTRO!';

	END IF;

	PERFORM DELETAR_CURSO(COD_CURSO_DELETADO);
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ############################### PROFESSOR_PUBLICAR_CURSO ################################ ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| PUBLICA O CURSO.                                                                                |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO CURSO.                                                                 |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: PROFESSOR NÃO TEM PERMISSÃO SOBRE O CURSO.                                   |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION PROFESSOR_PUBLICAR_CURSO(CODIGO_CURSO INT)
RETURNS VOID
AS $$
BEGIN
	PERFORM VERIFICAR_PERMISSAO_DA_TABELA_DO_USUARIO('PROFESSOR');
	
	IF VERIFICAR_PERMISSAO_DO_USUARIO(CODIGO_CURSO, 'CURSO') = FALSE THEN
		RAISE EXCEPTION 'NÃO É PERMITIDO QUE UM PROFESSOR PUBLIQUE O CURSO DE OUTRO!';
		
	END IF;

	PERFORM PUBLICAR_CURSO(CODIGO_CURSO);
END
$$ LANGUAGE plpgsql;

--*****************************************************************************************************************************************************************--
----------------------------*****************************************  << MODULO # PROFESSOR >>  ****************************************----------------------------
--*****************************************************************************************************************************************************************--


--|-------------------------------------------------------------------------------------------------|--
--|--- ################################ PROFESSOR_CRIAR_MODULOS ################################ ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CRIA MÓDULOS UNIDOS A UM PROFESSOR.                                                             |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [TEXT[]] NOMES DOS MÓDULOS; [TEXT[]] DESCRIÇÕES DOS MÓDULOS.                           |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: PROFESSOR NÃO TEM PERMISSÃO SOBRE O CURSO.                                   |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION PROFESSOR_CRIAR_MODULOS(CODIGO_CURSO INT, NOME_MODULO TEXT[], DESCRICAO_MODULO TEXT[])
RETURNS VOID
AS $$
BEGIN
	PERFORM VERIFICAR_PERMISSAO_DA_TABELA_DO_USUARIO('PROFESSOR');

	IF VERIFICAR_PERMISSAO_DO_USUARIO(CODIGO_CURSO, 'CURSO') = FALSE THEN
		RAISE EXCEPTION 'NÃO É PERMITIDO QUE UM PROFESSOR CRIE MÓDULOS NO CURSO DE OUTRO!';
		
	END IF;

	PERFORM CRIAR_MODULOS(CODIGO_CURSO, NOME_MODULO, DESCRICAO_MODULO);
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ############################### PROFESSOR_DELETAR_MODULO ################################ ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| REMOVE O MÓDULO.                                                                                |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO MÓDULO.                                                                |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: PROFESSOR NÃO TEM PERMISSÃO SOBRE O MÓDULO.                                  |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION PROFESSOR_DELETAR_MODULO(CODIGO_MODULO INT)
RETURNS VOID
AS $$
BEGIN
	PERFORM VERIFICAR_PERMISSAO_DA_TABELA_DO_USUARIO('PROFESSOR');
	
	IF VERIFICAR_PERMISSAO_DO_USUARIO(CODIGO_MODULO, 'MODULO') = FALSE THEN
		RAISE EXCEPTION 'NÃO É PERMITIDO QUE UM PROFESSOR REMOVA UM MÓDULO NO CURSO DE OUTRO!';
		
	END IF;

	PERFORM DELETAR_MODULO(CODIGO_MODULO);
END
$$ LANGUAGE plpgsql;


--*****************************************************************************************************************************************************************--
----------------------------*************************************  << PRE_REQUISITO # PROFESSOR >>  *************************************----------------------------
--*****************************************************************************************************************************************************************--

--|-------------------------------------------------------------------------------------------------|--
--|--- ############################# PROFESSOR_CRIAR_PRE_REQUISITO ############################# ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CRIA UM VÍNCULO ENTRE MÓDULOS NA TABELA PRÉ-REQUISITO.                                          |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO MÓDULO; [INT] CÓDIGO DO MÓDULO PRÉ-REQUISITO.                          |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: PROFESSOR NÃO TEM PERMISSÃO SOBRE ALGUM DOS MÓDULO.                          |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION PROFESSOR_CRIAR_PRE_REQUISITO(COD_MODULO INT, COD_MODULO_PRE_REQUISITO INT)
RETURNS VOID
AS $$
BEGIN
	PERFORM VERIFICAR_PERMISSAO_DA_TABELA_DO_USUARIO('PROFESSOR');

	IF VERIFICAR_PERMISSAO_DO_USUARIO(CODIGO_MODULO, 'MODULO') = FALSE THEN
		RAISE EXCEPTION 'NÃO É PERMITIDO QUE UM PROFESSOR USE UM MÓDULO DO CURSO DE OUTRO NO COD_MODULO!';

	ELSIF VERIFICAR_PERMISSAO_DO_USUARIO(CODIGO_MODULO_PRE_REQUISITO, 'MODULO') = FALSE THEN
		RAISE EXCEPTION 'NÃO É PERMITIDO QUE UM PROFESSOR USE UM MÓDULO DO CURSO DE OUTRO NO COD_MODULO_PRE_REQUISITO!';

	END IF;
	
	PERFORM CRIAR_PRE_REQUISITO(COD_MODULO, COD_MODULO_PRE_REQUISITO);
END
$$ LANGUAGE plpgsql;



--*****************************************************************************************************************************************************************--
----------------------------***************************************  << DISCIPLINA # PROFESSOR >>  **************************************----------------------------
--*****************************************************************************************************************************************************************--


--|-------------------------------------------------------------------------------------------------|--
--|--- ############################## PROFESSOR_CRIAR_DISCIPLINAS ############################## ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CRIA DISCIPLINAS UNIDAS A UM MÓDULO.                                                            |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO MÓDULO; [TEXT[]] NOMES DAS DISCIPLINAS; [TEXT[]] DESCRIÇÕES DAS        |--
--| DISCIPLINAS.                                                                                    |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: PROFESSOR NÃO TEM PERMISSÃO SOBRE O MÓDULO.                                  |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION PROFESSOR_CRIAR_DISCIPLINAS(CODIGO_MODULO INT, NOME_DISCIPLINA TEXT[], DESCRICAO_DISCIPLINA TEXT[])
RETURNS VOID
AS $$
BEGIN
	PERFORM VERIFICAR_PERMISSAO_DA_TABELA_DO_USUARIO('PROFESSOR');

	IF VERIFICAR_PERMISSAO_DO_USUARIO(CODIGO_MODULO, 'MODULO') = FALSE THEN
		RAISE EXCEPTION 'NÃO É PERMITIDO QUE UM PROFESSOR CRIE DISCIPLINAS EM UM MÓDULO DO CURSO DE OUTRO!';
		
	END IF;

	PERFORM CRIAR_DISCIPLINAS(CODIGO_MODULO, NOME_DISCIPLINA, DESCRICAO_DISCIPLINA);
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ############################# PROFESSOR_DELETAR_DISCIPLINA ############################## ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| REMOVE A DISCIPLINA.                                                                            |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DA DISCIPLINA.                                                            |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: PROFESSOR NÃO TEM PERMISSÃO SOBRE A DICIPLINA.                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION PROFESSOR_DELETAR_DISCIPLINA(CODIGO_DISCIPLINA INT)
RETURNS VOID
AS $$
BEGIN
	PERFORM VERIFICAR_PERMISSAO_DA_TABELA_DO_USUARIO('PROFESSOR');

	IF VERIFICAR_PERMISSAO_DO_USUARIO(CODIGO_DISCIPLINA, 'DISCIPLINA') = FALSE THEN
		RAISE EXCEPTION 'NÃO É PERMITIDO QUE UM PROFESSOR REMOVA UMA DISCIPLINA EM UM MÓDULO DO CURSO DE OUTRO!';
		
	END IF;

	PERFORM DELETAR_DISCIPLINA(CODIGO_DISCIPLINA);
END
$$ LANGUAGE plpgsql;



--*****************************************************************************************************************************************************************--
----------------------------***************************************  << VIDEO_AULA # PROFESSOR >>  **************************************----------------------------
--*****************************************************************************************************************************************************************--


--|-------------------------------------------------------------------------------------------------|--
--|--- ############################## PROFESSOR_CRIAR_VIDEO_AULAS ############################## ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CRIA VIDEOAULAS UNIDAS A DISCIPLINAS.                                                           |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DA DISCIPLINA; [TEXT[]] TÍTULOS DAS VIDEOAULAS; [TEXT[]] DESCRIÇÕES DAS   |--
--| VIDEOAULAS; INT[] DURAÇÕES DAS VIDEOAULAS.                                                      |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: PROFESSOR NÃO TEM PERMISSÃO SOBRE A DICIPLINA.                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION PROFESSOR_CRIAR_VIDEO_AULAS(CODIGO_DISCIPLINA INT, TITULO_VIDEO TEXT[], DESCRICAO TEXT[], DURACAO INT[])
RETURNS VOID
AS $$
BEGIN
	PERFORM VERIFICAR_PERMISSAO_DA_TABELA_DO_USUARIO('PROFESSOR');

	IF VERIFICAR_PERMISSAO_DO_USUARIO(CODIGO_DISCIPLINA, 'DISCIPLINA') = FALSE THEN
		RAISE EXCEPTION 'NÃO É PERMITIDO QUE UM PROFESSOR CRIE VIDEO_AULAS EM UMA DISCIPLINA EM UM MÓDULO DO CURSO DE OUTRO!';
		
	END IF;

	PERFORM CRIAR_VIDEO_AULAS(CODIGO_DISCIPLINA, TITULO_VIDEO, DESCRICAO, DURACAO);
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ############################# PROFESSOR_DELETAR_VIDEO_AULA ############################## ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| REMOVE A VIDEOAULA.                                                                             |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DA VIDEOAULA.                                                             |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: PROFESSOR NÃO TEM PERMISSÃO SOBRE A DICIPLINA.                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION PROFESSOR_DELETAR_VIDEO_AULA(CODIGO_VIDEO_AULA INT)
RETURNS VOID
AS $$
BEGIN
	PERFORM VERIFICAR_PERMISSAO_DA_TABELA_DO_USUARIO('PROFESSOR');

	IF VERIFICAR_PERMISSAO_DO_USUARIO(CODIGO_VIDEO_AULA, 'VIDEO_AULA') = FALSE THEN
		RAISE EXCEPTION 'NÃO É PERMITIDO QUE UM PROFESSOR REMOVA UMA VIDEO_AULA EM UMA DISCIPLINA EM UM MÓDULO DO CURSO DE OUTRO!';

	END IF;

	PERFORM DELETAR_VIDEO_AULA(CODIGO_VIDEO_AULA);
END
$$ LANGUAGE plpgsql;



--*****************************************************************************************************************************************************************--
----------------------------***************************************  << ALUNO_VIDEO_ASSISTIDO >>  ***************************************----------------------------
--*****************************************************************************************************************************************************************--


--|-------------------------------------------------------------------------------------------------|--
--|--- ############################### ALUNO_ASSISTIR_VIDEO_AULA ############################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| FAZ O ALUNO ASSISTIR À VIDEOAULA (FAZ UM VÍNCULO ALUNO_VIDEO_ASSISTIDO)                         |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DA VIDEOAULA.                                                             |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION ALUNO_ASSISTIR_VIDEO_AULA(CODIGO_VIDEO_AULA INT)
RETURNS VOID
AS $$
DECLARE
	CODIGO_USUARIO INT;
BEGIN
	PERFORM VERIFICAR_PERMISSAO_DA_TABELA_DO_USUARIO('ALUNO');
	
	CODIGO_USUARIO := RETORNAR_CODIGO_DO_USUARIO();

	PERFORM ASSISTIR_VIDEO_AULA(CODIGO_USUARIO, CODIGO_VIDEO_AULA);
END
$$ LANGUAGE plpgsql;


--*****************************************************************************************************************************************************************--
----------------------------****************************************  << QUESTAO # PROFESSOR >>  ****************************************----------------------------
--*****************************************************************************************************************************************************************--


--|-------------------------------------------------------------------------------------------------|--
--|--- ################################ PROFESSOR_CRIAR_QUESTAO ################################ ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CRIA UMA QUESTÃO UNIDA A UMA DISCIPLINA.                                                        |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DA DISCIPLINA; [TEXT] TEXTO DA QUESTÃO.                                   |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: PROFESSOR NÃO TEM PERMISSÃO SOBRE A DICIPLINA.                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION PROFESSOR_CRIAR_QUESTAO(CODIGO_DISCIPLINA INT, TEXTO_INSERIDO TEXT)
RETURNS VOID
AS $$
BEGIN
	PERFORM VERIFICAR_PERMISSAO_DA_TABELA_DO_USUARIO('PROFESSOR');

	IF VERIFICAR_PERMISSAO_DO_USUARIO(CODIGO_DISCIPLINA, 'DISCIPLINA') = FALSE THEN
		RAISE EXCEPTION 'NÃO É PERMITIDO QUE UM PROFESSOR CRIE QUESTÕES EM UMA DISCIPLINA EM UM MÓDULO DO CURSO DE OUTRO!';
		
	END IF;

	PERFORM CRIAR_QUESTAO(CODIGO_DISCIPLINA, TEXTO_INSERIDO);
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ############################### PROFESSOR_DELETAR_QUESTAO ############################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| REMOVE A QUESTÃO.                                                                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DA QUESTÃO.                                                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: PROFESSOR NÃO TEM PERMISSÃO SOBRE A DICIPLINA.                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION PROFESSOR_DELETAR_QUESTAO(CODIGO_QUESTAO INT)
RETURNS VOID
AS $$
BEGIN
	PERFORM VERIFICAR_PERMISSAO_DA_TABELA_DO_USUARIO('PROFESSOR');
	
	IF VERIFICAR_PERMISSAO_DO_USUARIO(CODIGO_QUESTAO, 'QUESTAO') = FALSE THEN
		RAISE EXCEPTION 'NÃO É PERMITIDO QUE UM PROFESSOR REMOVA UMA QUESTÃO EM UMA DISCIPLINA EM UM MÓDULO DO CURSO DE OUTRO!';
		
	END IF;

	PERFORM DELETAR_QUESTAO(CODIGO_QUESTAO);
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ######################### PROFESSOR_LISTAR_QUESTOES_DOS_ALUNOS ########################## ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| LISTA AS QUESTÕES RESPONDIDAS POR ALUNOS EM CURSOS DO PROFESSOR.                                |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION PROFESSOR_LISTAR_QUESTOES_DOS_ALUNOS()
RETURNS VOID
AS $$
DECLARE
	CODIGO_USUARIO INT;
BEGIN
	PERFORM VERIFICAR_PERMISSAO_DA_TABELA_DO_USUARIO('PROFESSOR');

	CODIGO_USUARIO := RETORNAR_CODIGO_DO_USUARIO();

	PERFORM LISTAR_QUESTOES_DOS_ALUNOS(COD_USUARIO);	
	
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ############################### PROFESSOR_CORRIGIR_QUESTAO ############################### --|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CORRIGE UMA QUESTAO_ALUNO COM UM TEXTO QUE REPRESENTA SE A RESPOSTA ESTÁ CORRETA.               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO VÍNCULO QUESTAO_ALUNO CORRIGIDO; [TEXT] RESPOSTA CORRETA INSERIDA.     |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: PROFESSOR NÃO TEM PERMISSÃO SOBRE A DICIPLINA.                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION PROFESSOR_CORRIGIR_QUESTAO(COD_QUESTAO_ALUNO_CORRIGIDA INT, RESPOSTA_CORRETA_INSERIDA TEXT)
RETURNS VOID
AS $$
BEGIN
	PERFORM VERIFICAR_PERMISSAO_DA_TABELA_DO_USUARIO('PROFESSOR');
	
	IF VERIFICAR_PERMISSAO_DO_USUARIO(COD_QUESTAO_ALUNO_CORRIGIDA, 'QUESTAO_ALUNO') = FALSE THEN
		RAISE EXCEPTION 'NÃO É PERMITIDO QUE UM PROFESSOR CORRIJA UMA QUESTAO RESPONDIDA POR UM ALUNO EM UMA DISCIPLINA EM UM MÓDULO DO CURSO DE OUTRO!';

	END IF;

	PERFORM CORRIGIR_QUESTAO(COD_QUESTAO_ALUNO_CORRIGIDA, RESPOSTA_CORRETA_INSERIDA);
END
$$ LANGUAGE plpgsql;



--*****************************************************************************************************************************************************************--
----------------------------*************************************  << QUESTIONARIO # PROFESSOR >>  **************************************----------------------------
--*****************************************************************************************************************************************************************--


--|-------------------------------------------------------------------------------------------------|--
--|--- ############################# PROFESSOR_CRIAR_QUESTIONARIO ############################## ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CRIA UM QUESTIONÁRIO UNIDO A UMA DISCIPLINA.                                                    |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] NOME DO QUESTIONÁRIO; [INT] CÓDIGO DA DISCIPLINA.                                |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: PROFESSOR NÃO TEM PERMISSÃO SOBRE A DICIPLINA.                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION PROFESSOR_CRIAR_QUESTIONARIO(NOME_INSERIDO TEXT, COD_DISCIPLINA_INSERIDA INT)
RETURNS VOID
AS $$
BEGIN
	PERFORM VERIFICAR_PERMISSAO_DA_TABELA_DO_USUARIO('PROFESSOR');
	
	IF VERIFICAR_PERMISSAO_DO_USUARIO(COD_DISCIPLINA_INSERIDA, 'DISCIPLINA') = FALSE THEN
		RAISE EXCEPTION 'NÃO É PERMITIDO QUE UM PROFESSOR CRIE UM QUESTIONÁRIO EM UMA DISCIPLINA EM UM MÓDULO DO CURSO DE OUTRO!';

	ELSE
		PERFORM CRIAR_QUESTIONARIO(NOME_INSERIDO, COD_DISCIPLINA_INSERIDA);
		
	END IF;
END
$$ LANGUAGE plpgsql;
 
--|-------------------------------------------------------------------------------------------------|--
--|--- ############################ PROFESSOR_DELETAR_QUESTIONARIO ############################# ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| REMOVE UM QUESTIONÁRIO.                                                                         |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO QUESTIONÁRIO.                                                          |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: PROFESSOR NÃO TEM PERMISSÃO SOBRE O QUESTIONÁRIO.                            |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION PROFESSOR_DELETAR_QUESTIONARIO(COD_QUESTIONARIO_DELETADO INT)
RETURNS VOID
AS $$
BEGIN
	PERFORM VERIFICAR_PERMISSAO_DA_TABELA_DO_USUARIO('PROFESSOR');
	
	IF VERIFICAR_PERMISSAO_DO_USUARIO(COD_DISCIPLINA_INSERIDA, 'QUESTIONARIO') = FALSE THEN
		RAISE EXCEPTION 'NÃO É PERMITIDO QUE UM PROFESSOR REMOVA UM QUESTIONÁRIO EM UMA DISCIPLINA EM UM MÓDULO DO CURSO DE OUTRO!';
		
	END IF;

	PERFORM DELETAR_QUESTIONARIO(COD_QUESTIONARIO_DELETADO);
END
$$ LANGUAGE plpgsql;



--*****************************************************************************************************************************************************************--
----------------------------*********************************  << QUESTAO_QUESTIONARIO # PROFESSOR >>  **********************************----------------------------
--*****************************************************************************************************************************************************************--


--|-------------------------------------------------------------------------------------------------|--
--|--- ####################### PROFESSOR_VINCULAR_QUESTAO_A_QUESTIONARIO ####################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CRIA UM VÍNCULO ENTRE A QUESTÃO E O QUESTIONÁRIO NA TABELA QUESTAO_QUESTIONARIO.                |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO QUESTIONÁRIO VÍNCULADO; [INT] CÓDIGO DA QUESTÃO VINCULADA.             |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: PROFESSOR NÃO TEM PERMISSÃO SOBRE O QUESTIONÁRIO; PROFESSOR NÃO TEM          |--
--| PERMISSÃO SOBRE A QUESTÃO.                                                                      |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION PROFESSOR_VINCULAR_QUESTAO_A_QUESTIONARIO(COD_QUESTIONARIO_VINCULADO INT, COD_QUESTAO_VINCULADA INT)
RETURNS VOID
AS $$
BEGIN
	PERFORM VERIFICAR_PERMISSAO_DA_TABELA_DO_USUARIO('PROFESSOR');
	
	IF VERIFICAR_PERMISSAO_DO_USUARIO(COD_QUESTIONARIO_VINCULADO, 'QUESTIONARIO') = FALSE THEN
		RAISE EXCEPTION 'NÃO É PERMITIDO QUE UM PROFESSOR FAÇA UM VÍNCULO QUESTÃO-QUESTIONÁRIO COM UM QUESTIONÁRIO EM UMA DISCIPLINA EM UM MÓDULO DO CURSO DE OUTRO!';

	ELSIF VERIFICAR_PERMISSAO_DO_USUARIO(COD_QUESTAO_VINCULADA, 'QUESTAO') = FALSE THEN
		RAISE EXCEPTION 'NÃO É PERMITIDO QUE UM PROFESSOR FAÇA UM VÍNCULO QUESTÃO-QUESTIONÁRIO COM UMA QUESTÃO EM UMA DISCIPLINA EM UM MÓDULO DO CURSO DE OUTRO!';

	END IF;

	PERFORM VINCULAR_QUESTAO_A_QUESTIONARIO(COD_QUESTIONARIO_VINCULADO, COD_QUESTAO_VINCULADA);

END
$$ LANGUAGE plpgsql;



--*****************************************************************************************************************************************************************--
----------------------------*******************************************  << QUESTAO_ALUNO >>  *******************************************----------------------------
--*****************************************************************************************************************************************************************--


--|-------------------------------------------------------------------------------------------------|--
--|--- ########################## ALUNO_SUBMETER_RESPOSTA_DE_QUESTAO ########################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| FAZ O ALUNO SUBMETER UMA RESPOSTA PARA UMA QUESTÃO POR MEIO DO ALUNO_QUESTAO.                   |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DA QUESTÃO; [TEXT] RESPOSTA PARA A QUESTÃO.                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION ALUNO_SUBMETER_RESPOSTA_DE_QUESTAO(COD_QUESTAO_SUBMETIDA INT, RESPOSTA_ALUNO_SUBMETIDA TEXT)
RETURNS VOID
AS $$
DECLARE
	CODIGO_USUARIO INT;
BEGIN
	PERFORM VERIFICAR_PERMISSAO_DA_TABELA_DO_USUARIO('ALUNO');

	CODIGO_USUARIO := RETORNAR_CODIGO_DO_USUARIO();

	PERFORM SUBMETER_RESPOSTA_DE_QUESTAO(COD_USUARIO, COD_QUESTAO_SUBMETIDA, RESPOSTA_ALUNO_SUBMETIDA);
END
$$ LANGUAGE plpgsql;
