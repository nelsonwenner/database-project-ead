---------------------------------------------------------------------------------------------------------------------------------------------------------------------
                      --        ####################################### FUNCTIONS AUXILIARES ########################################        --
                      -- ################################################################################################################### --
---------------------------------------------------------------------------------------------------------------------------------------------------------------------


--*****************************************************************************************************************************************************************--
----------------------------***************************  << FUNCTIONS AUXILIARES DE FUNCTIONS PRINCIPAIS >>  ****************************----------------------------
--*****************************************************************************************************************************************************************--


--|-------------------------------------------------------------------------------------------------|--
--|--- ############################### RETORNAR_TABELA_DO_USUARIO ############################## ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SELECIONA O NOME DA TABELA A QUAL O USUÁRIO LOGADO PERTENCE.                                    |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [TEXT] TEXTO QUE REPRESENTA A TABELA A QUAL O USUÁRIO LOGADO PERTENCE ('ALUNO',          |--
--| 'PROFESSOR' OU 'SUPER USUARIO').                                                                |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION RETORNAR_TABELA_DO_USUARIO()
RETURNS VARCHAR(13)
AS $$
BEGIN
	IF CURRENT_USER IN (SELECT EMAIL FROM ALUNO) THEN
		RETURN 'ALUNO';
		
	ELSIF CURRENT_USER IN (SELECT EMAIL FROM PROFESSOR) THEN
		RETURN 'PROFESSOR';
		
	ELSE
		RETURN 'SUPER USUARIO';
		
	END IF;
END
$$ LANGUAGE plpgsql;


--|-------------------------------------------------------------------------------------------------|--
--|--- ############################### RETORNAR_CODIGO_DO_USUARIO ############################## ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SELECIONA O CÓDIGO DO USUÁRIO LOGADO, CASO ELE SEJA 'ALUNO' OU 'PROFESSOR'.                     |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: 'SUPER USUARIO' EXECUTANDO A FUNÇÃO.                                         |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [INT] CÓDIGO DO USUÁRIO LOGADO.                                                          |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION RETORNAR_CODIGO_DO_USUARIO()
RETURNS INT
AS $$
DECLARE
	CODIGO INT;
	TABELA TEXT := RETORNAR_TABELA_DO_USUARIO();
BEGIN
	

	IF TABELA = 'ALUNO' THEN
		SELECT COD_ALUNO INTO CODIGO FROM ALUNO WHERE EMAIL = CURRENT_USER;
		RETURN CODIGO;
		
	ELSIF TABELA = 'PROFESSOR' THEN
		SELECT COD_PROFESSOR INTO CODIGO FROM PROFESSOR WHERE EMAIL = CURRENT_USER;
		RETURN CODIGO;
		
	ELSE
		RAISE EXCEPTION 'É OBRIGATÓRIO ESTAR LOGADO COMO ALUNO OU COMO PROFESSOR PARA EXECUTAR ESSA FUNÇÃO!';
		
	END IF;
END
$$ LANGUAGE plpgsql;


--|-------------------------------------------------------------------------------------------------|--
--|--- ####################### VERIFICAR_PERMISSAO_DA_TABELA_DO_USUARIO ######################## ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| APLICA CASOS DE EXCEÇÃO CASO O NOME DA TABELA DO USUÁRIO LOGADO NÃO SEJA O MESMO QUE SE DESEJA. |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [TEXT] NOME DA TABELA QUE SE REQUER QUE O USUÁRIO LOGADO PERTENÇA.                     |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: 'SUPER USUARIO' EXECUTANDO A FUNÇÃO; NOME DA TABELA DO USUÁRIO LOGADO        |--
--| DIFERENTE DO NOME DA TABELA QUE SE REQUER QUE O USUÁRIO LOGADO PERTENÇA; A TABELA QUE SE REQUER |--
--| QUE O USUÁRIO LOGADO PERTENÇA SER DIFERENTE DE 'ALUNO' OU PROFESSOR.                            |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION VERIFICAR_PERMISSAO_DA_TABELA_DO_USUARIO(TABELA_DO_USUARIO_REQUERIDA TEXT)
RETURNS VOID
AS $$
DECLARE
	TABELA_DO_USUARIO VARCHAR(13) := RETORNAR_TABELA_DO_USUARIO();
BEGIN
	IF TABELA_DO_USUARIO_REQUERIDA = 'ALUNO_OU_PROFESSOR' THEN
		 IF TABELA_DO_USUARIO = 'SUPER USUARIO' THEN
			RAISE EXCEPTION 'É OBRIGATÓRIO ESTAR LOGADO COMO ALUNO OU COMO PROFESSOR PARA EXECUTAR ESSA FUNÇÃO!';

		 END IF;
		 
	ELSIF TABELA_DO_USUARIO_REQUERIDA != TABELA_DO_USUARIO THEN
		IF TABELA_DO_USUARIO_REQUERIDA = 'ALUNO' THEN
			RAISE EXCEPTION 'É OBRIGATÓRIO ESTAR LOGADO COMO ALUNO PARA EXECUTAR ESSA FUNÇÃO!';

		ELSIF TABELA_DO_USUARIO_REQUERIDA = 'PROFESSOR' THEN
			RAISE EXCEPTION 'É OBRIGATÓRIO ESTAR LOGADO COMO PROFESSOR PARA EXECUTAR ESSA FUNÇÃO!';

		ELSE
			RAISE EXCEPTION 'A TABELA_DO_USUARIO_REQUERIDA SÓ PODE SER ALUNO, PROFESSOR OU ALUNO_OU_PROFESSOR!';

		END IF;

	END IF;
END
$$ LANGUAGE plpgsql;


--|-------------------------------------------------------------------------------------------------|--
--|--- ############################# CALCULAR_DATA_PAGAMENTO_ATUAL ############################# ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CALCULA A DATA DE PAGAMENTO MAIS RECENTE (OS PAGAMENTOS ACONTECEM TODO DIA 01 DO MÊS).          |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [DATE] DATA DE PAGAMENTO MAIS RECENTE.                                                   |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION CALCULAR_DATA_PAGAMENTO_ATUAL()
RETURNS DATE
AS $$
DECLARE
	MES_DATA_PAGAMENTO_ATUAL INT;
	ANO_DATA_PAGAMENTO_ATUAL INT;
	DATA_PAGAMENTO_ATUAL DATE;
BEGIN
	MES_DATA_PAGAMENTO_ATUAL := EXTRACT(MONTH FROM DATE(NOW()));
	ANO_DATA_PAGAMENTO_ATUAL := EXTRACT(YEAR FROM DATE(NOW()));
 
	DATA_PAGAMENTO_ATUAL := CAST(CAST(ANO_DATA_PAGAMENTO_ATUAL AS VARCHAR(4)) || '-' || CAST(MES_DATA_PAGAMENTO_ATUAL AS VARCHAR(2)) || '-01' AS DATE);
	RETURN DATA_PAGAMENTO_ATUAL;
END
$$ LANGUAGE plpgsql;


--|-------------------------------------------------------------------------------------------------|--
--|--- ############################## VERIFICAR_SE_REGISTRO_EXISTE ############################# ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| VERIFICA A EXISTÊNCIA DE UM REGISTRO EM UMA TABELA.                                             |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO REGISTRO QUE DEVE EXISTIR EM UMA TABELA; [TEXT] NOME DA TABELA EM QUE  |--
--| O REGISTRO DEVE EXISTIR.                                                                        |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [BOOLEAN] BOLEANO SOBRE A EXISTÊNCIA DO REGISTRO NA TABELA.                              |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION VERIFICAR_SE_REGISTRO_EXISTE(COD_ANALISADO INT, TABELA TEXT)
RETURNS BOOLEAN
AS $$
DECLARE
	REGISTRO RECORD;
BEGIN
	IF TABELA = 'ALUNO' THEN
		SELECT * INTO REGISTRO FROM ALUNO WHERE COD_ALUNO = COD_ANALISADO;

		IF REGISTRO.COD_ALUNO IS NOT NULL THEN
			RETURN TRUE;
			
		ELSE
			RETURN FALSE;
			
		END IF;

	ELSIF TABELA = 'PROFESSOR' THEN
		SELECT * INTO REGISTRO FROM PROFESSOR WHERE COD_PROFESSOR = COD_ANALISADO;

		IF REGISTRO.COD_PROFESSOR IS NOT NULL THEN
			RETURN TRUE;

		ELSE
			RETURN FALSE;

		END IF;

	ELSIF TABELA = 'CURSO' THEN
		SELECT * INTO REGISTRO FROM CURSO WHERE COD_CURSO = COD_ANALISADO;

		IF REGISTRO.COD_CURSO IS NOT NULL THEN
			RETURN TRUE;

		ELSE
			RETURN FALSE;

		END IF;

	ELSIF TABELA = 'MODULO' THEN
		SELECT * INTO REGISTRO FROM MODULO WHERE COD_MODULO = COD_ANALISADO;
		IF REGISTRO.COD_MODULO IS NOT NULL THEN
			RETURN TRUE;

		ELSE
			RETURN FALSE;

		END IF;

	ELSIF TABELA = 'DISCIPLINA' THEN
		SELECT * INTO REGISTRO FROM DISCIPLINA WHERE COD_DISCIPLINA = COD_ANALISADO;

		IF REGISTRO.COD_DISCIPLINA IS NOT NULL THEN
			RETURN TRUE;

		ELSE
			RETURN FALSE;

		END IF;

	ELSIF TABELA = 'VIDEO_AULA' THEN
		SELECT * INTO REGISTRO FROM VIDEO_AULA WHERE COD_VIDEO_AULA = COD_ANALISADO;

		IF REGISTRO.COD_VIDEO_AULA IS NOT NULL THEN
			RETURN TRUE;

		ELSE
			RETURN FALSE;

		END IF;

	ELSIF TABELA = 'QUESTAO' THEN
		SELECT * INTO REGISTRO FROM QUESTAO WHERE COD_QUESTAO = COD_ANALISADO;

		IF REGISTRO.COD_QUESTAO IS NOT NULL THEN
			RETURN TRUE;

		ELSE
			RETURN FALSE;

		END IF;

	ELSIF TABELA = 'QUESTIONARIO' THEN
		SELECT * INTO REGISTRO FROM QUESTIONARIO WHERE COD_QUESTIONARIO = COD_ANALISADO;

		IF REGISTRO.COD_QUESTIONARIO IS NOT NULL THEN
			RETURN TRUE;

		ELSE
			RETURN FALSE;

		END IF;

	ELSIF TABELA = 'QUESTAO_ALUNO' THEN
		SELECT * INTO REGISTRO FROM QUESTAO_ALUNO WHERE COD_QUESTAO_ALUNO = COD_ANALISADO;

		IF REGISTRO.COD_QUESTAO_ALUNO IS NOT NULL THEN
			RETURN TRUE;

		ELSE
			RETURN FALSE;

		END IF;
	END IF;

	RETURN NULL;
    
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ############################# VERIFICAR_PERMISSAO_DO_USUARIO ############################ ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| VERIFICA A POSSIBILIDADE DO USUÁRIO LOGADO MANIPULAR O REGISTRO DA LINHA DA TABELA QUE POSSUI O |--
--| CÓDIGO DA TABELA.                                                                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DA TABELA QUE SE REQUER QUE O USUÁRIO LOGADO POSSUA PERMISSÃO; [TEXT]     |--
--| NOME DA TABELA QUE SE REQUER QUE O USUÁRIO LOGADO POSSUA PERMISSÃO.                             |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: 'SUPER USUARIO' EXECUTANDO A FUNÇÃO; CÓDIGO DA TABELA QUE SE REQUER QUE O    |--
--| USUÁRIO LOGADO POSSUA PERMISSÃO INVÁLIDO.                                                       |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [BOOLEAN] BOLEANO SOBRE A POSSIBILIDADE DO USUÁRIO LOGADO MANIPULAR O REGISTRO DA LINHA  |--
--| DA TABELA QUE POSSUI O CÓDIGO DA TABELA.                                                        |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION VERIFICAR_PERMISSAO_DO_USUARIO(CODIGO_TABELA_VERIFICADA INT, TABELA TEXT)
RETURNS BOOLEAN
AS $$
DECLARE
	TABELA_DO_USUARIO VARCHAR(13);
	CODIGO_USUARIO_VERIFICADO INT;
	EMAIL_USUARIO_VERIFICADO TEXT;
BEGIN
	TABELA_DO_USUARIO := RETORNAR_TABELA_DO_USUARIO();

	IF TABELA_DO_USUARIO = 'SUPER USUARIO' THEN
		RAISE EXCEPTION 'ESSA FUNÇÃO NÃO DEVE SER EXECUTADA POR UM SUPER USUARIO!';
	
	ELSIF TABELA = 'CURSO' THEN
		IF VERIFICAR_SE_REGISTRO_EXISTE(CODIGO_TABELA_VERIFICADA, 'CURSO') IS FALSE THEN
			RAISE EXCEPTION 'ESSE CURSO NÃO EXISTE, INSIRA UM COD_CURSO VÁLIDO!';

		ELSIF TABELA_DO_USUARIO = 'PROFESSOR' THEN
			SELECT COD_PROFESSOR INTO CODIGO_USUARIO_VERIFICADO FROM CURSO WHERE COD_CURSO = CODIGO_TABELA_VERIFICADA;

		END IF;
		
	ELSIF TABELA = 'MODULO' THEN
		IF VERIFICAR_SE_REGISTRO_EXISTE(CODIGO_TABELA_VERIFICADA, 'MODULO') IS FALSE THEN
			RAISE EXCEPTION 'ESSE MÓDULO NÃO EXISTE, INSIRA UM COD_MODULO VÁLIDO!';

		ELSIF TABELA_DO_USUARIO = 'PROFESSOR' THEN
			SELECT COD_PROFESSOR INTO CODIGO_USUARIO_VERIFICADO FROM CURSO
			       WHERE COD_CURSO = (SELECT COD_CURSO FROM MODULO WHERE COD_MODULO = CODIGO_TABELA_VERIFICADA);

		END IF;

	ELSIF TABELA = 'DISCIPLINA' THEN
		IF VERIFICAR_SE_REGISTRO_EXISTE(CODIGO_TABELA_VERIFICADA, 'DISCIPLINA') IS FALSE THEN
			RAISE EXCEPTION 'ESSA DISCIPLINA NÃO EXISTE, INSIRA UM COD_DISCIPLINA VÁLIDO!';

		ELSIF TABELA_DO_USUARIO = 'PROFESSOR' THEN
			SELECT COD_PROFESSOR INTO CODIGO_USUARIO_VERIFICADO FROM CURSO
			       WHERE COD_CURSO = (SELECT COD_CURSO FROM MODULO WHERE COD_MODULO =
			       (SELECT COD_MODULO FROM DISCIPLINA WHERE COD_DISCIPLINA = CODIGO_TABELA_VERIFICADA));

		END IF;
	
	ELSIF TABELA = 'VIDEO_AULA' THEN
		IF VERIFICAR_SE_REGISTRO_EXISTE(CODIGO_TABELA_VERIFICADA, 'VIDEO_AULA') IS FALSE THEN
			RAISE EXCEPTION 'ESSA VIDEO_AULA NÃO EXISTE, INSIRA UM COD_VIDEO_AULA VÁLIDO!';

		ELSIF TABELA_DO_USUARIO = 'PROFESSOR' THEN
			SELECT COD_PROFESSOR INTO CODIGO_USUARIO_VERIFICADO FROM CURSO
			       WHERE COD_CURSO = (SELECT COD_CURSO FROM MODULO WHERE COD_MODULO =
			       (SELECT COD_MODULO FROM DISCIPLINA WHERE COD_DISCIPLINA =
			       (SELECT COD_DISCIPLINA FROM VIDEO_AULA WHERE COD_VIDEO_AULA = CODIGO_TABELA_VERIFICADA)));

		END IF;

	ELSIF TABELA = 'QUESTAO' THEN
		IF VERIFICAR_SE_REGISTRO_EXISTE(CODIGO_TABELA_VERIFICADA, 'QUESTAO') IS FALSE THEN
			RAISE EXCEPTION 'ESSA QUESTAO NÃO EXISTE, INSIRA UM COD_QUESTAO VÁLIDO!';

		ELSIF TABELA_DO_USUARIO = 'PROFESSOR' THEN
			SELECT COD_PROFESSOR INTO CODIGO_USUARIO_VERIFICADO FROM CURSO
			       WHERE COD_CURSO = (SELECT COD_CURSO FROM MODULO WHERE COD_MODULO =
			       (SELECT COD_MODULO FROM DISCIPLINA WHERE COD_DISCIPLINA =
			       (SELECT COD_DISCIPLINA FROM QUESTAO WHERE COD_QUESTAO = CODIGO_TABELA_VERIFICADA)));
			
		END IF;

	ELSIF TABELA = 'QUESTAO_ALUNO' THEN
		IF VERIFICAR_SE_REGISTRO_EXISTE(CODIGO_TABELA_VERIFICADA, 'QUESTAO_ALUNO') IS FALSE THEN
			RAISE EXCEPTION 'ESSA QUESTAO_ALUNO NÃO EXISTE, INSIRA UM COD_QUESTAO_ALUNO VÁLIDO!';

		ELSIF TABELA_DO_USUARIO = 'PROFESSOR' THEN
			SELECT COD_PROFESSOR INTO CODIGO_USUARIO_VERIFICADO FROM CURSO
			       WHERE COD_CURSO = (SELECT COD_CURSO FROM MODULO WHERE COD_MODULO =
			       (SELECT COD_MODULO FROM DISCIPLINA WHERE COD_DISCIPLINA =
			       (SELECT COD_DISCIPLINA FROM QUESTAO WHERE COD_QUESTAO =
			       (SELECT COD_QUESTAO FROM QUESTAO_ALUNO WHERE COD_QUESTAO_ALUNO = CODIGO_TABELA_VERIFICADA))));
			
		END IF;

	ELSIF TABELA = 'QUESTIONARIO' THEN
		IF VERIFICAR_SE_REGISTRO_EXISTE(CODIGO_TABELA_VERIFICADA, 'QUESTIONARIO') IS FALSE THEN
			RAISE EXCEPTION 'ESSE QUESTIONARIO NÃO EXISTE, INSIRA UM COD_QUESTIONARIO VÁLIDO!';

		ELSIF TABELA_DO_USUARIO = 'PROFESSOR' THEN
			SELECT COD_PROFESSOR INTO CODIGO_USUARIO_VERIFICADO FROM CURSO
			       WHERE COD_CURSO = (SELECT COD_CURSO FROM MODULO WHERE COD_MODULO =
			       (SELECT COD_MODULO FROM DISCIPLINA WHERE COD_DISCIPLINA =
			       (SELECT COD_DISCIPLINA FROM QUESTIONARIO WHERE COD_QUESTIONARIO = CODIGO_TABELA_VERIFICADA)));
			
		END IF;

	ELSE
		RAISE EXCEPTION 'TABELA INVÁLIDA!';

	END IF;

	IF TABELA_DO_USUARIO = 'ALUNO' THEN
		SELECT EMAIL INTO EMAIL_USUARIO_VERIFICADO FROM ALUNO WHERE COD_ALUNO = CODIGO_USUARIO_VERIFICADO;

	ELSE
		SELECT EMAIL INTO EMAIL_USUARIO_VERIFICADO FROM PROFESSOR WHERE COD_PROFESSOR = CODIGO_USUARIO_VERIFICADO;

	END IF;

	IF EMAIL_USUARIO_VERIFICADO = CURRENT_USER THEN
		RETURN TRUE;

	END IF;
	
	RETURN FALSE;

END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- #################################### CURSO_DISPONIVEL ################################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| VERIFICA SE O CURSO ESTÁ PUBLICADO.                                                             |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO O CURSO QUE SE DESEJA VERIFICAR SE ESTÁ PUBLICADO.                        |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [BOOLEAN] BOLEANO SOBRE O CURSO ESTAR PUBLICADO.                                         |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION CURSO_DISPONIVEL(COD_CURSO_ANALISADO INT)
RETURNS BOOLEAN
AS $$
DECLARE
	CURSO_ANALISADO_PUBLICADO BOOLEAN;
BEGIN
	SELECT PUBLICADO INTO CURSO_ANALISADO_PUBLICADO FROM CURSO WHERE COD_CURSO = COD_CURSO_ANALISADO;
	RETURN CURSO_ANALISADO_PUBLICADO;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ############################# VERIFICAR_VINCULO_ALUNO_CURSO ############################# ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| VERIFICA SE O ALUNO ESTÁ VÍNCULADO AO CURSO, POR MEIO DE UM ALUNO_CURSO.                        |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO ALUNO QUE SE DESEJA VERIFICAR SE ESTÁ VINCULADO; [INT] CÓDIGO DA       |--
--| TABELA QUE SE DESEJA VERIFICAR SE ESTÁ VINCULADA.                                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [BOOLEAN] BOLEANO SOBRE O ALUNO ESTAR VÍNCULADO AO CURSO, POR MEIO DE UM ALUNO_CURSO.    |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION VERIFICAR_VINCULO_ALUNO_CURSO(COD_ALUNO_ANALISADO INT, COD_CURSO_ANALISADO INT)
RETURNS BOOLEAN
AS $$
DECLARE
	ALUNO_CURSO_ANALISADO RECORD;
BEGIN
	SELECT COD_ALUNO_CURSO INTO ALUNO_CURSO_ANALISADO FROM ALUNO_CURSO WHERE COD_ALUNO_ANALISADO = COD_ALUNO AND COD_CURSO_ANALISADO = COD_CURSO;
	 
	IF ALUNO_CURSO_ANALISADO IS NULL THEN
		RETURN FALSE;

	ELSE
		RETURN TRUE;

	END IF;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ################################ PERIODO_CURSANDO_VALIDO ################################ ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| VERIFICA SE O PERÍODO EM QUE O ALUNO ESTÁ CURSANDO AINDA NÃO ULTRAPASSOU A DURAÇÃO DO CURSO.    |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO ALUNO QUE SE DESEJA VERIFICAR SE O PERÍODO CURSANDO É VÁLIDO; [INT]    |--
--| CÓDIGO DO CURSO EM QUE ESSA VERIFICAÇÃO SERÁ DIRECIONADA.                                       |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [BOOLEAN] BOLEANO SOBRE O PERÍODO EM QUE O ALUNO ESTÁ CURSANDO AINDA NÃO TER             |--
--| ULTRAPASSADO A DURAÇÃO DO CURSO.                                                                |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION PERIODO_CURSANDO_VALIDO(COD_ALUNO_ANALISADO INT, COD_CURSO_ANALISADO INT)
RETURNS BOOLEAN
AS $$
DECLARE
	DATA_COMPRA_ALUNO_CURSO_ANALISADA DATE;
	DURACAO_CURSO_ANALISADA INT;
BEGIN
	SELECT DATA_COMPRA INTO DATA_COMPRA_ALUNO_CURSO_ANALISADA FROM ALUNO_CURSO WHERE COD_ALUNO_ANALISADO = COD_ALUNO AND COD_CURSO_ANALISADO = COD_CURSO;
	SELECT DURACAO INTO DURACAO_CURSO_ANALISADA FROM CURSO WHERE COD_CURSO_ANALISADO = COD_CURSO;
	   
	IF DATA_COMPRA_ALUNO_CURSO_ANALISADA + DURACAO_CURSO_ANALISADA >= DATE(NOW()) THEN
		RETURN TRUE;

	ELSE
		RETURN FALSE;

	END IF;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ################################## ALUNO_AINDA_CURSANDO ################################# ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| VERIFICA SE O ALUNO AINDA ESTÁ CURSANDO O CURSO.                                                |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO ALUNO QUE SE DESEJA VERIFICAR SE AINDA ESTÁ CURSANDO; [INT] CÓDIGO DO  |--
--| CURSO EM QUE ESSA VERIFICAÇÃO SERÁ DIRECIONADA.                                                 |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [BOOLEAN] BOLEANO SOBRE O ALUNO AINDA ESTÁ CURSANDO O CURSO.                             |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION ALUNO_AINDA_CURSANDO(COD_ALUNO_ANALISADO INT, COD_CURSO_ANALISADO INT)
RETURNS BOOLEAN
AS $$
BEGIN
	IF VERIFICAR_VINCULO_ALUNO_CURSO(COD_ALUNO_ANALISADO, COD_CURSO_ANALISADO) IS TRUE
	AND PERIODO_CURSANDO_VALIDO(COD_ALUNO_ANALISADO, COD_CURSO_ANALISADO) IS TRUE THEN
		RETURN TRUE;

	ELSE
		RETURN FALSE;

	END IF;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- #################################### ALUNO_JA_CURSOU #################################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| VERIFICA SE O ALUNO JÁ CURSOU (E NÃO CURSA MAIS) O CURSO.                                       |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO ALUNO QUE SE DESEJA VERIFICAR SE JÁ CURSOU; [INT] CÓDIGO DO CURSO EM   |--
--| QUE ESSA VERIFICAÇÃO SERÁ DIRECIONADA.                                                          |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [BOOLEAN] BOLEANO SOBRE O ALUNO JÁ TER CURSADO (E NÃO CURSAR MAIS) O CURSO.              |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION ALUNO_JA_CURSOU(COD_ALUNO_ANALISADO INT, COD_CURSO_ANALISADO INT)
RETURNS BOOLEAN
AS $$
BEGIN
	IF VERIFICAR_VINCULO_ALUNO_CURSO(COD_ALUNO_ANALISADO, COD_CURSO_ANALISADO) = TRUE
	AND PERIODO_CURSANDO_VALIDO(COD_ALUNO_ANALISADO, COD_CURSO_ANALISADO) != TRUE THEN
		RETURN TRUE;

	ELSE
		RETURN FALSE;

	END IF;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- #################################### SELECIONAR_PRECO ################################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SELECIONA O PREÇO DO CURSO.                                                                     |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO CURSO QUE SE DESEJA SELECIONAR O PREÇO.                                |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [BOOLEAN] BOLEANO SOBRE O ALUNO JÁ TER CURSADO (E NÃO CURSAR MAIS) O CURSO.              |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION SELECIONAR_PRECO(COD_CURSO_ANALISADO INT)
RETURNS FLOAT
AS $$
DECLARE
	PRECO_SELECIONADO FLOAT;
BEGIN
	SELECT PRECO INTO PRECO_SELECIONADO FROM CURSO WHERE COD_CURSO_ANALISADO = COD_CURSO;
	RETURN PRECO_SELECIONADO;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ################################### ALUNO_JA_ASSISTIU ################################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| VERIFICA SE O ALUNO JÁ ASSISTIU À VIDEOAULA.                                                    |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO CURSO QUE SE DESEJA VERIFICAR; [INT] CÓDIGO DA VIDEOAULA EM QUE ESSA   |--
--| VERIFICAÇÃO SERÁ DIRECIONADA.                                                                   |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [BOOLEAN] BOLEANO SOBRE O ALUNO JÁ TER ASSISTIDO À VIDEOAULA.                            |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION ALUNO_JA_ASSISTIU(CODIGO_ALUNO INT, CODIGO_VIDEO_AULA INT)
RETURNS BOOLEAN
AS $$
DECLARE
	REGISTRO_VIDEO_AULA RECORD;
BEGIN
	FOR REGISTRO_VIDEO_AULA IN (SELECT * FROM ALUNO_VIDEO_ASSISTIDO) LOOP
		IF REGISTRO_VIDEO_AULA.COD_VIDEO_AULA = CODIGO_VIDEO_AULA AND REGISTRO_VIDEO_AULA.COD_ALUNO = CODIGO_ALUNO THEN
			RETURN TRUE;

		END IF;

	END LOOP;

	RETURN FALSE;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ######################## VERIFICAR_VINCULO_QUESTAO_QUESTIONARIO ######################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| VERIFICA SE A QUESTÃO ESTÁ VÍNCULADA AO QUESTIONÁRIO, POR MEIO DE UM QUESTAO_QUESTIONARIO.      |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DA QUESTÃO QUE SE DESEJA VERIFICAR SE ESTÁ VINCULADA; [INT] CÓDIGO DO     |--
--| QUESTIONÁRIO QUE SE DESEJA VERIFICAR SE ESTÁ VINCULADO.                                         |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [BOOLEAN] BOLEANO SOBRE A QUESTÃO ESTAR VÍNCULADA AO QUESTIONÁRIO, POR MEIO DE UM        |--
--| QUESTAO_QUESTIONARIO.                                                                           |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION VERIFICAR_VINCULO_QUESTAO_QUESTIONARIO(COD_QUESTIONARIO_ANALISADO INT, COD_QUESTAO_ANALISADA INT)
RETURNS BOOLEAN
AS $$
DECLARE
	QUESTAO_QUESTIONARIO_ANALISADO RECORD;
BEGIN
	SELECT * INTO QUESTAO_QUESTIONARIO_ANALISADO FROM QUESTAO_QUESTIONARIO WHERE COD_QUESTIONARIO = COD_QUESTIONARIO_ANALISADO
	AND COD_QUESTAO = COD_QUESTAO_ANALISADA;
	
	IF QUESTAO_QUESTIONARIO_ANALISADO IS NULL THEN
		RETURN FALSE;

	ELSE
		RETURN TRUE;

	END IF;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ############################ VERIFICAR_VINCULO_QUESTAO_ALUNO ############################ ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| VERIFICA SE A QUESTÃO ESTÁ VÍNCULADA AO ALUNO, POR MEIO DE UM QUESTAO_ALUNO.                    |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO ALUNO QUE SE DESEJA VERIFICAR SE ESTÁ VINCULADA; [INT] CÓDIGO DA       |--
--| QUESTÃO QUE SE DESEJA VERIFICAR SE ESTÁ VINCULADO.                                              |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [BOOLEAN] BOLEANO SOBRE A QUESTÃO ESTAR VÍNCULADA AO ALUNO, POR MEIO DE UM               |--
--| QUESTAO_ALUNO.                                                                                  |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION VERIFICAR_VINCULO_QUESTAO_ALUNO(COD_ALUNO_ANALISADO INT, COD_QUESTAO_ANALISADA INT)
RETURNS BOOLEAN
AS $$
DECLARE
	ALUNO_QUESTAO_ANALISADO RECORD;
BEGIN
	SELECT * INTO ALUNO_QUESTAO_ANALISADO FROM QUESTAO_ALUNO WHERE COD_ALUNO = COD_ALUNO_ANALISADO AND COD_QUESTAO = COD_QUESTAO_ANALISADA;

	IF ALUNO_QUESTAO_ANALISADO IS NULL THEN
		RETURN FALSE;

	ELSE
		RETURN TRUE;

	END IF;
END
$$ LANGUAGE plpgsql;



--*****************************************************************************************************************************************************************--
----------------------------***************************  << FUNCTIONS AUXILIARES DE FUNCTIONS DE TRIGGERS >>  ***************************----------------------------
--*****************************************************************************************************************************************************************--


--|-------------------------------------------------------------------------------------------------|--
--|--- ##################################### RETORNA_IDADE ##################################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SELECIONA A IDADE BASEADA EM UMA DATA DE NASCIMENTO.                                            |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [DATE] DATA DE NASCIMENTO.                                                             |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [INT] IDADE.                                                                             |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

/* RETORNA IDADE */
CREATE OR REPLACE FUNCTION RETORNA_IDADE(DATA_NASCIMENTO DATE)
RETURNS INT
AS $$
BEGIN
	RETURN EXTRACT(YEAR FROM AGE(DATA_NASCIMENTO));
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ########################## VERIFICAR_CPF_USUARIO_JA_REGISTRADO ########################## ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| VERIFICA SE EXISTE ALGUM USUÁRIO DA TABELA ESPECIFICADA COM O CPF ESPECIFICADO.                 |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [TEXT] CPF DO USUÁRIO; [TEXT] TABELA DO USUÁRIO.                                       |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [BOOLEAN] BOOLEANO SOBRE EXISTIR ALGUM USUÁRIO DA TABELA ESPECIFICADA COM O CPF          |--
--| ESPECIFICADO.                                                                                   |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION VERIFICAR_CPF_USUARIO_JA_REGISTRADO(CPF_USUARIO TEXT, TABELA TEXT)
RETURNS BOOLEAN
AS $$
DECLARE
	USUARIO_COM_CPF RECORD;
BEGIN
	IF TABELA = 'ALUNO' THEN
		SELECT COD_ALUNO INTO USUARIO_COM_CPF FROM ALUNO WHERE CPF = CPF_USUARIO;

	ELSIF TABELA = 'PROFESSOR' THEN
		SELECT COD_PROFESSOR INTO USUARIO_COM_CPF FROM PROFESSOR WHERE CPF = CPF_USUARIO;

	ELSE
		RETURN NULL;

	END IF;

	IF USUARIO_COM_CPF IS NOT NULL THEN
		RETURN TRUE;

	ELSE
		RETURN FALSE;

	END IF;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ######################### VERIFICAR_EMAIL_USUARIO_JA_REGISTRADO ######################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| VERIFICA SE EXISTE ALGUM USUÁRIO DA TABELA ESPECIFICADA COM O EMAIL ESPECIFICADO.               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [TEXT] EMAIL DO USUÁRIO; [TEXT] TABELA DO USUÁRIO.                                     |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [BOOLEAN] BOOLEANO SOBRE EXISTIR ALGUM USUÁRIO DA TABELA ESPECIFICADA COM O EMAIL        |--
--| ESPECIFICADO.                                                                                   |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION VERIFICAR_EMAIL_USUARIO_JA_REGISTRADO(EMAIL_USUARIO TEXT, TABELA TEXT)
RETURNS BOOLEAN
AS $$
DECLARE
	USUARIO_COM_EMAIL RECORD;
BEGIN
	IF TABELA = 'ALUNO' THEN
		SELECT COD_ALUNO INTO USUARIO_COM_EMAIL FROM ALUNO WHERE EMAIL = EMAIL_USUARIO;
		
	ELSIF TABELA = 'PROFESSOR' THEN
		SELECT COD_PROFESSOR INTO USUARIO_COM_EMAIL FROM PROFESSOR WHERE EMAIL = EMAIL_USUARIO;

	ELSE
		RETURN NULL;

	END IF;
	
	IF USUARIO_COM_EMAIL IS NOT NULL THEN
		RETURN TRUE;

	ELSE
		RETURN FALSE;

	END IF;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ########################## VERIFICAR_EXISTENCIA_ALUNOS_CURSANDO ######################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| VERIFICA SE EXISTE ALGUM ALUNO CURSANDO O CURSO ESPECIFICADO.                                   |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO CURSO.                                                                 |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [BOOLEAN] BOOLEANO SOBRE EXISTIR ALGUM ALUNO CURSANDO O CURSO ESPECIFICADO.              |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION VERIFICAR_EXISTENCIA_ALUNOS_CURSANDO(CODIGO_CURSO INT)
RETURNS BOOLEAN
AS $$
DECLARE
	REGISTRO_ALUNO RECORD;
BEGIN
	FOR REGISTRO_ALUNO IN (SELECT * FROM ALUNO WHERE COD_ALUNO IN (SELECT COD_ALUNO FROM ALUNO_CURSO WHERE COD_CURSO = CODIGO_CURSO)) LOOP
		IF PERIODO_CURSANDO_VALIDO(REGISTRO_ALUNO.COD_ALUNO, CODIGO_CURSO) IS TRUE THEN
			RETURN TRUE;

		END IF;

	END LOOP;

	RETURN FALSE;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ############################## INCREMENTAR_NUMERO_MODULOS ############################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| APLICA O INCREMENTO ESPECIFICADO NO NÚMERO DE MÓDULOS DO CURSO ESPECIFICADO.                    |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO CURSO; [INT] INCREMENTO A SER APLICADO NO NÚMERO DE MÓDULOS DO CURSO.  |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION INCREMENTAR_NUMERO_MODULOS(CODIGO_CURSO INT, INCREMENTO INT)
RETURNS VOID
AS $$
BEGIN
	UPDATE CURSO SET NUMERO_MODULOS = NUMERO_MODULOS + INCREMENTO WHERE COD_CURSO = CODIGO_CURSO;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ######################### VERIFICAR_SE_ALTEROU_APENAS_PUBLICADO ######################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| VERIFICA SE APENAS O PUBLICADO DO CURSO PODE TER SIDO ALTERADO EM UMA ATUALIZAÇÃO DA TABELA     |--
--| CURSO, SENDO ANALISADOS TODOS OS ATRIBUTOS DE DEPOIS E DE DEPOIS DA ATUALIZAÇÃO DO CURSO.       |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO CURSO ANTES DA ATUALIZAÇÃO; [INT] CÓDIGO DO CURSO DEPOIS DA            |--
--| ATUALIZAÇÃO; [TEXT] NOME DO CURSO ANTES DA ATUALIZAÇÃO; [TEXT] NOME DO CURSO DEPOIS DA          |--
--| ATUALIZAÇÃO; [TEXT] DESCRIÇÃO DO CURSO ANTES DA ATUALIZAÇÃO; [TEXT] DESCRIÇÃO DO CURSO DEPOIS   |--
--| DA ATUALIZAÇÃO; [INT] DURAÇÃO DO CURSO ANTES DA ATUALIZAÇÃO; [INT] DURAÇÃO DO CURSO DEPOIS DA   |--
--| ATUALIZAÇÃO; [FLOAT] PREÇO DO CURSO ANTES DA ATUALIZAÇÃO; [FLOAT] PREÇO DO CURSO DEPOIS DA      |--
--| ATUALIZAÇÃO; [INT] NÚMERO DE MÓDULOS DO CURSO ANTES DA ATUALIZAÇÃO; [INT] NÚMERO DE MÓDULOS DO  |--
--| CURSO DEPOIS DA ATUALIZAÇÃO; [FLOAT] PREÇO DO CURSO ANTES DA ATUALIZAÇÃO; [FLOAT] PREÇO DO      |--
--| CURSO DEPOIS DA ATUALIZAÇÃO; [BOOLEAN] DISPONIBILIDADE DO CURSO ANTES DA ATUALIZAÇÃO; [BOOLEAN] |--
--| DISPONIBILIDADE DO CURSO DEPOIS DA ATUALIZAÇÃO; [INT] CÓDIGO DO PROFESSOR DO CURSO ANTES DA     |--
--| ATUALIZAÇÃO; [INT] CÓDIGO DO PROFESSOR DO CURSO DEPOIS DA ATUALIZAÇÃO.                          |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [BOOLEAN] BOOLEANO SOBRE APENAS O PUBLICADO DO CURSO PODER TER SIDO ALTERADO.            |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION VERIFICAR_SE_ALTEROU_APENAS_PUBLICADO(OLD_COD_CURSO INT, NEW_COD_CURSO INT,
	                                                         OLD_NOME TEXT, NEW_NOME TEXT,
	                                                         OLD_DESCRICAO TEXT, NEW_DESCRICAO TEXT,
	                                                         OLD_DURACAO INT, NEW_DURACAO INT,
	                                                         OLD_PRECO FLOAT, NEW_PRECO FLOAT,
	                                                         OLD_NUMERO_MODULOS INT, NEW_NUMERO_MODULOS INT,
	                                                         OLD_DISPONIBILIDADE BOOLEAN, NEW_DISPONIBILIDADE BOOLEAN,
	                                                         OLD_COD_PROFESSOR INT, NEW_COD_PROFESSOR INT)
RETURNS BOOLEAN
AS $$
BEGIN
	IF (OLD_COD_CURSO != NEW_COD_CURSO OR
	    OLD_NOME != NEW_NOME OR
	    OLD_DESCRICAO != NEW_DESCRICAO OR
	    OLD_DURACAO != NEW_DURACAO OR
	    OLD_PRECO != NEW_PRECO OR
	    OLD_NUMERO_MODULOS != NEW_NUMERO_MODULOS OR
	    OLD_DISPONIBILIDADE != NEW_DISPONIBILIDADE OR
	    OLD_COD_PROFESSOR != NEW_COD_PROFESSOR) IS TRUE THEN
		RETURN FALSE;

	END IF;

	RETURN TRUE;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ##################### VERIFICAR_POSSIBILIDADE_DELETE_UPDATE_NO_CURSO #################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| APLICA CASOS DE EXCEÇÃO CASO OCORRER ALGUMA ALTERAÇÃO DENTRO DE UM CURSO COM ELE ESTANDO        |--
--| PUBLICADO OU COM ALUNOS QUE AINDA ESTÃO CURSANDO.                                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO CURSO.                                                                 |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: CURSO PUBLICADO; EXISTÊNCIA DE ALUNOS CURSANDO.                              |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION VERIFICAR_POSSIBILIDADE_DELETE_UPDATE_NO_CURSO(CODIGO_CURSO INT)
RETURNS VOID
AS $$
BEGIN
	IF (SELECT PUBLICADO FROM CURSO WHERE COD_CURSO = CODIGO_CURSO) IS TRUE THEN
		RAISE EXCEPTION 'NÃO É POSSÍVEL ADICIONAR, ALTERAR OU REMOVER NADA QUE ESTEJA EM UM CURSO JÁ PUBLICADO';

	ELSIF VERIFICAR_EXISTENCIA_ALUNOS_CURSANDO(CODIGO_CURSO) IS TRUE THEN
		RAISE EXCEPTION 'NÃO É POSSÍVEL ADICIONAR, ALTERAR OU REMOVER NADA QUE ESTEJA EM UM CURSO ONDE AINDA HÁ ALUNOS CURSANDO!';

	END IF;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ################################ CALCULAR_DURACAO_CURSO ################################# ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CÁLCULA A DURAÇÃO DO CURSO, EM DIAS, BASEADO NO DOBRO DO TEMPO DAS VIDEOAULAS (CONSIDERA-SE QUE |--
--| UM ALUNO ASSISTE A MESMA VIDEOAULAS DUAS VEZES AO LONGO DO CURSO) E NO NÚMERO DE QUESTÕES       |--
--| (CONSIDERA-SE QUE O ALUNO RESPONDE A CADA QUESTÃO APENAS UMA VEZ E DEMORA 6 MINUTOS PARA SER    |--
--| RESPONDIDA), ISSO TUDO CONSIDERANDO QUE O ALUNO DEDICA NO MÍNIMO 1 HORA DE ESTUDO POR DIA.      |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO CURSO.                                                                 |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [INT] DURAÇÃO DO CURSO, EM DIAS.                                                         |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION CALCULAR_DURACAO_CURSO(CODIGO_CURSO INT)
RETURNS INT
AS $$
DECLARE
	REGISTRO_DISCIPLINA_DO_CURSO RECORD;
	REGISTRO_VIDEOAULA_DO_CURSO RECORD;
	REGISTRO_QUESTAO_DO_CURSO RECORD;
	
	QTD_TEMPO_VIDEOS_DO_CURSO_TOTAL INT := 0;
	NUM_QUESTOES_DO_CURSO_TOTAL INT := 0;

	DURACAO_CALCULADA INT;
BEGIN
	FOR REGISTRO_DISCIPLINA_DO_CURSO IN (SELECT * FROM DISCIPLINA D_C
	                                    INNER JOIN MODULO M_D ON D_C.COD_MODULO = M_D.COD_MODULO
	                                    WHERE M_D.COD_CURSO = CODIGO_CURSO) LOOP
		FOR REGISTRO_VIDEOAULA_DO_CURSO IN (SELECT * FROM VIDEO_AULA WHERE COD_DISCIPLINA = REGISTRO_DISCIPLINA_DO_CURSO.COD_DISCIPLINA) LOOP
			QTD_TEMPO_VIDEOS_DO_CURSO_TOTAL := QTD_TEMPO_VIDEOS_DO_CURSO_TOTAL + REGISTRO_VIDEOAULA_DO_CURSO.DURACAO;

		END LOOP;

		FOR REGISTRO_QUESTAO_DO_CURSO IN (SELECT * FROM QUESTAO WHERE COD_DISCIPLINA = REGISTRO_DISCIPLINA_DO_CURSO.COD_DISCIPLINA) LOOP
			NUM_QUESTOES_DO_CURSO_TOTAL := NUM_QUESTOES_DO_CURSO_TOTAL + 1;

		END LOOP;
		
	END LOOP;

	DURACAO_CALCULADA := TRUNC(((QTD_TEMPO_VIDEOS_DO_CURSO_TOTAL * 2) + (NUM_QUESTOES_DO_CURSO_TOTAL * 6)) / 60);

	IF (((QTD_TEMPO_VIDEOS_DO_CURSO_TOTAL * 2) + (NUM_QUESTOES_DO_CURSO_TOTAL * 6)) % 60) != 0 THEN
		DURACAO_CALCULADA = DURACAO_CALCULADA + 1;
	END IF;

	RETURN DURACAO_CALCULADA;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ################################### VALIDAR_DISCIPLINA ################################## ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| VERIFICA SE A DISCIPLINA É VÁLIDA (POSSUI 3 VIDEOAULAS).                                        |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DA DISCIPLINA.                                                            |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [BOOLEAN] BOOLEANO SOBRE A DISCIPLINA SER VÁLIDA.                                        |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION VALIDAR_DISCIPLINA(CODIGO_DISCIPLINA INT)
RETURNS BOOLEAN
AS $$
DECLARE
	NUM_VIDEOS INT := (SELECT COUNT(*) FROM VIDEO_AULA V_A WHERE V_A.COD_DISCIPLINA = CODIGO_DISCIPLINA);
BEGIN
	IF NUM_VIDEOS >= 3 THEN
		RETURN TRUE;

	ELSE
		RETURN FALSE;

	END IF;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- #################################### VALIDAR_MODULO ##################################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| VERIFICA SE O MÓDULO É VÁLIDO (POSSUI 3 DISCIPLINAS VÁLIDAS).                                   |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO MÓDULO.                                                                |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [BOOLEAN] BOOLEANO SOBRE O MÓDULO SER VÁLIDO.                                            |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION VALIDAR_MODULO(CODIGO_MODULO INT)
RETURNS BOOLEAN
AS $$
DECLARE
	NUM_DISCIPLINAS_VALIDAS INT := 0;
	REGISTRO_DISCIPLINA RECORD;
BEGIN
	FOR REGISTRO_DISCIPLINA IN (SELECT * FROM DISCIPLINA D_P WHERE D_P.COD_MODULO = CODIGO_MODULO) LOOP
		IF VALIDAR_DISCIPLINA(REGISTRO_DISCIPLINA.COD_DISCIPLINA) = TRUE THEN
		    NUM_DISCIPLINAS_VALIDAS := NUM_DISCIPLINAS_VALIDAS + 1;

		END IF;

	END LOOP;
	   
	IF NUM_DISCIPLINAS_VALIDAS >= 3 THEN
		RETURN TRUE;

	ELSE
		RETURN FALSE;

	END IF;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ##################################### VALIDAR_CURSO ##################################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| VERIFICA SE O CURSO É VÁLIDO (POSSUI 3 MÓDULOS VÁLIDOS).                                        |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO CURSO.                                                                 |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [BOOLEAN] BOOLEANO SOBRE O CURSO SER VÁLIDO.                                             |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION VALIDAR_CURSO(CODIGO_CURSO INT)
RETURNS BOOLEAN
AS $$
DECLARE
	NUM_MODULOS_VALIDOS INT := 0;
	REGISTRO_MODULO RECORD;
BEGIN
	FOR REGISTRO_MODULO IN (SELECT * FROM MODULO M_D WHERE M_D.COD_CURSO = CODIGO_CURSO) LOOP
		IF VALIDAR_MODULO(REGISTRO_MODULO.COD_MODULO) = TRUE THEN
			NUM_MODULOS_VALIDOS := NUM_MODULOS_VALIDOS + 1;

		END IF;

	END LOOP;

	IF NUM_MODULOS_VALIDOS >= 3 THEN
		RETURN TRUE;

	ELSE
		RETURN FALSE;

	END IF;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ######################## CONFIGURAR_ACESSIBILIDADE_ALUNO_MODULO ######################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CONFIGURA A ACESSABILIDADE DE UM ALUNO_MODULO, ADICIONANDO UM ALUNO_MODULO PARA CADA MÓDULO DO  |--
--| CURSO. A ACESSABILIDADE É CONFIGURADA COMO TRUE PARA OS MÓDULOS QUE NÃO POSSUEM PRÉ-REQUISITOS. |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO ALUNO; [INT] CÓDIGO DO CURSO.                                          |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION CONFIGURAR_ACESSIBILIDADE_ALUNO_MODULO(CODIGO_ALUNO INT, CODIGO_CURSO INT)
RETURNS VOID
AS $$
DECLARE
	REGISTRO_MODULO RECORD;
BEGIN
	FOR REGISTRO_MODULO IN (SELECT * FROM MODULO WHERE COD_CURSO = CODIGO_CURSO) LOOP
		IF (SELECT COD_MODULO FROM PRE_REQUISITO WHERE COD_MODULO = REGISTRO_MODULO.COD_MODULO) IS NULL THEN
			INSERT INTO ALUNO_MODULO VALUES (DEFAULT, TRUE, FALSE, CODIGO_ALUNO, REGISTRO_MODULO.COD_MODULO);

		ELSE
			INSERT INTO ALUNO_MODULO VALUES (DEFAULT, FALSE, FALSE, CODIGO_ALUNO, REGISTRO_MODULO.COD_MODULO);

		END IF;
		
	END LOOP;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ############################# QUANTIDADE_VIDEOS_ASSISTIDOS ############################## ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CÁLCULA A QUANTIDADE DE VÍDEOS ASSISTIDOS EM UM MÓDULO POR UM ALUNO.                            |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO ALUNO; [INT] CÓDIGO DO MÓDULO.                                         |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [INT] QUANTIDADE DE VÍDEOS ASSISTIDOS EM UM MÓDULO.                                      |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION QUANTIDADE_VIDEOS_ASSISTIDOS(CODIGO_ALUNO INT, CODIGO_MODULO INT)
RETURNS INT
AS $$
DECLARE
	REGISTRO_VIDEO_ASSISTIDO RECORD;
	QUANTIDADE INT := 0;
BEGIN
	SELECT COUNT(*) INTO QUANTIDADE FROM ALUNO_VIDEO_ASSISTIDO A_V_A INNER JOIN VIDEO_AULA V_A ON A_V_A.COD_VIDEO_AULA = V_A.COD_VIDEO_AULA
	INNER JOIN DISCIPLINA D_C ON V_A.COD_DISCIPLINA = D_C.COD_DISCIPLINA WHERE A_V_A.COD_ALUNO = CODIGO_ALUNO AND D_C.COD_MODULO = CODIGO_MODULO;
	
	RETURN QUANTIDADE;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ############################### QUANTIDADE_VIDEOS_MODULO ################################ ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CÁLCULA A QUANTIDADE DE VÍDEOS TOTAL DE UM MÓDULO.                                              |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO MÓDULO.                                                                |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [INT] QUANTIDADE DE VÍDEOS TOTAL DE UM MÓDULO.                                           |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION QUANTIDADE_VIDEOS_MODULO(CODIGO_MODULO INT)
RETURNS INT
AS $$
DECLARE
	QTD_VIDEOS_MODULO INT;
BEGIN
	SELECT COUNT(*) INTO QTD_VIDEOS_MODULO FROM VIDEO_AULA V_D WHERE V_D.COD_DISCIPLINA IN
	       (SELECT COD_DISCIPLINA FROM DISCIPLINA D_C WHERE D_C.COD_MODULO = CODIGO_MODULO);
	   
	RETURN QTD_VIDEOS_MODULO;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ###################### VERIFICAR_SUFICIENTE_ASSISTIDO_PARA_AVALIAR ###################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| VERIFICA SE O ALUNO ASSISTIU UMA QUANTIDADE DE VIDEOAULAS E UMA QUANTIDADE DE TEMPO SUFICIENTE  |--
--| PARA PODER AVALIAR O CURSO (CONSIDERAMOS TER ASSISTIDO 10% DO NÚMERO DE VÍDEOAULAS E 15% DO     |--
--| TEMPO DE VÍDEOAULAS COMO O MÍNIMO PARA ISSO).                                                   |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO ALUNO; [INT] CÓDIGO DO CURSO.                                          |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [BOOLEAN] BOOLEANO SOBRE O ALUNO PODER AVALIAR O CURSO.                                  |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

/* ASSISTIR VIDEOS */
CREATE OR REPLACE FUNCTION VERIFICAR_SUFICIENTE_ASSISTIDO_PARA_AVALIAR(CODIGO_ALUNO INT, CODIGO_CURSO INT)
RETURNS BOOLEAN
AS $$
DECLARE
	REGISTRO_VIDEOAULA_DO_CURSO RECORD;

	NUM_VIDEOS_DO_CURSO_TOTAL INT := 0;
	NUM_VIDEOS_DO_CURSO_ASSISTIDOS INT := 0;
	
	QTD_TEMPO_VIDEOS_DO_CURSO_TOTAL INT := 0;
	QTD_TEMPO_VIDEOS_DO_CURSO_ASSISTIDOS INT := 0;

	PORCENTAGEM_NUM_VIDEOS FLOAT;
	PORCENTAGEM_QTD_TEMPO FLOAT;
BEGIN
	FOR REGISTRO_VIDEOAULA_DO_CURSO IN (SELECT COD_VIDEO_AULA, V_D.DURACAO FROM VIDEO_AULA V_D
	                                    INNER JOIN DISCIPLINA D_C ON V_D.COD_DISCIPLINA = D_C.COD_DISCIPLINA
	                                    INNER JOIN MODULO M_D ON D_C.COD_MODULO = M_D.COD_MODULO
	                                    WHERE M_D.COD_CURSO = CODIGO_CURSO) LOOP
		NUM_VIDEOS_DO_CURSO_TOTAL := NUM_VIDEOS_DO_CURSO_TOTAL + 1;
		QTD_TEMPO_VIDEOS_DO_CURSO_TOTAL := QTD_TEMPO_VIDEOS_DO_CURSO_TOTAL + REGISTRO_VIDEOAULA_DO_CURSO.DURACAO;

		IF ALUNO_JA_ASSISTIU(CODIGO_ALUNO, REGISTRO_VIDEOAULA_DO_CURSO.COD_VIDEO_AULA) IS TRUE THEN
			NUM_VIDEOS_DO_CURSO_ASSISTIDOS = NUM_VIDEOS_DO_CURSO_ASSISTIDOS + 1;
			QTD_TEMPO_VIDEOS_DO_CURSO_ASSISTIDOS = QTD_TEMPO_VIDEOS_DO_CURSO_ASSISTIDOS + REGISTRO_VIDEOAULA_DO_CURSO.DURACAO;
			
		END IF;
		
	END LOOP;

	PORCENTAGEM_NUM_VIDEOS = (SELECT TRUNC((NUM_VIDEOS_DO_CURSO_ASSISTIDOS::DECIMAL / NUM_VIDEOS_DO_CURSO_TOTAL::DECIMAL), 2));
	PORCENTAGEM_QTD_TEMPO = (SELECT TRUNC((QTD_TEMPO_VIDEOS_DO_CURSO_ASSISTIDOS::DECIMAL / QTD_TEMPO_VIDEOS_DO_CURSO_TOTAL::DECIMAL), 2));

	IF PORCENTAGEM_NUM_VIDEOS < 0.15 OR PORCENTAGEM_QTD_TEMPO < 0.1 THEN
		RETURN FALSE;

	END IF;

	RETURN TRUE;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ######################### VERIFICAR_SE_MODULOS_FICAM_ACESSIVEIS ######################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| TORNA ACESSIVEL ALGUM(NS) MÓDULO(S) QUE POSSUEM, COMO PRÉ-REQUISITO O MÓDULO PASSADO, FICANDO   |--
--| ELE(S) ACESSÍVEL(IS) NO ALUNO_MODULO.                                                           |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO MODULO (QUE DEVE TER FICADO COM A META_CONCLUIDA ANTES DE EXECUTAR     |--
--| ESSA FUNÇÃO) QUE PODE SER PRÉ-REQUISITO PARA OUTROS MÓDULOS; CÓDIGO DO ALUNO QUE IRÁ PASSAR A   |--
--| TER SEUS MÓDULOS ACESSÍVEIS.                                                                    |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION VERIFICAR_SE_MODULOS_FICAM_ACESSIVEIS(COD_MODULO_ALUNO_MODULO INT, CODIGO_ALUNO INT)
RETURNS VOID
AS $$
DECLARE
	MODULO_FICAR_ACESSIVEL BOOLEAN;
	MODULO_PRE_REQUISITO_ANALISADO RECORD;
	ALUNO_MODULO_VERIFICADO RECORD;
BEGIN
	
	FOR MODULO_PRE_REQUISITO_ANALISADO IN (SELECT * FROM PRE_REQUISITO WHERE COD_MODULO_PRE_REQUISITO = COD_MODULO_ALUNO_MODULO) LOOP
		MODULO_FICAR_ACESSIVEL := TRUE;

		FOR ALUNO_MODULO_VERIFICADO IN (SELECT * FROM ALUNO_MODULO WHERE COD_MODULO IN (SELECT COD_MODULO_PRE_REQUISITO
		FROM PRE_REQUISITO WHERE COD_MODULO = MODULO_PRE_REQUISITO_ANALISADO.COD_MODULO) AND COD_ALUNO = CODIGO_ALUNO) LOOP

			IF ALUNO_MODULO_VERIFICADO.META_CONCLUIDA IS FALSE THEN
				MODULO_FICAR_ACESSIVEL := FALSE;
				
			END IF;

		END LOOP;

		IF MODULO_FICAR_ACESSIVEL IS TRUE THEN
			UPDATE ALUNO_MODULO SET ACESSIVEL = TRUE WHERE COD_MODULO = MODULO_PRE_REQUISITO_ANALISADO.COD_MODULO AND COD_ALUNO = CODIGO_ALUNO;
			
		END IF;

	END LOOP;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ########################### VERIFICAR_VALIDADE_PRE_REQUISITO ############################ ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| VERIFICA SE É VÁLIDO RELACIONAR UM MÓDULO COM OUTRO NA TABELA PRÉ-REQUISITO. OU SEJA, OS        |--
--| MÓDULOS NÃO DEVEM ENTRAR EM UM ESTADO EM QUE UM NÃO CONSIGA ACESSAR O OUTRO E VICE-VERSA POIS   |--
--| ELES TÊM UM AO OUTRO COMO PRÉ-REQUISITO (IMPASSE DE PRÉ-REQUISITO ENTRE MÓDULOS).               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DO MODULO QUE SERÁ O MÓDULO NO PRÉ-REQUISITO; [INT] CÓDIGO DO MODULO QUE  |--
--| SERÁ O MÓDULO PRÉ-REQUISITO NO PRÉ-REQUISITO.                                                   |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [BOOLEAN] BOOLEANO SOBRE A POSSIBILIDADE DOS MÓDULOS SE ASSOCIAREM ENTRE SI NA TABELA DE |--
--| PRÉ-REQUISITOS.                                                                                 |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

-- <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>< --
----- <<><><><><><><><><><><><><>>  OBRIGADÃO PELO CÓDIGO, LUAN! :D  <<><><><><><><><><><><><><>> -----
-- <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>< --

CREATE OR REPLACE FUNCTION VERIFICAR_VALIDADE_PRE_REQUISITO(CODIGO_MODULO INT, CODIGO_MODULO_PRE_REQUISITO INT)
RETURNS BOOLEAN
AS $$
DECLARE
	REGISTRO_COD_MODULO_PRE_REQUISITO RECORD;
BEGIN
	IF CODIGO_MODULO IN (SELECT COD_MODULO_PRE_REQUISITO FROM PRE_REQUISITO WHERE COD_MODULO = CODIGO_MODULO_PRE_REQUISITO) THEN
		RETURN FALSE;
		
	ELSE
		FOR REGISTRO_COD_MODULO_PRE_REQUISITO IN (SELECT COD_MODULO_PRE_REQUISITO FROM PRE_REQUISITO WHERE COD_MODULO = CODIGO_MODULO_PRE_REQUISITO) LOOP
			IF VERIFICAR_VALIDADE_PRE_REQUISITO(CODIGO_MODULO, REGISTRO_COD_MODULO_PRE_REQUISITO.COD_MODULO_PRE_REQUISITO) IS FALSE THEN
				RETURN FALSE;
				
			END IF;
			
		END LOOP;
		
		RETURN TRUE;
		
	END IF;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ############################# VERIFICAR_MODULOS_MESMO_CURSO ############################# ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| VERIFICA SE DOIS MÓDULOS PERTENCEM AO MESMO CURSO.                                              |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| ENTRADA: [INT] CÓDIGO DE UM MODULO; [INT] CÓDIGO DE OUTRO MÓDULO.                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [BOOLEAN] BOOLEANO SOBRE OS MÓDULOS PERTENCEREM AO MESMO CURSO.                          |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION VERIFICAR_MODULOS_MESMO_CURSO(CODIGO_MODULO_1 INT, CODIGO_MODULO_2 INT)
RETURNS BOOLEAN
AS $$
BEGIN
	RETURN (SELECT COD_CURSO FROM MODULO WHERE COD_MODULO = CODIGO_MODULO_1) = (SELECT COD_CURSO FROM MODULO WHERE COD_MODULO = CODIGO_MODULO_2);
END
$$ LANGUAGE plpgsql;
