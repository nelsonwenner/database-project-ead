---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ############################################################################################################################################################### --
-- ##################################################################### CRIAÇÃO DAS TABELAS ##################################################################### --
-- ############################################################################################################################################################### --
--------------------------------------------------------------------------------------------------------------------------------------------------------------------- 


CREATE TABLE ALUNO
(
	COD_ALUNO SERIAL NOT NULL PRIMARY KEY,
	NOME VARCHAR(30) NOT NULL,
	CPF VARCHAR(11),
	DATA_NASCIMENTO DATE NOT NULL,
	EMAIL VARCHAR(30) NOT NULL,
	SENHA VARCHAR(30) NOT NULL,
	SALDO FLOAT DEFAULT 0
);

CREATE TABLE PROFESSOR
(
	COD_PROFESSOR SERIAL NOT NULL PRIMARY KEY,
	NOME VARCHAR(30) NOT NULL,
	CPF VARCHAR(11) NOT NULL,
	DATA_NASCIMENTO DATE NOT NULL,
	EMAIL VARCHAR(30) NOT NULL,
	SENHA VARCHAR(30) NOT NULL,
	SALDO FLOAT DEFAULT 0,
	DATA_ULTIMO_PAGAMENTO DATE DEFAULT NULL
);

CREATE TABLE CURSO
(
	COD_CURSO SERIAL NOT NULL PRIMARY KEY,
	NOME VARCHAR(60) NOT NULL,
	DESCRICAO VARCHAR(300),
	DURACAO INT DEFAULT 0,
	PRECO FLOAT,
	NUMERO_MODULOS INT DEFAULT 0,
	PUBLICADO BOOLEAN DEFAULT FALSE,
	DISPONIBILIDADE BOOLEAN DEFAULT FALSE,

	COD_PROFESSOR INT NOT NULL REFERENCES PROFESSOR(COD_PROFESSOR) ON DELETE CASCADE
);

CREATE TABLE ALUNO_CURSO
(
	COD_ALUNO_CURSO SERIAL NOT NULL PRIMARY KEY,
	DATA_COMPRA DATE,
	NOTA_AVALIACAO FLOAT,

	COD_ALUNO INT NOT NULL REFERENCES ALUNO(COD_ALUNO) ON DELETE CASCADE,
	COD_CURSO INT NOT NULL REFERENCES CURSO(COD_CURSO) ON DELETE CASCADE
);

CREATE TABLE MODULO
(
	COD_MODULO SERIAL NOT NULL PRIMARY KEY,
	NOME VARCHAR(100),
	DESCRICAO VARCHAR(300),

	COD_CURSO INT NOT NULL REFERENCES CURSO(COD_CURSO) ON DELETE CASCADE
);

CREATE TABLE ALUNO_MODULO
(
	COD_ALUNO_MODULO SERIAL NOT NULL PRIMARY KEY,
	ACESSIVEL BOOLEAN,
	META_CONCLUIDA BOOLEAN,

	COD_ALUNO INT NOT NULL REFERENCES ALUNO(COD_ALUNO) ON DELETE CASCADE,
	COD_MODULO INT NOT NULL REFERENCES MODULO(COD_MODULO) ON DELETE CASCADE
);

CREATE TABLE PRE_REQUISITO
(
	COD_PRE_REQUISITO SERIAL NOT NULL PRIMARY KEY,

	COD_MODULO INT NOT NULL REFERENCES MODULO(COD_MODULO) ON DELETE CASCADE,
	COD_MODULO_PRE_REQUISITO INT NOT NULL REFERENCES MODULO(COD_MODULO) ON DELETE CASCADE,

	UNIQUE (COD_PRE_REQUISITO, COD_MODULO) -- PAR DE VALORES ÚNICOS (1, 2), (2, 1), PORÉM (1, 2) NOVAMENTE NÃO PODE.
);

CREATE TABLE DISCIPLINA
(
	COD_DISCIPLINA SERIAL NOT NULL PRIMARY KEY,
	NOME VARCHAR(100),
	DESCRICAO VARCHAR(300),

	COD_MODULO INT NOT NULL REFERENCES MODULO(COD_MODULO) ON DELETE CASCADE
);

CREATE TABLE VIDEO_AULA
(
	COD_VIDEO_AULA SERIAL PRIMARY KEY,
	NOME VARCHAR(30) NOT NULL,
	DESCRICAO VARCHAR(300),
	DURACAO FLOAT,

	COD_DISCIPLINA INT NOT NULL REFERENCES DISCIPLINA(COD_DISCIPLINA) ON DELETE CASCADE
);

CREATE TABLE ALUNO_VIDEO_ASSISTIDO
(
	COD_ALUNO_VIDEO_ASSISTIDO SERIAL NOT NULL PRIMARY KEY,

	COD_ALUNO INT NOT NULL REFERENCES ALUNO(COD_ALUNO) ON DELETE CASCADE,
	COD_VIDEO_AULA INT NOT NULL REFERENCES VIDEO_AULA(COD_VIDEO_AULA) ON DELETE CASCADE
);

CREATE TABLE QUESTAO
(
	COD_QUESTAO SERIAL NOT NULL PRIMARY KEY,
	TEXTO VARCHAR(500),

	COD_DISCIPLINA INT NOT NULL REFERENCES DISCIPLINA(COD_DISCIPLINA) ON DELETE CASCADE
);

CREATE TABLE QUESTIONARIO
(
	COD_QUESTIONARIO SERIAL NOT NULL PRIMARY KEY,
	NOME VARCHAR(30),

	COD_DISCIPLINA INT NOT NULL REFERENCES DISCIPLINA(COD_DISCIPLINA) ON DELETE CASCADE
);

CREATE TABLE QUESTAO_QUESTIONARIO
(
	COD_QUESTAO_QUESTIONARIO SERIAL NOT NULL PRIMARY KEY,

	COD_QUESTAO INT NOT NULL REFERENCES QUESTAO(COD_QUESTAO) ON DELETE CASCADE,
	COD_QUESTIONARIO INT NOT NULL REFERENCES QUESTIONARIO(COD_QUESTIONARIO) ON DELETE CASCADE
);

CREATE TABLE QUESTAO_ALUNO
(
	COD_QUESTAO_ALUNO SERIAL NOT NULL PRIMARY KEY,
	RESPOSTA_ALUNO VARCHAR(500),
	RESPOSTA_CORRETA VARCHAR(13) DEFAULT 'NÃO ANALISADA',

	COD_QUESTAO INT NOT NULL REFERENCES QUESTAO(COD_QUESTAO),
	COD_ALUNO INT NOT NULL REFERENCES ALUNO(COD_ALUNO)
);




---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ############################################################################################################################################################### --
-- ########################################################################## FUNCTIONS ########################################################################## --
-- ############################################################################################################################################################### --
---------------------------------------------------------------------------------------------------------------------------------------------------------------------


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



---------------------------------------------------------------------------------------------------------------------------------------------------------------------
                      --        ####################################### FUNCTIONS DE TRIGGERS #######################################        --
                      -- ################################################################################################################### --
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

--|-------------------------------------------------------------------------------------------------|--
--|--- ########################### CONTROLAR_EVENTOS_USUARIO_BEFORE ############################ ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| FAZ CONTROLE SOBRE AS AÇÕES TOMADAS ANTES DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA  |--
--| ALUNO OU PROFESSOR.                                                                             |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: IDADE MENOR QUE 18; CPF JÁ REGISTRADO ANTERIORMENTE; EMAIL JÁ REGISTRADO     |--
--| ANTERIORMENTE; SALDO NEGATIVO; ALTERAÇÃO DE DATA DE NASCIMENTO; ALTERAÇÃO DO EMAIL.             |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [TRIGGER].                                                                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION CONTROLAR_EVENTOS_USUARIO_BEFORE()
RETURNS TRIGGER
AS $$
DECLARE
	IDADE INT;
BEGIN
	IF TG_OP = 'INSERT' THEN
		IDADE := RETORNA_IDADE(NEW.DATA_NASCIMENTO);
		IF IDADE < 18 THEN
			RAISE EXCEPTION 'VOCÊ É MENOR DE IDADE, CADASTRO REJEITADO!';
		 
		ELSIF VERIFICAR_CPF_USUARIO_JA_REGISTRADO(NEW.CPF, 'ALUNO') THEN
			RAISE EXCEPTION 'JÁ EXISTE UM ALUNO CADASTRADO COM ESSE CPF, INSIRA UM CPF VÁLIDO!';
		   
		ELSIF VERIFICAR_EMAIL_USUARIO_JA_REGISTRADO(NEW.EMAIL, 'ALUNO') THEN
			RAISE EXCEPTION 'ESSE EMAIL JÁ CONSTA EM UM CADASTRO ALUNO, INSIRA UM EMAIL VÁLIDO!';
		   
		ELSIF VERIFICAR_CPF_USUARIO_JA_REGISTRADO(NEW.CPF, 'PROFESSOR') THEN
			RAISE EXCEPTION 'JÁ EXISTE UM PROFESSOR CADASTRADO COM ESSE CPF, INSIRA UM CPF VÁLIDO!';
		   
		ELSIF VERIFICAR_EMAIL_USUARIO_JA_REGISTRADO(NEW.EMAIL, 'PROFESSOR') THEN
			RAISE EXCEPTION 'ESSE EMAIL JÁ CONSTA EM UM CADASTRO PROFESSOR, INSIRA UM EMAIL VÁLIDO!';

		ELSIF NEW.SALDO < 0 THEN
			RAISE EXCEPTION 'REGISTRAR UM SALDO NEGATIVO É UMA OPERAÇÃO INVÁLIDA!';

		END IF;

		RETURN NEW;
		
	ELSIF TG_OP = 'UPDATE' THEN
		IF OLD.DATA_NASCIMENTO != NEW.DATA_NASCIMENTO THEN
			RAISE EXCEPTION 'ALTERAR A DATA DE NASCIMENTO É UMA OPERAÇÃO INVÁLIDA!';

		ELSIF OLD.EMAIL != NEW.EMAIL THEN
			RAISE EXCEPTION 'ALTERAR O EMAIL É UMA OPERAÇÃO INVÁLIDA!';

		ELSIF NEW.SALDO < 0 THEN
			RAISE EXCEPTION 'REGISTRAR UM SALDO NEGATIVO É UMA OPERAÇÃO INVÁLIDA!';
		
		END IF;

		RETURN NEW;
		
	ELSIF TG_OP = 'DELETE' THEN
		RETURN OLD;

	END IF;

	RETURN NULL;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ############################# CONTROLAR_EVENTOS_ALUNO_AFTER ############################# ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| FAZ CONTROLE SOBRE AS AÇÕES TOMADAS DEPOIS DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA |--
--| ALUNO. AÇÕES: CRIAR UM NOVO USUÁRIO NO GRUPO ALUNO (LOGIN ROLE); ATUALIZAR A SENHA DO USUÁRIO   |--
--| (LOGIN ROLE); DELETAR USUÁRIO (LOGIN ROLE).                                                     |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [TRIGGER].                                                                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION CONTROLAR_EVENTOS_ALUNO_AFTER()
RETURNS TRIGGER
AS $$
BEGIN
	IF TG_OP = 'INSERT' THEN
		EXECUTE FORMAT('CREATE USER "%s" LOGIN PASSWORD ''%s'' IN GROUP ALUNO', NEW.EMAIL, NEW.SENHA);
		
		RETURN NEW;
		
	ELSIF TG_OP = 'UPDATE' THEN
		IF OLD.SENHA != NEW.SENHA THEN
			EXECUTE FORMAT('ALTER USER "%s" PASSWORD ''%s''', NEW.EMAIL, NEW.SENHA);

		END IF;

		RETURN NEW;
		
	ELSIF TG_OP = 'DELETE' THEN
		EXECUTE FORMAT('DROP USER "%s"', OLD.EMAIL);

		RETURN OLD;

	END IF;

	RETURN NULL;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ########################### CONTROLAR_EVENTOS_PROFESSOR_AFTER ########################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| FAZ CONTROLE SOBRE AS AÇÕES TOMADAS DEPOIS DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA |--
--| PROFESSOR. AÇÕES: CRIAR UM NOVO USUÁRIO NO GRUPO PROFESSOR (LOGIN ROLE); ATUALIZAR A SENHA DO   |--
--| USUÁRIO (LOGIN ROLE); DELETAR USUÁRIO (LOGIN ROLE).                                             |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [TRIGGER].                                                                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION CONTROLAR_EVENTOS_PROFESSOR_AFTER()
RETURNS TRIGGER
AS $$
BEGIN
	IF TG_OP = 'INSERT' THEN
		EXECUTE FORMAT('CREATE USER "%s" LOGIN PASSWORD ''%s'' IN GROUP PROFESSOR', NEW.EMAIL, NEW.SENHA);
		
		RETURN NEW;
		
	ELSIF TG_OP = 'UPDATE' THEN
		IF OLD.SENHA != NEW.SENHA THEN
			EXECUTE FORMAT('ALTER USER "%s" PASSWORD ''%s''', NEW.EMAIL, NEW.SENHA);

		END IF;

		RETURN NEW;
		
	ELSIF TG_OP = 'DELETE' THEN
		EXECUTE FORMAT('DROP USER "%s"', OLD.EMAIL);

		RETURN OLD;

	END IF;

	RETURN NULL;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ############################ CONTROLAR_EVENTOS_CURSO_BEFORE ############################# ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| FAZ CONTROLE SOBRE AS AÇÕES TOMADAS ANTES DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA  |--
--| CURSO. AÇÕES: CALCULAR DURAÇÃO DO CURSO CASO NECESSÁRIO.                                        |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: CÓDIGO DE PROFESSOR INVÁLIDO; CURSO SER PUBLICADO SEM TER DISPONIBILIDADE;   |--
--| CÓDIGO DE CURSO INVÁLIDO.                                                                       |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [TRIGGER].                                                                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION CONTROLAR_EVENTOS_CURSO_BEFORE()
RETURNS TRIGGER
AS $$
BEGIN
	IF TG_OP = 'INSERT' THEN
		IF VERIFICAR_SE_REGISTRO_EXISTE(NEW.COD_PROFESSOR, 'PROFESSOR') IS FALSE THEN
			RAISE EXCEPTION 'ESSE PROFESSOR NÃO EXISTE, INSIRA UM COD_PROFESSOR VÁLIDO!';

		ELSIF NEW.PUBLICADO = TRUE THEN
			IF NEW.DISPONIBILIDADE = FALSE THEN
				RAISE EXCEPTION 'O CURSO NÃO PODE FICAR PUBLICADO SEM ESTAR COM DISPONIBILIDADE! ANTES DE PUBLICAR ATENDA AOS REQUISITOS!';

			END IF;
			
			NEW.DURACAO := CALCULAR_DURACAO_CURSO(NEW.COD_CURSO);

		END IF;

		RETURN NEW;

	ELSIF TG_OP = 'UPDATE' THEN
		IF VERIFICAR_SE_REGISTRO_EXISTE(NEW.COD_CURSO, 'CURSO') IS FALSE THEN
			RAISE EXCEPTION 'ESSE CURSO NÃO EXISTE, INSIRA UM COD_CURSO VÁLIDO!';

		ELSIF VERIFICAR_SE_REGISTRO_EXISTE(NEW.COD_PROFESSOR, 'PROFESSOR') IS FALSE THEN
			RAISE EXCEPTION 'ESSE PROFESSOR NÃO EXISTE, INSIRA UM COD_PROFESSOR VÁLIDO!';
			
		ELSIF NOT(VERIFICAR_SE_ALTEROU_APENAS_PUBLICADO(OLD.COD_CURSO, NEW.COD_CURSO,
		                                                OLD.NOME, NEW.NOME,
		                                                OLD.DESCRICAO, NEW.DESCRICAO,
		                                                OLD.DURACAO, NEW.DURACAO,
		                                                OLD.PRECO, NEW.PRECO,
		                                                OLD.NUMERO_MODULOS, NEW.NUMERO_MODULOS,
		                                                OLD.DISPONIBILIDADE, NEW.DISPONIBILIDADE,
		                                                OLD.COD_PROFESSOR, NEW.COD_PROFESSOR)) THEN
			PERFORM VERIFICAR_POSSIBILIDADE_DELETE_UPDATE_NO_CURSO(NEW.COD_CURSO);
		
		ELSIF NEW.PUBLICADO = TRUE THEN
			IF NEW.DISPONIBILIDADE = FALSE THEN
				RAISE EXCEPTION 'O CURSO NÃO PODE FICAR PUBLICADO SEM ESTAR COM DISPONIBILIDADE! ANTES DE PUBLICAR ATENDA AOS REQUISITOS!';

			END IF;
			
			NEW.DURACAO := CALCULAR_DURACAO_CURSO(NEW.COD_CURSO);

		END IF;

		RETURN NEW;
		
	ELSIF TG_OP = 'DELETE' THEN
		
		PERFORM VERIFICAR_POSSIBILIDADE_DELETE_UPDATE_NO_CURSO(OLD.COD_CURSO);

		RETURN OLD;

	END IF;

	RETURN NULL;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ######################### CONTROLAR_EVENTOS_ALUNO_CURSO_BEFORE ########################## ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| FAZ CONTROLE SOBRE AS AÇÕES TOMADAS ANTES DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA  |--
--| ALUNO_CURSO. AÇÕES: APLICAR A COBRANÇA PELA COMPRA DO CURSO.                                    |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: CÓDIGO DE ALUNO INVÁLIDO; CÓDIGO DE CURSO INVÁLIDO; CURSO NÃO PUBLICADO;     |--
--| ALUNO ENVOLVIDO NAS ALTERAÇÕES NÃO ESTAR CURSANDO; NÃO TER ASSISTIDO VIDEOAULAS O SUFICIENTE    |--
--| PARA PODER AVALIAR O CURSO; TER UMA NOTA DE AVALIAÇÃO FORA DO INTERVALO 0~5.                    |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [TRIGGER].                                                                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION CONTROLAR_EVENTOS_ALUNO_CURSO_BEFORE()
RETURNS TRIGGER
AS $$
BEGIN
	IF TG_OP = 'INSERT' THEN
		IF VERIFICAR_SE_REGISTRO_EXISTE(NEW.COD_ALUNO, 'ALUNO') IS FALSE THEN
			RAISE EXCEPTION 'ESSE ALUNO NÃO EXISTE, INSIRA UM COD_ALUNO VÁLIDO!';
		
		ELSIF VERIFICAR_SE_REGISTRO_EXISTE(NEW.COD_CURSO, 'CURSO') IS FALSE THEN
			RAISE EXCEPTION 'ESSE CURSO NÃO EXISTE, INSIRA UM COD_CURSO VÁLIDO!';
		
		ELSIF ALUNO_AINDA_CURSANDO(NEW.COD_ALUNO, NEW.COD_CURSO) IS TRUE THEN
			RAISE EXCEPTION 'VOCÊ AINDA ESTÁ CURSANDO ESSE CURSO. COMPRA DO CURSO REJEITADA!';
		 
		ELSIF CURSO_DISPONIVEL(NEW.COD_CURSO) != TRUE THEN
			RAISE EXCEPTION 'CURSO INDISPONÍVEL PARA NOVAS COMPRAS. O CURSO DEVE TER SIDO PUBLICADO PARA SER COMPRADO!';

		END IF;

		PERFORM ATUALIZAR_SALDO(-SELECIONAR_PRECO(NEW.COD_CURSO), NEW.COD_ALUNO, 'ALUNO');
		
		RETURN NEW;
		
	ELSIF TG_OP = 'UPDATE' THEN
		-- SE CAIR NESSE CASO SIGNIFICA QUE O ALUNO NÃO COMPROU NOVAMENTE O CURSO, ELE SIMPLISMENTE ALTEROU ALGUM DADO.
		IF OLD.DATA_COMPRA = NEW.DATA_COMPRA THEN
			IF ALUNO_AINDA_CURSANDO(NEW.COD_ALUNO, NEW.COD_CURSO) != TRUE THEN
				RAISE EXCEPTION 'CURSO INDISPONÍVEL PARA MUDANÇAS. O ALUNO REFERENCIADO DEVE ESTAR CURSANDO O CURSO PARA REALIZAR ALTERAÇÕES!';
			
			ELSIF OLD.NOTA_AVALIACAO != NEW.NOTA_AVALIACAO THEN
				IF VERIFICAR_SUFICIENTE_ASSISTIDO_PARA_AVALIAR(NEW.COD_ALUNO, NEW.COD_CURSO) IS FALSE THEN
					RAISE EXCEPTION 'PARA AVALIAR O CURSO, É PRECISO TER ASSISTIDO 15%% DAS VIDEOAULAS E 10%% DO TEMPO TOTAL DE VIDEOAULAS!';

				ELSIF NEW.NOTA_AVALIACAO < 0 OR NEW.NOTA_AVALIACAO > 5 THEN
					RAISE EXCEPTION 'A NOTA DE AVALIAÇÃO DEVE ESTAR ENTRE 0 E 5!';

				END IF;

			END IF;

		ELSE
			PERFORM ATUALIZAR_SALDO(-SELECIONAR_PRECO(NEW.COD_CURSO), NEW.COD_ALUNO, 'ALUNO');

		END IF;

		RETURN NEW;
		
	ELSIF TG_OP = 'DELETE' THEN
		RETURN OLD;

	END IF;

	RETURN NULL;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ########################## CONTROLAR_EVENTOS_ALUNO_CURSO_AFTER ########################## ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| FAZ CONTROLE SOBRE AS AÇÕES TOMADAS DEPOIS DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA |--
--| ALUNO_CURSO. AÇÕES: FAZER O PROFESSOR RECEBER O SALÁRIO, CONFIGURAR O ALUNO_MODULO, TORNANDO    |--
--| MÓDULOS ACESSÍVEIS OU NÃO PARA O ALUNO.                                                         |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [TRIGGER].                                                                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION CONTROLAR_EVENTOS_ALUNO_CURSO_AFTER()
RETURNS TRIGGER
AS $$
BEGIN
	IF TG_OP = 'INSERT' THEN
		PERFORM RECEBER_SALARIO(
			(SELECT P_F.COD_PROFESSOR FROM ALUNO_CURSO A_C
			INNER JOIN CURSO C_R ON A_C.COD_CURSO = C_R.COD_CURSO
			INNER JOIN PROFESSOR P_F ON C_R.COD_PROFESSOR = P_F.COD_PROFESSOR
			WHERE A_C.COD_ALUNO_CURSO = NEW.COD_ALUNO_CURSO)
		);
		
		PERFORM CONFIGURAR_ACESSIBILIDADE_ALUNO_MODULO(NEW.COD_ALUNO, NEW.COD_CURSO);
		
		RETURN NEW;
		
	ELSIF TG_OP = 'UPDATE' THEN
		PERFORM RECEBER_SALARIO(
			(SELECT P_F.COD_PROFESSOR FROM ALUNO_CURSO A_C
			INNER JOIN CURSO C_R ON A_C.COD_CURSO = C_R.COD_CURSO
			INNER JOIN PROFESSOR P_F ON C_R.COD_PROFESSOR = P_F.COD_PROFESSOR
			WHERE A_C.COD_ALUNO_CURSO = NEW.COD_ALUNO_CURSO)
		);
		
		RETURN NEW;
		
	ELSIF TG_OP = 'DELETE' THEN
		RETURN OLD;

	END IF;

	RETURN NULL;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ############################ CONTROLAR_EVENTOS_MODULO_BEFORE ############################ ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| FAZ CONTROLE SOBRE AS AÇÕES TOMADAS ANTES DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA  |--
--| MÓDULO.                                                                                         |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: CÓDIGO DE CURSO INVÁLIDO.                                                    |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [TRIGGER].                                                                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION CONTROLAR_EVENTOS_MODULO_BEFORE()
RETURNS TRIGGER
AS $$
BEGIN
	IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
		IF VERIFICAR_SE_REGISTRO_EXISTE(NEW.COD_CURSO, 'CURSO') IS FALSE THEN
			RAISE EXCEPTION 'ESSE CURSO NÃO EXISTE, INSIRA UM COD_CURSO VÁLIDO!';

		END IF;

		PERFORM VERIFICAR_POSSIBILIDADE_DELETE_UPDATE_NO_CURSO(NEW.COD_CURSO);

		RETURN NEW;

	ELSIF TG_OP = 'DELETE' THEN
		PERFORM VERIFICAR_POSSIBILIDADE_DELETE_UPDATE_NO_CURSO(OLD.COD_CURSO);
		
		RETURN OLD;

	END IF;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ############################ CONTROLAR_EVENTOS_MODULO_AFTER ############################# ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| FAZ CONTROLE SOBRE AS AÇÕES TOMADAS DEPOIS DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA |--
--| MÓDULO. AÇÕES: INCREMENTAR/DECREMENTAR O NÚMERO DE MÓDULOS; ATUALIZAR O PUBLICADO E A           |--
--| DISPONIBILIDADE DO CURSO CASO NECESSÁRIO.                                                       |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [TRIGGER].                                                                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION CONTROLAR_EVENTOS_MODULO_AFTER()
RETURNS TRIGGER
AS $$
BEGIN
	IF TG_OP = 'INSERT' THEN
		PERFORM INCREMENTAR_NUMERO_MODULOS(NEW.COD_CURSO, 1);

		RETURN NEW;
		
	ELSIF TG_OP = 'UPDATE' THEN
		IF OLD.COD_CURSO != NEW.COD_CURSO THEN
			IF VALIDAR_CURSO(OLD.COD_CURSO) = FALSE THEN
				UPDATE CURSO SET PUBLICADO = FALSE WHERE COD_CURSO = OLD.COD_CURSO;
				UPDATE CURSO SET DISPONIBILIDADE = FALSE WHERE COD_CURSO = OLD.COD_CURSO;

			END IF;

			IF VALIDAR_CURSO(NEW.COD_CURSO) = TRUE THEN
				UPDATE CURSO SET DISPONIBILIDADE = TRUE WHERE COD_CURSO = NEW.COD_CURSO;

			END IF;
			
			PERFORM INCREMENTAR_NUMERO_MODULOS(OLD.COD_CURSO, -1);
			PERFORM INCREMENTAR_NUMERO_MODULOS(NEW.COD_CURSO, 1);
		END IF;

		RETURN NEW;
		
	ELSIF TG_OP = 'DELETE' THEN
		PERFORM INCREMENTAR_NUMERO_MODULOS(OLD.COD_CURSO, -1);
		
		IF VALIDAR_CURSO(OLD.COD_CURSO) = FALSE THEN
			UPDATE CURSO SET PUBLICADO = FALSE WHERE COD_CURSO = OLD.COD_CURSO;
			UPDATE CURSO SET DISPONIBILIDADE = FALSE WHERE COD_CURSO = OLD.COD_CURSO;

		END IF;

		RETURN OLD;
		
	END IF;
	
	RETURN NULL;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ######################### CONTROLAR_EVENTOS_ALUNO_MODULO_BEFORE ######################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| FAZ CONTROLE SOBRE AS AÇÕES TOMADAS DEPOIS DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA |--
--| ALUNO_MODULO.                                                                                   |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: CÓDIGO DE ALUNO INVÁLIDO; CÓDIGO DE MÓDULO INVÁLIDO; ALUNO ENVOLVIDO NAS     |--
--| ALTERAÇÕES NÃO ESTAR CURSANDO;                                                                  |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [TRIGGER].                                                                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION CONTROLAR_EVENTOS_ALUNO_MODULO_BEFORE()
RETURNS TRIGGER
AS $$
DECLARE
	CODIGO_CURSO INT;
BEGIN
	IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
		SELECT COD_CURSO INTO CODIGO_CURSO FROM MODULO WHERE COD_MODULO = NEW.COD_MODULO;

		IF VERIFICAR_SE_REGISTRO_EXISTE(NEW.COD_ALUNO, 'ALUNO') IS FALSE THEN
			RAISE EXCEPTION 'ESSE ALUNO NÃO EXISTE, INSIRA UM COD_ALUNO VÁLIDO!';

		ELSIF VERIFICAR_SE_REGISTRO_EXISTE(NEW.COD_MODULO, 'MODULO') IS FALSE THEN
			RAISE EXCEPTION 'ESSE MODULO NÃO EXISTE, INSIRA UM COD_MODULO VÁLIDO!';
			
		ELSIF ALUNO_AINDA_CURSANDO(NEW.COD_ALUNO, CODIGO_CURSO) != TRUE THEN
			RAISE EXCEPTION 'CURSO INDISPONÍVEL PARA MUDANÇAS. O ALUNO REFERENCIADO DEVE ESTAR CURSANDO O CURSO PARA REALIZAR ALTERAÇÕES!';

		END IF;
		
		RETURN NEW;
		
	ELSIF TG_OP = 'DELETE' THEN
		RETURN OLD;

	END IF;

	RETURN NULL;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ######################### CONTROLAR_EVENTOS_ALUNO_MODULO_AFTER ########################## ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| FAZ CONTROLE SOBRE AS AÇÕES TOMADAS DEPOIS DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA |--
--| ALUNO_MODULO. AÇÕES: TORNAR MÓDULOS ACESSÍVEIS.                                                 |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [TRIGGER].                                                                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION CONTROLAR_EVENTOS_ALUNO_MODULO_AFTER()
RETURNS TRIGGER
AS $$
BEGIN
	IF TG_OP = 'INSERT' THEN
		RETURN NEW;
	
	ELSIF TG_OP = 'UPDATE' THEN
		IF OLD.META_CONCLUIDA IS FALSE AND NEW.META_CONCLUIDA IS TRUE THEN
			PERFORM VERIFICAR_SE_MODULOS_FICAM_ACESSIVEIS(NEW.COD_MODULO, NEW.COD_ALUNO);

		END IF;
		
		RETURN NEW;
		
	ELSIF TG_OP = 'DELETE' THEN
		RETURN OLD;

	END IF;

	RETURN NULL;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ######################## CONTROLAR_EVENTOS_PRE_REQUISITO_BEFORE ######################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| FAZ CONTROLE SOBRE AS AÇÕES TOMADAS ANTES DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA  |--
--| PRÉ-REQUISITO.                                                                                  |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: CÓDIGO DE MÓDULO INVÁLIDO; CÓDIGO DE MÓDULO PRÉ-REQUISITO INVÁLIDO; CÓDIGOS  |--
--| DE MÓDULOS DE CURSOS DIFERENTES; IMPASSE AO RELACIONAR MÓDULO E MÓDULO PRÉ-REQUISITO.           |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [TRIGGER].                                                                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION CONTROLAR_EVENTOS_PRE_REQUISITO_BEFORE()
RETURNS TRIGGER
AS $$
BEGIN
	IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
		IF VERIFICAR_SE_REGISTRO_EXISTE(NEW.COD_MODULO, 'MODULO') IS FALSE THEN
			RAISE EXCEPTION 'ESSE MODULO NÃO EXISTE, INSIRA UM COD_MODULO VÁLIDO!';
			
		ELSIF VERIFICAR_SE_REGISTRO_EXISTE(NEW.COD_MODULO_PRE_REQUISITO, 'MODULO') IS FALSE THEN
			RAISE EXCEPTION 'ESSE MODULO NÃO EXISTE, INSIRA UM COD_MODULO_PRE_REQUISITO VÁLIDO!';

		ELSIF VERIFICAR_MODULOS_MESMO_CURSO(NEW.COD_MODULO, NEW.COD_MODULO_PRE_REQUISITO) IS FALSE THEN
			RAISE EXCEPTION 'VOCÊ NÃO PODE FAZER UMA RELAÇÃO MODULO - MODULO_PRE_REQUISITO COM MÓDULOS DE CURSOS DIFERENTES!';
			
		ELSIF VERIFICAR_VALIDADE_PRE_REQUISITO(NEW.COD_MODULO, NEW.COD_MODULO_PRE_REQUISITO) IS FALSE THEN
			RAISE EXCEPTION 'VOCÊ NÃO PODE FAZER ESSA RELAÇÃO MODULO - MODULO_PRE_REQUISITO. PRE-REQUITOS ENTRAM EM IMPASSE!';

		END IF;

		PERFORM VERIFICAR_POSSIBILIDADE_DELETE_UPDATE_NO_CURSO((SELECT COD_CURSO FROM MODULO WHERE COD_MODULO = NEW.COD_MODULO));

		RETURN NEW;

	ELSIF TG_OP = 'DELETE' THEN
		PERFORM VERIFICAR_POSSIBILIDADE_DELETE_UPDATE_NO_CURSO((SELECT COD_CURSO FROM MODULO WHERE COD_MODULO = OLD.COD_MODULO));
		                                               
		RETURN OLD;
	
	END IF;

	RETURN NULL;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ########################## CONTROLAR_EVENTOS_DISCIPLINA_BEFORE ########################## ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| FAZ CONTROLE SOBRE AS AÇÕES TOMADAS ANTES DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA  |--
--| DISCIPLINA.                                                                                     |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: CÓDIGO DE MÓDULO INVÁLIDO.                                                   |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [TRIGGER].                                                                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION CONTROLAR_EVENTOS_DISCIPLINA_BEFORE()
RETURNS TRIGGER
AS $$
BEGIN
	IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
		IF VERIFICAR_SE_REGISTRO_EXISTE(NEW.COD_MODULO, 'MODULO') IS FALSE THEN
			RAISE EXCEPTION 'ESSE MÓDULO NÃO EXISTE, INSIRA UM COD_MODULO VÁLIDO!';
			
		END IF;

		PERFORM VERIFICAR_POSSIBILIDADE_DELETE_UPDATE_NO_CURSO((SELECT COD_CURSO FROM MODULO WHERE COD_MODULO = NEW.COD_MODULO));

		RETURN NEW;

	ELSIF TG_OP = 'DELETE' THEN
		PERFORM VERIFICAR_POSSIBILIDADE_DELETE_UPDATE_NO_CURSO((SELECT COD_CURSO FROM MODULO WHERE COD_MODULO = OLD.COD_MODULO));

		RETURN OLD;
		
	END IF;

	RETURN NULL;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ########################## CONTROLAR_EVENTOS_DISCIPLINA_AFTER ########################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| FAZ CONTROLE SOBRE AS AÇÕES TOMADAS DEPOIS DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA |--
--| DISCIPLINA. AÇÕES: ATUALIZAR O PUBLICADO E A DISPONIBILIDADE DO CURSO CASO NECESSÁRIO.          |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [TRIGGER].                                                                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION CONTROLAR_EVENTOS_DISCIPLINA_AFTER()
RETURNS TRIGGER
AS $$
DECLARE
	OLD_COD_CURSO INT;
BEGIN
	IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
		RETURN NEW;
		
	ELSIF TG_OP = 'DELETE' THEN
		SELECT COD_CURSO INTO OLD_COD_CURSO FROM MODULO M_D WHERE M_D.COD_MODULO = OLD.COD_MODULO;

		IF VALIDAR_CURSO(OLD_COD_CURSO) = FALSE THEN
			UPDATE CURSO SET PUBLICADO = FALSE WHERE COD_CURSO = OLD_COD_CURSO;
			UPDATE CURSO SET DISPONIBILIDADE = FALSE WHERE COD_CURSO = OLD_COD_CURSO;

		END IF;

		RETURN OLD;
		
	END IF;
	
	RETURN NULL;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ########################## CONTROLAR_EVENTOS_VIDEO_AULA_BEFORE ########################## ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| FAZ CONTROLE SOBRE AS AÇÕES TOMADAS ANTES DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA  |--
--| VIDEOAULA.                                                                                      |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: CÓDIGO DE DISCIPLINA INVÁLIDO.                                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [TRIGGER].                                                                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION CONTROLAR_EVENTOS_VIDEO_AULA_BEFORE()
RETURNS TRIGGER
AS $$
BEGIN
	IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
		IF VERIFICAR_SE_REGISTRO_EXISTE(NEW.COD_DISCIPLINA, 'DISCIPLINA') IS FALSE THEN
			RAISE EXCEPTION 'ESSA DISCIPLINA NÃO EXISTE, INSIRA UM COD_DISCIPLINA VÁLIDO!';
			
		END IF;

		PERFORM VERIFICAR_POSSIBILIDADE_DELETE_UPDATE_NO_CURSO((SELECT COD_CURSO FROM MODULO WHERE COD_MODULO =
		                                                       (SELECT COD_MODULO FROM DISCIPLINA WHERE COD_DISCIPLINA = NEW.COD_DISCIPLINA)));

		RETURN NEW;

	ELSIF TG_OP = 'DELETE' THEN
		PERFORM VERIFICAR_POSSIBILIDADE_DELETE_UPDATE_NO_CURSO((SELECT COD_CURSO FROM MODULO WHERE COD_MODULO =
		                                                       (SELECT COD_MODULO FROM DISCIPLINA WHERE COD_DISCIPLINA = OLD.COD_DISCIPLINA)));
		
		RETURN OLD;
		
	END IF;

	RETURN NULL;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ########################## CONTROLAR_EVENTOS_VIDEO_AULA_AFTER ########################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| FAZ CONTROLE SOBRE AS AÇÕES TOMADAS DEPOIS DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA |--
--| DISCIPLINA. AÇÕES: ATUALIZAR O PUBLICADO E A DISPONIBILIDADE DO CURSO CASO NECESSÁRIO.          |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [TRIGGER].                                                                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION CONTROLAR_EVENTOS_VIDEO_AULA_AFTER()
RETURNS TRIGGER
AS $$
DECLARE
	NEW_COD_CURSO INT;
	OLD_COD_CURSO INT;
BEGIN
	IF TG_OP = 'INSERT' THEN
		SELECT M_D.COD_CURSO INTO NEW_COD_CURSO FROM MODULO M_D WHERE M_D.COD_MODULO =
		       (SELECT D_C.COD_MODULO FROM DISCIPLINA D_C WHERE D_C.COD_DISCIPLINA = NEW.COD_DISCIPLINA);

		IF VALIDAR_CURSO(NEW_COD_CURSO) = TRUE THEN
			UPDATE CURSO SET DISPONIBILIDADE = TRUE WHERE COD_CURSO = NEW_COD_CURSO;

		END IF;

		RETURN NEW;
	    
	ELSIF TG_OP = 'UPDATE' THEN
		RETURN NEW;
	    
	ELSIF TG_OP = 'DELETE' THEN
		SELECT COD_CURSO INTO OLD_COD_CURSO FROM MODULO M_D WHERE M_D.COD_MODULO =
		       (SELECT D_C.COD_MODULO FROM DISCIPLINA D_C WHERE D_C.COD_DISCIPLINA = OLD.COD_DISCIPLINA);

		IF VALIDAR_CURSO(NEW_COD_CURSO) = FALSE THEN
			UPDATE CURSO SET PUBLICADO = FALSE WHERE COD_CURSO = OLD_COD_CURSO;
			UPDATE CURSO SET DISPONIBILIDADE = FALSE WHERE COD_CURSO = OLD_COD_CURSO;

		END IF;

		RETURN OLD;
	    
	END IF;

	RETURN NULL;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- #################### CONTROLAR_EVENTOS_ALUNO_VIDEO_ASSISTIDO_BEFORE ##################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| FAZ CONTROLE SOBRE AS AÇÕES TOMADAS ANTES DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA  |--
--| ALUNO_VIDEO_ASSISTIDO.                                                                          |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: CÓDIGO DE ALUNO INVÁLIDO; CÓDIGO DE VIDEOAULA INVÁLIDO; ALUNO ENVOLVIDO NAS  |--
--| ALTERAÇÕES NÃO ESTAR CURSANDO; ALUNO NÃO TER ACESSO AO MÓDULO.                                  |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [TRIGGER].                                                                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION CONTROLAR_EVENTOS_ALUNO_VIDEO_ASSISTIDO_BEFORE()
RETURNS TRIGGER
AS $$
DECLARE
	CODIGO_MODULO INT;
	MODULO_ACESSIVEL BOOLEAN;
	CODIGO_CURSO INT;
BEGIN
	IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
		IF VERIFICAR_SE_REGISTRO_EXISTE(NEW.COD_ALUNO, 'ALUNO') IS FALSE THEN
			RAISE EXCEPTION 'ESSE ALUNO NÃO EXISTE, INSIRA UM COD_ALUNO VÁLIDO!';

		ELSIF VERIFICAR_SE_REGISTRO_EXISTE(NEW.COD_VIDEO_AULA, 'VIDEO_AULA') IS FALSE THEN
			RAISE EXCEPTION 'ESSA VIDEO_AULA NÃO EXISTE, INSIRA UM COD_VIDEO_AULA!';

		END IF;
		
		SELECT D_C.COD_MODULO INTO CODIGO_MODULO FROM DISCIPLINA D_C INNER JOIN VIDEO_AULA V_L ON D_C.COD_DISCIPLINA =
		V_L.COD_DISCIPLINA WHERE V_L.COD_VIDEO_AULA = NEW.COD_VIDEO_AULA;

		SELECT A_M.ACESSIVEL INTO MODULO_ACESSIVEL FROM ALUNO_MODULO A_M INNER JOIN MODULO M_D ON
		A_M.COD_MODULO = M_D.COD_MODULO WHERE A_M.COD_MODULO = CODIGO_MODULO AND A_M.COD_ALUNO = NEW.COD_ALUNO;

		SELECT C_S.COD_CURSO INTO CODIGO_CURSO FROM CURSO C_S INNER JOIN MODULO M_D ON C_S.COD_CURSO = M_D.COD_CURSO
		WHERE M_D.COD_MODULO = CODIGO_MODULO;

		IF ALUNO_AINDA_CURSANDO(NEW.COD_ALUNO, CODIGO_CURSO) IS FALSE THEN
			RAISE EXCEPTION 'CURSO INDISPONÍVEL PARA MUDANÇAS. O ALUNO REFERENCIADO DEVE ESTAR CURSANDO O CURSO PARA REALIZAR ALTERAÇÕES!';

		ELSIF MODULO_ACESSIVEL IS FALSE THEN
			RAISE EXCEPTION 'ESSE ALUNO NÃO ATINGIU A META OBRIGATORIA DOS MÓDULOS QUE SÃO PRE_REQUISITO PARA ACESSAR ESSE MÓDULO!';
			
		END IF;
		
		RETURN NEW;
		
	ELSIF TG_OP = 'DELETE' THEN
		RETURN OLD;
	END IF;

	RETURN NULL;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ##################### CONTROLAR_EVENTOS_ALUNO_VIDEO_ASSISTIDO_AFTER ##################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| FAZ CONTROLE SOBRE AS AÇÕES TOMADAS DEPOIS DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA |--
--| ALUNO_VIDEO_ASSISTIDO. AÇÕES: ATUALIZAR O BOOLEANO QUE REPRESENTA QUE A META DO MÓDULO FOI      |--
--| CONCLUÍDA/ALCANÇADA, CASO NECESSÁRIO.                                                           |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [TRIGGER].                                                                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION CONTROLAR_EVENTOS_ALUNO_VIDEO_ASSISTIDO_AFTER()
RETURNS TRIGGER
AS $$
DECLARE
	META_MODULO_PORCENTAGEM FLOAT;
	CODIGO_MODULO INT;
BEGIN
	IF TG_OP = 'INSERT' THEN
		SELECT M_D.COD_MODULO INTO CODIGO_MODULO FROM MODULO M_D INNER JOIN DISCIPLINA D_C ON
		       M_D.COD_MODULO = D_C.COD_MODULO INNER JOIN VIDEO_AULA V_L ON D_C.COD_DISCIPLINA = V_L.COD_DISCIPLINA
		       WHERE V_L.COD_VIDEO_AULA = NEW.COD_VIDEO_AULA;
		
		META_MODULO_PORCENTAGEM := TRUNC((QUANTIDADE_VIDEOS_ASSISTIDOS(NEW.COD_ALUNO, CODIGO_MODULO)::DECIMAL /
		                                  QUANTIDADE_VIDEOS_MODULO(CODIGO_MODULO)::DECIMAL), 1);
		
		IF META_MODULO_PORCENTAGEM >= 0.6 THEN
			UPDATE ALUNO_MODULO SET META_CONCLUIDA = TRUE WHERE COD_ALUNO = NEW.COD_ALUNO AND COD_MODULO = CODIGO_MODULO;

		END IF;

		RETURN NEW;
	
	END IF;
	
	RETURN NULL;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ########################### CONTROLAR_EVENTOS_QUESTAO_BEFORE ############################ ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| FAZ CONTROLE SOBRE AS AÇÕES TOMADAS ANTES DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA  |--
--| QUESTÃO.                                                                                        |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: CÓDIGO DE DISCIPLINA INVÁLIDO; TEXTO CURTO PARA A QUESTÃO.                   |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [TRIGGER].                                                                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION CONTROLAR_EVENTOS_QUESTAO_BEFORE()
RETURNS TRIGGER
AS $$
BEGIN
	IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
		IF VERIFICAR_SE_REGISTRO_EXISTE(NEW.COD_DISCIPLINA, 'DISCIPLINA') IS FALSE THEN
			RAISE EXCEPTION 'ESSA DISCIPLINA NÃO EXISTE, INSIRA UM COD_DISCIPLINA VÁLIDO!';

		END IF;
		
		IF LENGTH(NEW.TEXTO) < 10 THEN
			RAISE EXCEPTION 'TEXTO DA QUESTÃO MUITO CURTO (MENOS DE 10 CARACTERES) INVÁLIDO!';

		END IF;

		PERFORM VERIFICAR_POSSIBILIDADE_DELETE_UPDATE_NO_CURSO((SELECT COD_CURSO FROM MODULO WHERE COD_MODULO =
		                                                       (SELECT COD_MODULO FROM DISCIPLINA WHERE COD_DISCIPLINA =
		                                                       (SELECT COD_DISCIPLINA FROM QUESTAO WHERE COD_QUESTAO = NEW.COD_QUESTAO))));
		
		RETURN NEW;
		
	ELSIF TG_OP = 'DELETE' THEN
		PERFORM VERIFICAR_POSSIBILIDADE_DELETE_UPDATE_NO_CURSO((SELECT COD_CURSO FROM MODULO WHERE COD_MODULO =
		                                                       (SELECT COD_MODULO FROM DISCIPLINA WHERE COD_DISCIPLINA =
		                                                       (SELECT COD_DISCIPLINA FROM QUESTAO WHERE COD_QUESTAO = OLD.COD_QUESTAO))));
		
		RETURN OLD;
		
	END IF;

	RETURN NULL;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ######################### CONTROLAR_EVENTOS_QUESTIONARIO_BEFORE ######################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| FAZ CONTROLE SOBRE AS AÇÕES TOMADAS ANTES DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA  |--
--| QUESTIONÁRIO.                                                                                   |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: CÓDIGO DE DISCIPLINA INVÁLIDO.                                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [TRIGGER].                                                                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION CONTROLAR_EVENTOS_QUESTIONARIO_BEFORE()
RETURNS TRIGGER
AS $$
BEGIN
	IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
		IF VERIFICAR_SE_REGISTRO_EXISTE(NEW.COD_DISCIPLINA, 'DISCIPLINA') IS FALSE THEN
			RAISE EXCEPTION 'ESSA DISCIPLINA NÃO EXISTE, INSIRA UM COD_DISCIPLINA VÁLIDO!';

		END IF;

		PERFORM VERIFICAR_POSSIBILIDADE_DELETE_UPDATE_NO_CURSO((SELECT COD_CURSO FROM MODULO WHERE COD_MODULO =
		                                                       (SELECT COD_MODULO FROM DISCIPLINA WHERE COD_DISCIPLINA =
		                                                       (SELECT COD_DISCIPLINA FROM QUESTIONARIO WHERE COD_QUESTIONARIO = NEW.COD_QUESTIONARIO))));

		RETURN NEW;
		
	ELSIF TG_OP = 'DELETE' THEN
		PERFORM VERIFICAR_POSSIBILIDADE_DELETE_UPDATE_NO_CURSO((SELECT COD_CURSO FROM MODULO WHERE COD_MODULO =
		                                                       (SELECT COD_MODULO FROM DISCIPLINA WHERE COD_DISCIPLINA =
		                                                       (SELECT COD_DISCIPLINA FROM QUESTIONARIO WHERE COD_QUESTIONARIO = OLD.COD_QUESTIONARIO))));
		
		RETURN OLD;
		
	END IF;

	RETURN NULL;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ##################### CONTROLAR_EVENTOS_QUESTAO_QUESTIONARIO_BEFORE ##################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| FAZ CONTROLE SOBRE AS AÇÕES TOMADAS ANTES DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA  |--
--| QUESTAO_QUESTIONARIO.                                                                           |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: CÓDIGO DE QUESTIONÁRIO INVÁLIDO; CÓDIGO DE QUESTÃO INVÁLIDO; QUESTÃO E       |--
--| QUESTIONÁRIO DE DISCIPLINAS DIFERENTES; QUESTÃO JÁ VINCULADA A QUESTIONÁRIO.                    |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [TRIGGER].                                                                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION CONTROLAR_EVENTOS_QUESTAO_QUESTIONARIO_BEFORE()
RETURNS TRIGGER
AS $$
DECLARE
	COD_DISCIPLINA_DO_QUESTIONARIO_VINCULADO INT;
	COD_DISCIPLINA_DA_QUESTAO_VINCULADA INT;
BEGIN
	IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
		IF VERIFICAR_SE_REGISTRO_EXISTE(NEW.COD_QUESTIONARIO, 'QUESTIONARIO') IS FALSE THEN
			RAISE EXCEPTION 'ESSE QUESTIONARIO NÃO EXISTE, INSIRA UM COD_QUESTIONARIO VÁLIDO!';
			
		ELSIF VERIFICAR_SE_REGISTRO_EXISTE(NEW.COD_QUESTAO, 'QUESTAO') IS FALSE THEN
			RAISE EXCEPTION 'ESSA QUESTAO NÃO EXISTE, INSIRA UM COD_QUESTAO VÁLIDO!';

		END IF;

		SELECT COD_DISCIPLINA INTO COD_DISCIPLINA_DO_QUESTIONARIO_VINCULADO FROM QUESTIONARIO WHERE COD_QUESTIONARIO = NEW.COD_QUESTIONARIO;
		SELECT COD_DISCIPLINA INTO COD_DISCIPLINA_DA_QUESTAO_VINCULADA FROM QUESTAO WHERE COD_QUESTAO = NEW.COD_QUESTAO;

		IF COD_DISCIPLINA_DO_QUESTIONARIO_VINCULADO != COD_DISCIPLINA_DA_QUESTAO_VINCULADA THEN
			RAISE EXCEPTION 'NÃO SE PODE VINCULAR UMA QUESTAO A UM QUESTIONARIO DE OUTRA DISCIPLINA!';
			
		ELSIF VERIFICAR_VINCULO_QUESTAO_QUESTIONARIO(NEW.COD_QUESTIONARIO, NEW.COD_QUESTAO) IS TRUE THEN
			RAISE EXCEPTION 'ESSA QUESTÃO JÁ ESTÁ VINCULADA A ESSE QUESTIONÁRIO!';

		END IF;

		PERFORM VERIFICAR_POSSIBILIDADE_DELETE_UPDATE_NO_CURSO((SELECT COD_CURSO FROM MODULO WHERE COD_MODULO =
		                                                       (SELECT COD_MODULO FROM DISCIPLINA WHERE COD_DISCIPLINA =
		                                                       (SELECT COD_DISCIPLINA FROM QUESTAO WHERE COD_QUESTAO = NEW.COD_QUESTAO))));
		
		RETURN NEW;
		
	ELSIF TG_OP = 'DELETE' THEN
		PERFORM VERIFICAR_POSSIBILIDADE_DELETE_UPDATE_NO_CURSO((SELECT COD_CURSO FROM MODULO WHERE COD_MODULO =
		                                                       (SELECT COD_MODULO FROM DISCIPLINA WHERE COD_DISCIPLINA =
		                                                       (SELECT COD_DISCIPLINA FROM QUESTAO WHERE COD_QUESTAO = OLD.COD_QUESTAO))));
		
		RETURN OLD;
		
	END IF;

	RETURN NULL;
END
$$ LANGUAGE plpgsql;

--|-------------------------------------------------------------------------------------------------|--
--|--- ######################## CONTROLAR_EVENTOS_QUESTAO_ALUNO_BEFORE ######################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| FAZ CONTROLE SOBRE AS AÇÕES TOMADAS ANTES DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA  |--
--| QUESTAO_ALUNO.                                                                                  |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| CASOS DE EXCEÇÕES: CÓDIGO DE ALUNO INVÁLIDO; CÓDIGO DE QUESTÃO INVÁLIDO; ALUNO ENVOLVIDO NAS    |--
--| ALTERAÇÕES NÃO ESTAR CURSANDO; ALUNO NÃO TER ACESSO AO MÓDULO; RESPOSTA_CORRETA SER DIFERENTE   |--
--| DE 'CORRETA', 'INCORRETA' OU 'NÃO ANALISADA'.                                                   |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| SAÍDA: [TRIGGER].                                                                               |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE OR REPLACE FUNCTION CONTROLAR_EVENTOS_QUESTAO_ALUNO_BEFORE()
RETURNS TRIGGER
AS $$
DECLARE
	CODIGO_MODULO INT;
	MODULO_ACESSIVEL BOOLEAN;
	CODIGO_CURSO INT;
BEGIN
	IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
		SELECT D_C.COD_MODULO INTO CODIGO_MODULO FROM DISCIPLINA D_C INNER JOIN QUESTAO Q_T ON D_C.COD_DISCIPLINA =
		Q_T.COD_DISCIPLINA WHERE Q_T.COD_QUESTAO = NEW.COD_QUESTAO;

		SELECT A_M.ACESSIVEL INTO MODULO_ACESSIVEL FROM ALUNO_MODULO A_M INNER JOIN MODULO M_D ON
		A_M.COD_MODULO = M_D.COD_MODULO WHERE A_M.COD_MODULO = CODIGO_MODULO AND A_M.COD_ALUNO = NEW.COD_ALUNO;

		SELECT COD_CURSO INTO CODIGO_CURSO FROM MODULO WHERE COD_MODULO =
		(SELECT COD_MODULO FROM DISCIPLINA WHERE COD_DISCIPLINA =
		(SELECT COD_DISCIPLINA FROM QUESTAO WHERE COD_QUESTAO = NEW.COD_QUESTAO));

		SELECT A_M.ACESSIVEL INTO MODULO_ACESSIVEL FROM ALUNO_MODULO A_M INNER JOIN MODULO M_D ON
		A_M.COD_MODULO = M_D.COD_MODULO WHERE A_M.COD_MODULO = CODIGO_MODULO AND A_M.COD_ALUNO = NEW.COD_ALUNO;

		IF VERIFICAR_SE_REGISTRO_EXISTE(NEW.COD_ALUNO, 'ALUNO') IS FALSE THEN
			RAISE EXCEPTION 'ESSE ALUNO NÃO EXISTE, INSIRA UM COD_ALUNO VÁLIDO!';
			
		ELSIF VERIFICAR_SE_REGISTRO_EXISTE(NEW.COD_QUESTAO, 'QUESTAO') IS FALSE THEN
			RAISE EXCEPTION 'ESSA QUESTAO NÃO EXISTE, INSIRA UM COD_QUESTAO VÁLIDO!';

		ELSIF ALUNO_AINDA_CURSANDO(NEW.COD_ALUNO, CODIGO_CURSO) IS FALSE THEN
			RAISE EXCEPTION 'CURSO INDISPONÍVEL PARA MUDANÇAS. O ALUNO REFERENCIADO DEVE ESTAR CURSANDO O CURSO PARA REALIZAR ALTERAÇÕES!';
		
		ELSIF MODULO_ACESSIVEL IS FALSE THEN
			RAISE EXCEPTION 'ESSE ALUNO NÃO ATINGIU A META OBRIGATORIA DOS MÓDULOS QUE SÃO PRE_REQUISITO PARA ACESSAR ESSE MÓDULO!';
		
		ELSIF NOT (NEW.RESPOSTA_CORRETA ILIKE 'CORRETA' OR NEW.RESPOSTA_CORRETA ILIKE 'INCORRETA' OR NEW.RESPOSTA_CORRETA ILIKE 'NÃO ANALISADA') THEN
			RAISE EXCEPTION 'DEVE-SE INFORMAR A RESPOSTA DO ALUNO APENAS COMO "CORRETA" OU "INCORRETA" OU "NÃO ANALISADA"!';

		END IF;

		RETURN NEW;
		
	ELSIF TG_OP = 'DELETE' THEN
		RETURN OLD;
		
	END IF;

	RETURN NULL;
END
$$ LANGUAGE plpgsql;



---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ############################################################################################################################################################### --
-- ########################################################################## TRIGGERS ########################################################################### --
-- ############################################################################################################################################################### --
---------------------------------------------------------------------------------------------------------------------------------------------------------------------


--*****************************************************************************************************************************************************************--
----------------------------**********************************************  << ALUNO >>  ************************************************----------------------------
--*****************************************************************************************************************************************************************--


--|-------------------------------------------------------------------------------------------------|--
--|--- ################################# EVENTOS_ALUNO_BEFORE ################################## ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| GATILHO PARA AÇÕES TOMADAS ANTES DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA ALUNO.    |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE TRIGGER EVENTOS_ALUNO_BEFORE
BEFORE INSERT OR UPDATE OR DELETE ON ALUNO
FOR EACH ROW
EXECUTE PROCEDURE CONTROLAR_EVENTOS_USUARIO_BEFORE();

--|-------------------------------------------------------------------------------------------------|--
--|--- ################################## EVENTOS_ALUNO_AFTER ################################## ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| GATILHO PARA AÇÕES TOMADAS DEPOIS DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA ALUNO.   |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE TRIGGER EVENTOS_ALUNO_AFTER
AFTER INSERT OR UPDATE OR DELETE ON ALUNO
FOR EACH ROW
EXECUTE PROCEDURE CONTROLAR_EVENTOS_ALUNO_AFTER();

--*****************************************************************************************************************************************************************--
----------------------------********************************************  << PROFESSOR >>  **********************************************----------------------------
--*****************************************************************************************************************************************************************--


--|-------------------------------------------------------------------------------------------------|--
--|--- ############################### EVENTOS_PROFESSOR_BEFORE ################################ ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| GATILHO PARA AÇÕES TOMADAS ANTES DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA           |--
--| PROFESSOR.                                                                                      |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE TRIGGER EVENTOS_PROFESSOR_BEFORE
BEFORE INSERT OR UPDATE OR DELETE ON PROFESSOR
FOR EACH ROW
EXECUTE PROCEDURE CONTROLAR_EVENTOS_USUARIO_BEFORE();

--|-------------------------------------------------------------------------------------------------|--
--|--- ################################ EVENTOS_PROFESSOR_AFTER ################################ ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| GATILHO PARA AÇÕES TOMADAS DEPOIS DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA          |--
--| PROFESSOR.                                                                                      |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
CREATE TRIGGER EVENTOS_PROFESSOR_AFTER
AFTER INSERT OR UPDATE OR DELETE ON PROFESSOR
FOR EACH ROW
EXECUTE PROCEDURE CONTROLAR_EVENTOS_PROFESSOR_AFTER();

--*****************************************************************************************************************************************************************--
----------------------------**********************************************  << CURSO >>  ************************************************----------------------------
--*****************************************************************************************************************************************************************--


--|-------------------------------------------------------------------------------------------------|--
--|--- ################################# EVENTOS_CURSO_BEFORE ################################## ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| GATILHO PARA AÇÕES TOMADAS ANTES DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA CURSO.    |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE TRIGGER EVENTOS_CURSO_BEFORE
BEFORE INSERT OR UPDATE OR DELETE ON CURSO
FOR EACH ROW
EXECUTE PROCEDURE CONTROLAR_EVENTOS_CURSO_BEFORE();


--*****************************************************************************************************************************************************************--
----------------------------********************************************  << ALUNO_CURSO >>  ********************************************----------------------------
--*****************************************************************************************************************************************************************--

--|-------------------------------------------------------------------------------------------------|--
--|--- ############################## EVENTOS_ALUNO_CURSO_BEFORE ############################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| GATILHO PARA AÇÕES TOMADAS DEPOIS DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA CURSO.   |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE TRIGGER EVENTOS_ALUNO_CURSO_BEFORE
BEFORE INSERT OR UPDATE OR DELETE ON ALUNO_CURSO
FOR EACH ROW
EXECUTE PROCEDURE CONTROLAR_EVENTOS_ALUNO_CURSO_BEFORE();

--|-------------------------------------------------------------------------------------------------|--
--|--- ############################### EVENTOS_ALUNO_CURSO_AFTER ############################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| GATILHO PARA AÇÕES TOMADAS DEPOIS DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA          |--
--| ALUNO_CURSO.                                                                                    |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE TRIGGER EVENTOS_ALUNO_CURSO_AFTER
AFTER INSERT OR UPDATE OR DELETE ON ALUNO_CURSO
FOR EACH ROW
EXECUTE PROCEDURE CONTROLAR_EVENTOS_ALUNO_CURSO_AFTER();


--*****************************************************************************************************************************************************************--
----------------------------**********************************************  << MODULO >>  ***********************************************----------------------------
--*****************************************************************************************************************************************************************--

--|-------------------------------------------------------------------------------------------------|--
--|--- ################################# EVENTOS_MODULO_BEFORE ################################# ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| GATILHO PARA AÇÕES TOMADAS ANTES DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA MÓDULO.   |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE TRIGGER EVENTOS_MODULO_BEFORE
BEFORE INSERT OR UPDATE OR DELETE ON MODULO
FOR EACH ROW
EXECUTE PROCEDURE CONTROLAR_EVENTOS_MODULO_BEFORE();

--|-------------------------------------------------------------------------------------------------|--
--|--- ################################# EVENTOS_MODULO_AFTER ################################## ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| GATILHO PARA AÇÕES TOMADAS DEPOIS DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA MÓDULO.  |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE TRIGGER EVENTOS_MODULO_AFTER
AFTER INSERT OR UPDATE OR DELETE ON MODULO
FOR EACH ROW
EXECUTE PROCEDURE CONTROLAR_EVENTOS_MODULO_AFTER();


--*****************************************************************************************************************************************************************--
----------------------------*******************************************  << ALUNO_MODULO >>  ********************************************----------------------------
--*****************************************************************************************************************************************************************--

--|-------------------------------------------------------------------------------------------------|--
--|--- ############################## EVENTOS_ALUNO_MODULO_BEFORE ############################## ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| GATILHO PARA AÇÕES TOMADAS ANTES DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA           |--
--| ALUNO_MODULO.                                                                                   |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE TRIGGER EVENTOS_ALUNO_MODULO_BEFORE
BEFORE INSERT OR UPDATE OR DELETE ON ALUNO_MODULO
FOR EACH ROW
EXECUTE PROCEDURE CONTROLAR_EVENTOS_ALUNO_MODULO_BEFORE();

--|-------------------------------------------------------------------------------------------------|--
--|--- ############################## EVENTOS_ALUNO_MODULO_AFTER ############################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| GATILHO PARA AÇÕES TOMADAS DEPOIS DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA          |--
--| ALUNO_MODULO.                                                                                   |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE TRIGGER EVENTOS_ALUNO_MODULO_AFTER
AFTER INSERT OR UPDATE OR DELETE ON ALUNO_MODULO
FOR EACH ROW
EXECUTE PROCEDURE CONTROLAR_EVENTOS_ALUNO_MODULO_AFTER();


--*****************************************************************************************************************************************************************--
----------------------------*******************************************  << PRE_REQUISITO >>  *******************************************----------------------------
--*****************************************************************************************************************************************************************--

--|-------------------------------------------------------------------------------------------------|--
--|--- ############################# EVENTOS_PRE_REQUISITO_BEFORE ############################## ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| GATILHO PARA AÇÕES TOMADAS ANTES DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA           |--
--| PRÉ-REQUISITO.                                                                                  |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE TRIGGER EVENTOS_PRE_REQUISITO_BEFORE
BEFORE INSERT OR UPDATE OR DELETE ON PRE_REQUISITO
FOR EACH ROW
EXECUTE PROCEDURE CONTROLAR_EVENTOS_PRE_REQUISITO_BEFORE();


--*****************************************************************************************************************************************************************--
----------------------------********************************************  << DISCIPLINA >>  *********************************************----------------------------
--*****************************************************************************************************************************************************************--

--|-------------------------------------------------------------------------------------------------|--
--|--- ############################### EVENTOS_DISCIPLINA_BEFORE ############################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| GATILHO PARA AÇÕES TOMADAS ANTES DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA           |--
--| DISCIPLINA.                                                                                     |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE TRIGGER EVENTOS_DISCIPLINA_BEFORE
BEFORE INSERT OR UPDATE OR DELETE ON DISCIPLINA
FOR EACH ROW
EXECUTE PROCEDURE CONTROLAR_EVENTOS_DISCIPLINA_BEFORE();

--|-------------------------------------------------------------------------------------------------|--
--|--- ############################### EVENTOS_DISCIPLINA_AFTER ################################ ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| GATILHO PARA AÇÕES TOMADAS DEPOIS DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA          |--
--| DISCIPLINA.                                                                                     |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE TRIGGER EVENTOS_DISCIPLINA_AFTER
AFTER INSERT OR UPDATE OR DELETE ON DISCIPLINA
FOR EACH ROW
EXECUTE PROCEDURE CONTROLAR_EVENTOS_DISCIPLINA_AFTER();


--*****************************************************************************************************************************************************************--
----------------------------********************************************  << VIDEO_AULA >>  *********************************************----------------------------
--*****************************************************************************************************************************************************************--

--|-------------------------------------------------------------------------------------------------|--
--|--- ############################### EVENTOS_VIDEO_AULA_BEFORE ############################### ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| GATILHO PARA AÇÕES TOMADAS ANTES DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA           |--
--| VIDEOAULA.                                                                                      |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE TRIGGER EVENTOS_VIDEO_AULA_BEFORE
BEFORE INSERT OR UPDATE OR DELETE ON VIDEO_AULA
FOR EACH ROW
EXECUTE PROCEDURE CONTROLAR_EVENTOS_VIDEO_AULA_BEFORE();

--|-------------------------------------------------------------------------------------------------|--
--|--- ############################### EVENTOS_VIDEO_AULA_AFTER ################################ ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| GATILHO PARA AÇÕES TOMADAS DEPOIS DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA          |--
--| VIDEOAULA.                                                                                      |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE TRIGGER EVENTOS_VIDEO_AULA_AFTER
AFTER INSERT OR UPDATE OR DELETE ON VIDEO_AULA
FOR EACH ROW
EXECUTE PROCEDURE CONTROLAR_EVENTOS_VIDEO_AULA_AFTER();


--*****************************************************************************************************************************************************************--
----------------------------***************************************  << ALUNO_VIDEO_ASSISTIDO >>  ***************************************----------------------------
--*****************************************************************************************************************************************************************--

--|-------------------------------------------------------------------------------------------------|--
--|--- ######################### EVENTOS_ALUNO_VIDEO_ASSISTIDO_BEFORE ########################## ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| GATILHO PARA AÇÕES TOMADAS ANTES DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA           |--
--| ALUNO_VIDEO_ASSISTIDO.                                                                          |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE TRIGGER EVENTOS_ALUNO_VIDEO_ASSISTIDO_BEFORE
BEFORE INSERT OR UPDATE OR DELETE ON ALUNO_VIDEO_ASSISTIDO
FOR EACH ROW
EXECUTE PROCEDURE CONTROLAR_EVENTOS_ALUNO_VIDEO_ASSISTIDO_BEFORE();

--|-------------------------------------------------------------------------------------------------|--
--|--- ########################## EVENTOS_ALUNO_VIDEO_ASSISTIDO_AFTER ########################## ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| GATILHO PARA AÇÕES TOMADAS DEPOIS DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA          |--
--| ALUNO_VIDEO_ASSISTIDO.                                                                          |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE TRIGGER EVENTOS_ALUNO_VIDEO_ASSISTIDO_AFTER
AFTER INSERT OR UPDATE OR DELETE ON ALUNO_VIDEO_ASSISTIDO
FOR EACH ROW
EXECUTE PROCEDURE CONTROLAR_EVENTOS_ALUNO_VIDEO_ASSISTIDO_AFTER();


--*****************************************************************************************************************************************************************--
----------------------------*********************************************  << QUESTAO >>  ***********************************************----------------------------
--*****************************************************************************************************************************************************************--

--|-------------------------------------------------------------------------------------------------|--
--|--- ################################ EVENTOS_QUESTAO_BEFORE ################################# ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| GATILHO PARA AÇÕES TOMADAS ANTES DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA QUESTÃO.  |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE TRIGGER EVENTOS_QUESTAO_BEFORE
BEFORE INSERT OR UPDATE OR DELETE ON QUESTAO
FOR EACH ROW
EXECUTE PROCEDURE CONTROLAR_EVENTOS_QUESTAO_BEFORE();


--*****************************************************************************************************************************************************************--
----------------------------*******************************************  << QUESTIONARIO >>  ********************************************----------------------------
--*****************************************************************************************************************************************************************--

--|-------------------------------------------------------------------------------------------------|--
--|--- ############################## EVENTOS_QUESTIONARIO_BEFORE ############################## ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| GATILHO PARA AÇÕES TOMADAS ANTES DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA           |--
--| QUESTIONÁRIO.                                                                                   |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE TRIGGER EVENTOS_QUESTIONARIO_BEFORE
BEFORE INSERT OR UPDATE OR DELETE ON QUESTIONARIO
FOR EACH ROW
EXECUTE PROCEDURE CONTROLAR_EVENTOS_QUESTIONARIO_BEFORE();


--*****************************************************************************************************************************************************************--
----------------------------***************************************  << QUESTAO_QUESTIONARIO >>  ****************************************----------------------------
--*****************************************************************************************************************************************************************--

--|-------------------------------------------------------------------------------------------------|--
--|--- ########################## EVENTOS_QUESTAO_QUESTIONARIO_BEFORE ########################## ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| GATILHO PARA AÇÕES TOMADAS ANTES DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA           |--
--| QUESTAO_QUESTIONARIO.                                                                           |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE TRIGGER EVENTOS_QUESTAO_QUESTIONARIO_BEFORE
BEFORE INSERT OR UPDATE OR DELETE ON QUESTAO_QUESTIONARIO
FOR EACH ROW
EXECUTE PROCEDURE CONTROLAR_EVENTOS_QUESTAO_QUESTIONARIO_BEFORE();


--*****************************************************************************************************************************************************************--
----------------------------******************************************  << QUESTAO_ALUNO >>  ********************************************----------------------------
--*****************************************************************************************************************************************************************--

--|-------------------------------------------------------------------------------------------------|--
--|--- ############################# EVENTOS_QUESTAO_ALUNO_BEFORE ############################## ---|----------------------------------------------------------------
--|-------------------------------------------------------------------------------------------------|--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--| GATILHO PARA AÇÕES TOMADAS ANTES DE OCORRER UM INSERT, UPDATE OU DELETE EM UMA TABELA           |--
--| QUESTAO_ALUNO.                                                                                  |--
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

CREATE TRIGGER EVENTOS_QUESTAO_ALUNO_BEFORE
BEFORE INSERT OR UPDATE OR DELETE ON QUESTAO_ALUNO
FOR EACH ROW
EXECUTE PROCEDURE CONTROLAR_EVENTOS_QUESTAO_ALUNO_BEFORE();



---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ############################################################################################################################################################### --
-- ############################################################################ GRUPOS ########################################################################### --
-- ############################################################################################################################################################### --
---------------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE GROUP ALUNO;
CREATE GROUP PROFESSOR;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA PUBLIC TO GROUP ALUNO, PROFESSOR;

GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA PUBLIC TO ALUNO, PROFESSOR;

GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA PUBLIC TO ALUNO, PROFESSOR;

REVOKE ALL PRIVILEGES ON FUNCTION INSERIR_ALUNO_E_PROFESSOR(TEXT, TEXT, DATE, TEXT, TEXT, TEXT), REMOVER_ALUNO_E_PROFESSOR(INT, TEXT) FROM PUBLIC, ALUNO, PROFESSOR;



---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ############################################################################################################################################################### --
-- ########################################################################## EXECUÇÕES ########################################################################## --
-- ############################################################################################################################################################### --
---------------------------------------------------------------------------------------------------------------------------------------------------------------------


SELECT * FROM ALUNO_MODULO;
SELECT * FROM PRE_REQUISITO;
SELECT * FROM ALUNO_CURSO;
SELECT * FROM ALUNO;
SELECT * FROM PROFESSOR;
SELECT * FROM CURSO;
SELECT * FROM MODULO;
SELECT * FROM DISCIPLINA;
SELECT * FROM VIDEO_AULA;
SELECT * FROM ALUNO_VIDEO_ASSISTIDO;
SELECT * FROM QUESTAO;
SELECT * FROM QUESTIONARIO;

--------------------------------------------------------------------- INSERIR_ALUNO_E_PROFESSOR ---------------------------------------------------------------------
--(PARÂMETROS: COD_USUARIO, NOME, CPF, DATA_NASCIMENTO, EMAIL, SENHA, TABELA)--

---- SELECT * FROM ALUNO;
---- SELECT * FROM PROFESSOR;

SELECT FROM INSERIR_ALUNO_E_PROFESSOR
('NELSON', '11223344555', '1992-07-23', 'NELSON@GMAIL.COM', '123', 'ALUNO'); -- COD_ALUNO: 1
SELECT FROM INSERIR_ALUNO_E_PROFESSOR
('CARLOS', '22334455666', '1990-01-23', 'CARLOS@GMAIL.COM', '123', 'ALUNO'); -- COD_ALUNO: 2
SELECT FROM INSERIR_ALUNO_E_PROFESSOR
('FELIPE', '33445566777', '2000-06-09', 'FELIPE@GMAIL.COM', '123', 'ALUNO'); -- COD_ALUNO: 3
SELECT FROM INSERIR_ALUNO_E_PROFESSOR
('JOHN', '44556677888', '2000-02-10', 'JOHN@GMAIL.COM', '123', 'ALUNO'); -- COD_ALUNO: 4
SELECT FROM INSERIR_ALUNO_E_PROFESSOR
('ELCY', '55667788999', '1998-10-08', 'ELCY@GMAIL.COM', '123', 'ALUNO'); -- COD_ALUNO: 5

SELECT FROM INSERIR_ALUNO_E_PROFESSOR
('GEOVANE', '12345678912', '1986-05-02', 'GEOVANE@GMAIL.COM', '123', 'PROFESSOR'); -- COD_PROFESSOR: 1
SELECT FROM INSERIR_ALUNO_E_PROFESSOR
('VILARINHO', '23456789123', '1999-03-10', 'VILARINHO@GMAIL.COM', '123', 'PROFESSOR'); -- COD_PROFESSOR: 2
SELECT FROM INSERIR_ALUNO_E_PROFESSOR
('LUAN', '34567891234', '2000-08-10', 'LUAN@GMAIL.COM', '123', 'PROFESSOR'); -- COD_PROFESSOR: 3
SELECT FROM INSERIR_ALUNO_E_PROFESSOR
('MARCOS', '45678912345', '1997-10-01', 'MARCOS@GMAIL.COM', '123', 'PROFESSOR'); -- COD_PROFESSOR: 4
SELECT FROM INSERIR_ALUNO_E_PROFESSOR
('PEDRO', '56789123456', '1989-01-05', 'PEDRO@GMAIL.COM', '123', 'PROFESSOR'); -- COD_PROFESSOR: 5

---- SELECT * FROM ALUNO;
---- SELECT * FROM PROFESSOR;

--------------------------------------------------------------------- REMOVER_ALUNO_E_PROFESSOR ---------------------------------------------------------------------
--(PARÂMETROS: COD_USUARIO_DELETADO, TABELA)--

---- SELECT * FROM ALUNO;
---- SELECT * FROM PROFESSOR;

SELECT REMOVER_ALUNO_E_PROFESSOR(4, 'ALUNO');

SELECT REMOVER_ALUNO_E_PROFESSOR(4, 'PROFESSOR');

---- SELECT * FROM ALUNO;
---- SELECT * FROM PROFESSOR;

-------------------------------------------------------------------------- ATUALIZAR_SALDO --------------------------------------------------------------------------
--(PARÂMETROS: VALOR_SALDO_A_ALTERAR, CODIGO, TABELA)--

---- SELECT * FROM ALUNO;
---- SELECT * FROM PROFESSOR;

SELECT FROM ATUALIZAR_SALDO(10000, 1, 'ALUNO');
SELECT FROM ATUALIZAR_SALDO(10, 2, 'ALUNO');
SELECT FROM ATUALIZAR_SALDO(300, 3, 'ALUNO');
SELECT FROM ATUALIZAR_SALDO(5000, 5, 'ALUNO');

SELECT FROM ATUALIZAR_SALDO(30000, 1, 'PROFESSOR');
SELECT FROM ATUALIZAR_SALDO(-10000, 1, 'PROFESSOR');
SELECT FROM ATUALIZAR_SALDO(100, 2, 'PROFESSOR');
SELECT FROM ATUALIZAR_SALDO(50, 3, 'PROFESSOR');
SELECT FROM ATUALIZAR_SALDO(7000, 5, 'PROFESSOR');

---- SELECT * FROM ALUNO;
---- SELECT * FROM PROFESSOR;

---------------------------------------------------------------------------- SACAR_SALDO ----------------------------------------------------------------------------
--(PARÂMETROS: CODIGO, TABELA)--

---- SELECT * FROM ALUNO;
---- SELECT * FROM PROFESSOR;

SELECT SACAR_SALDO(3, 'ALUNO');

SELECT SACAR_SALDO(3, 'PROFESSOR');

---- SELECT * FROM ALUNO;
---- SELECT * FROM PROFESSOR;

-------------------------------------------------------------------------- CONSULTAR_SALDO --------------------------------------------------------------------------
--(PARÂMETROS: CODIGO, TABELA)--

---- SELECT * FROM ALUNO;
---- SELECT * FROM PROFESSOR;

SELECT CONSULTAR_SALDO(1, 'ALUNO');
SELECT CONSULTAR_SALDO(2, 'ALUNO');
SELECT CONSULTAR_SALDO(3, 'ALUNO');
SELECT CONSULTAR_SALDO(5, 'ALUNO');

SELECT CONSULTAR_SALDO(1, 'PROFESSOR');
SELECT CONSULTAR_SALDO(2, 'PROFESSOR');
SELECT CONSULTAR_SALDO(3, 'PROFESSOR');
SELECT CONSULTAR_SALDO(5, 'PROFESSOR');

---- SELECT * FROM ALUNO;
---- SELECT * FROM PROFESSOR;

---------------------------------------------------------------------------- CRIAR_CURSO ----------------------------------------------------------------------------
--(PARÂMETROS: COD_PROFESSOR, NOME_CURSO, DESCRICAO, PRECO)--

---- SELECT * FROM CURSO;

SELECT FROM CRIAR_CURSO(1, 'PROGRAMACAO', 'APRENDENDO ALGORITMOS E PROGRAMACAO', 250); -- COD_CURSO: 1
SELECT FROM CRIAR_CURSO(2, 'JOGOS', 'APRENDENDO PROGRAMACAO PARA JOGOS', 150); -- COD_CURSO: 2
SELECT FROM CRIAR_CURSO(3, 'MATEMATICA', 'APRENDENDO A FAZER CALCULOS', 100); -- COD_CURSO: 3
SELECT FROM CRIAR_CURSO(5, 'BÁSICO DE JAVA', 'APRENDENDO A PROGRAMAR EM JAVA', 400); -- COD_CURSO: 4
SELECT FROM CRIAR_CURSO(3, 'PROGRAMACAO SEM GRAFOS', 'APRENDENDO A PROGRAMAR SEM GRAFOS', 200); -- COD_CURSO: 5

---- SELECT * FROM CURSO;

--------------------------------------------------------------------------- DELETAR_CURSO ---------------------------------------------------------------------------
--(PARÂMETROS: COD_CURSO_DELETADO)--

---- SELECT * FROM CURSO;

SELECT FROM DELETAR_CURSO(4);

---- SELECT * FROM CURSO;

--------------------------------------------------------------------------- CRIAR_MODULOS ---------------------------------------------------------------------------
--(PARÂMETROS: CODIGO_CURSO, NOME_MODULO(ARRAY), DESCRICAO_MODULO(ARRAY))--

---- SELECT * FROM MODULO;

SELECT FROM CRIAR_MODULOS (
	3,
	ARRAY ['MODULO 1(MATEMATICA)', 'MODULO 2(MATEMATICA)', 'MODULO 3(MATEMATICA)'],
	ARRAY ['DESCRICAO 1(MATEMATICA)', 'DESCRICAO 2(MATEMATICA)', 'DESCRICAO 3(MATEMATICA)']
);  -- COD_MODULO: 1, 2, 3

SELECT FROM CRIAR_MODULOS (
	3,
	ARRAY ['MODULO DELETADO 1', 'MODULO DELETADO 2', 'MODULO DELETADO 1'],
	ARRAY ['DESCRICAO 1', 'DESCRICAO 2', 'DESCRICAO 3']
);  -- COD_MODULO: 4, 5, 6

---- SELECT * FROM MODULO;
---- SELECT * FROM CURSO; -- VEJA QUE ELE NÃO ESTÁ DISPONIVEL

-------------------------------------------------------------------------- DELETAR_MODULO ---------------------------------------------------------------------------
--(PARÂMETROS: CODIGO_MODULO--

---- SELECT * FROM MODULO;

SELECT FROM DELETAR_MODULO(4);
SELECT FROM DELETAR_MODULO(5);
SELECT FROM DELETAR_MODULO(6);

---- SELECT * FROM MODULO;

------------------------------------------------------------------------ CRIAR_DISCIPLINAS --------------------------------------------------------------------------
--(PARÂMETROS: CODIGO_MODULO, NOME_DISCIPLINA, DESCRICAO_DISCIPLINA)--

---- SELECT * FROM DISCIPLINA;

SELECT FROM CRIAR_DISCIPLINAS (
	1,
	ARRAY ['APRENDENDO A SOMAR', 'APRENDENDO A DIVIDIR', 'APRENDENDO A SUBTRAIR'],
	ARRAY ['DESCRICAO 1', 'DESCRICAO 2', 'DESCRICAO 3']
);  -- COD_DISCIPLINA: 1, 2, 3

SELECT FROM CRIAR_DISCIPLINAS (
	2,
	ARRAY ['APRENDENDO A DERIVADA', 'APRENDENDO A BASKARA', 'APRENDENDO A ALGEBRA'],
	ARRAY ['DESCRICAO 1', 'DESCRICAO 2', 'DESCRICAO 3']
);  -- COD_DISCIPLINA: 4, 5, 6

SELECT FROM CRIAR_DISCIPLINAS (
	3,
	ARRAY ['APRENDENDO RAIZ QUADRADA', 'APRENDENDO RAIZ CÚBICA', 'APRENDENDO OUTRAS RAIZES'],
	ARRAY ['DESCRICAO 1', 'DESCRICAO 2', 'DESCRICAO 3']
);  -- COD_DISCIPLINA: 7, 8, 9

SELECT FROM CRIAR_DISCIPLINAS (
	3,
	ARRAY ['APRENDENDO A EQUAÇÃO', 'APRENDENDO GEOMETRIA', 'APRENDENDO A PRODUTO CARTEZIADO'],
	ARRAY ['DESCRICAO 1', 'DESCRICAO 2', 'DESCRICAO 3']
);  -- COD_DISCIPLINA: 10, 11, 12

---- SELECT * FROM DISCIPLINA;
---- SELECT * FROM CURSO; -- VEJA QUE ELE NÃO ESTÁ DISPONIVEL

------------------------------------------------------------------------ DELETAR_DISCIPLINA -------------------------------------------------------------------------
--(PARÂMETROS: CODIGO_DISCIPLINA)--

---- SELECT * FROM DISCIPLINA;

SELECT FROM DELETAR_DISCIPLINA(10);
SELECT FROM DELETAR_DISCIPLINA(11);
SELECT FROM DELETAR_DISCIPLINA(12);

---- SELECT * FROM DISCIPLINA;

------------------------------------------------------------------------ CRIAR_VIDEO_AULAS --------------------------------------------------------------------------
--(PARÂMETROS: CODIGO_DISCIPLINA, TITULO_VIDEO(ARRAY), DESCRICAO(ARRAY), DURACAO(ARRAY))--

---- SELECT * FROM VIDEO_AULA;

SELECT FROM CRIAR_VIDEO_AULAS (
	1,
	ARRAY ['VIDEO 1', 'VIDEO 2', 'VIDEO 3'],
	ARRAY ['DESCRICAO 1', 'DESCRICAO 2', 'DESCRICAO 3'],
	ARRAY [10, 5, 3]
);  -- COD_VIDEO_AULA: 1, 2, 3

SELECT FROM CRIAR_VIDEO_AULAS (
	2,
	ARRAY ['VIDEO 1', 'VIDEO 2', 'VIDEO 3'],
	ARRAY ['DESCRICAO 1', 'DESCRICAO 2', 'DESCRICAO 3'],
	ARRAY [20, 10, 8]
);  -- COD_VIDEO_AULA: 4, 5, 6

SELECT FROM CRIAR_VIDEO_AULAS (
	3,
	ARRAY ['VIDEO 1', 'VIDEO 2', 'VIDEO 3'],
	ARRAY ['DESCRICAO 1', 'DESCRICAO 2', 'DESCRICAO 3'],
	ARRAY [2, 15, 10]
);  -- COD_VIDEO_AULA: 7, 8, 9

SELECT FROM CRIAR_VIDEO_AULAS (
	4,
	ARRAY ['VIDEO 1', 'VIDEO 2', 'VIDEO 3'],
	ARRAY ['DESCRICAO 1', 'DESCRICAO 2', 'DESCRICAO 3'],
	ARRAY [15, 15, 4]
);  -- COD_VIDEO_AULA: 10, 11, 12

SELECT FROM CRIAR_VIDEO_AULAS (
	5,
	ARRAY ['VIDEO 1', 'VIDEO 2', 'VIDEO 3'],
	ARRAY ['DESCRICAO 1', 'DESCRICAO 2', 'DESCRICAO 3'],
	ARRAY [6, 2, 14]
);  -- COD_VIDEO_AULA: 13, 14, 15

SELECT FROM CRIAR_VIDEO_AULAS (
	6,
	ARRAY ['VIDEO 1', 'VIDEO 2', 'VIDEO 3'],
	ARRAY ['DESCRICAO 1', 'DESCRICAO 2', 'DESCRICAO 3'],
	ARRAY [30, 15, 20]
);  -- COD_VIDEO_AULA: 16, 17, 18

SELECT FROM CRIAR_VIDEO_AULAS (
	7,
	ARRAY ['VIDEO 1', 'VIDEO 2', 'VIDEO 3'],
	ARRAY ['DESCRICAO 1', 'DESCRICAO 2', 'DESCRICAO 3'],
	ARRAY [16, 4, 18]
);  -- COD_VIDEO_AULA: 19, 20, 21

SELECT FROM CRIAR_VIDEO_AULAS (
	8,
	ARRAY ['VIDEO 1', 'VIDEO 2', 'VIDEO 3'],
	ARRAY ['DESCRICAO 1', 'DESCRICAO 2', 'DESCRICAO 3'],
	ARRAY [4, 6, 8]
);  -- COD_VIDEO_AULA: 22, 23, 24

---- SELECT * FROM CURSO; -- VEJA QUE ELE NÃO ESTÁ DISPONIVEL

SELECT FROM CRIAR_VIDEO_AULAS (
	9,
	ARRAY ['VIDEO 1', 'VIDEO 2', 'VIDEO 3'],
	ARRAY ['DESCRICAO 1', 'DESCRICAO 2', 'DESCRICAO 3'],
	ARRAY [18, 25, 15]
);  -- COD_VIDEO_AULA: 25, 26, 27

---- SELECT * FROM VIDEO_AULA;
---- SELECT * FROM CURSO; -- VEJA QUE ELE ESTÁ DISPONIVEL AGORA

------------------------------------------------------------------------ DELETAR_VIDEO_AULA -------------------------------------------------------------------------
--(PARÂMETROS: CODIGO_VIDEO_AULA)--
SELECT FROM DELETAR_VIDEO_AULA(27);

---- SELECT * FROM VIDEO_AULA;
---- SELECT * FROM CURSO; -- VEJA QUE ELE NÃO ESTÁ DISPONIVEL

------------------------------------------------------------------------ CRIAR_PRE_REQUISITO ------------------------------------------------------------------------
--(PARAMENTROS: COD_MODULO, COD_MODULO_PRE_REQUISITO)--

---- SELECT * FROM PRE_REQUISITO;

SELECT FROM CRIAR_PRE_REQUISITO(2, 1);
SELECT FROM CRIAR_PRE_REQUISITO(3, 2);
SELECT FROM CRIAR_PRE_REQUISITO(1, 3); -- NÃO É PARA DAR CERTO POIS ISSO RESULTARIA UM IMPASSE DE MODULOS QUE NUNCA PODEM SER ACESSADOS.

---- SELECT * FROM PRE_REQUISITO;

--------------------------------------------------------------------------- CRIAR_QUESTAO ---------------------------------------------------------------------------
--(PARAMENTROS: CODIGO_DISCIPLINA, TEXTO_INSERIDO)--

---- SELECT * FROM QUESTAO;

SELECT FROM CRIAR_QUESTAO(2, 'QUANTO É 9 / 3?'); -- COD_QUESTAO: 1
SELECT FROM CRIAR_QUESTAO(2, 'QUANTO É 50 / 2?'); -- COD_QUESTAO: 2
SELECT FROM CRIAR_QUESTAO(2, 'QUANTO É 20 / 4?'); -- COD_QUESTAO: 3
SELECT FROM CRIAR_QUESTAO(2, 'QUANTO É 1000 / 20?'); -- COD_QUESTAO: 4
SELECT FROM CRIAR_QUESTAO(2, 'QUANTO É 7 / 1?'); -- COD_QUESTAO: 5
SELECT FROM CRIAR_QUESTAO(8, 'QUANTO É A RAIZ CÚBICA DE 1?'); -- COD_QUESTAO: 6
SELECT FROM CRIAR_QUESTAO(8, 'QUANTO É A RAIZ CÚBICA DE 8?'); -- COD_QUESTAO: 7
SELECT FROM CRIAR_QUESTAO(8, 'QUANTO É A RAIZ CÚBICA DE 27?'); -- COD_QUESTAO: 8

---- SELECT * FROM QUESTAO;

-------------------------------------------------------------------------- DELETAR_QUESTAO --------------------------------------------------------------------------
--(PARAMENTROS: CODIGO_QUESTAO)--

---- SELECT * FROM QUESTAO;

SELECT FROM DELETAR_QUESTAO(5);

---- SELECT * FROM QUESTAO;

------------------------------------------------------------------------ CRIAR_QUESTIONARIO -------------------------------------------------------------------------
--(PARAMENTROS: NOME_INSERIDO, COD_DISCIPLINA_INSERIDA)--

---- SELECT * FROM QUESTIONARIO;

SELECT FROM CRIAR_QUESTIONARIO('DIVISÃO 1', 2); -- COD_QUESTIONARIO: 1
SELECT FROM CRIAR_QUESTIONARIO('DIVISÃO 2', 2); -- COD_QUESTIONARIO: 2
SELECT FROM CRIAR_QUESTIONARIO('DIVISÃO 3', 2); -- COD_QUESTIONARIO: 3
SELECT FROM CRIAR_QUESTIONARIO('RAIZ QUADRADA 1', 7); -- COD_QUESTIONARIO: 4
SELECT FROM CRIAR_QUESTIONARIO('RAIZ QUADRADA 2', 7); -- COD_QUESTIONARIO: 5
SELECT FROM CRIAR_QUESTIONARIO('RAIZ CUBICA 1', 8); -- COD_QUESTIONARIO: 6
SELECT FROM CRIAR_QUESTIONARIO('RAIZ CUBICA 2', 8); -- COD_QUESTIONARIO: 7

---- SELECT * FROM QUESTIONARIO;

----------------------------------------------------------------------- DELETAR_QUESTIONARIO ------------------------------------------------------------------------
--(PARAMENTROS: COD_QUESTIONARIO_DELETADO)--

---- SELECT * FROM QUESTIONARIO;

SELECT FROM DELETAR_QUESTIONARIO(5);

---- SELECT * FROM QUESTIONARIO;

------------------------------------------------------------------ VINCULAR_QUESTAO_A_QUESTIONARIO ------------------------------------------------------------------
--(PARAMENTROS: COD_QUESTIONARIO_VINCULADO, COD_QUESTAO_VINCULADA)--

---- SELECT * FROM QUESTAO_QUESTIONARIO;

SELECT FROM VINCULAR_QUESTAO_A_QUESTIONARIO(1, 1);
SELECT FROM VINCULAR_QUESTAO_A_QUESTIONARIO(2, 2);
SELECT FROM VINCULAR_QUESTAO_A_QUESTIONARIO(3, 3);
SELECT FROM VINCULAR_QUESTAO_A_QUESTIONARIO(3, 4);
SELECT FROM VINCULAR_QUESTAO_A_QUESTIONARIO(6, 6);
SELECT FROM VINCULAR_QUESTAO_A_QUESTIONARIO(7, 7);
SELECT FROM VINCULAR_QUESTAO_A_QUESTIONARIO(4, 8); -- NÃO DÁ CERTO PORQUE AS DISCIPLINAS SÃO DIFERENTES
SELECT FROM VINCULAR_QUESTAO_A_QUESTIONARIO(7, 8);

---- SELECT * FROM QUESTAO_QUESTIONARIO;

-------------------------------------------------------------------------- PUBLICAR_CURSO ---------------------------------------------------------------------------
--(PARÂMETROS: CODIGO_CURSO)--

SELECT PUBLICAR_CURSO(3); -- NÃO É PARA DAR CERTO

-- SELECT * FROM CURSO; -- VEJA QUE ELE NÃO ESTÁ DISPONIVEL

--SÓ PARA DEIXAR O CURSO NOVAMENTE DISPONIVEL:
SELECT FROM CRIAR_VIDEO_AULAS (
	9,
	ARRAY ['VIDEO 3'],
	ARRAY ['DESCRICAO 3'],
	ARRAY [15]
);  -- COD_VIDEO_AULA: 28

-- SELECT * FROM CURSO; -- VEJA QUE ELE ESTÁ DISPONIVEL

SELECT FROM PUBLICAR_CURSO(3); -- AGORA VAI DAR CERTO

-- SELECT * FROM CURSO; -- VEJA QUE ELE ESTÁ DISPONIVEL E PUBLICADO

--------------------------------------------------------------------------- COMPRAR_CURSO ---------------------------------------------------------------------------
--(EXECUTE COMO SUPER USUÁRIO)--
--(PARAMENTROS: COD_ALUNO_ANALISADO, COD_CURSO_ANALISADO)--

---- SELECT * FROM ALUNO_CURSO;
---- SELECT * FROM ALUNO_MODULO;

SELECT FROM COMPRAR_CURSO(2, 3); -- NÃO TEM SALDO O SUFICIENTE
SELECT FROM COMPRAR_CURSO(1, 5); -- CURSO AINDA NÃO PUBLICADO
SELECT FROM COMPRAR_CURSO(1, 3);

---- SELECT * FROM ALUNO_CURSO;
---- SELECT * FROM ALUNO_MODULO;

------------------------------------------------------------------------ ASSISTIR_VIDEO_AULA ------------------------------------------------------------------------
--(EXECUTE COMO SUPER USUÁRIO)--
--(PARAMENTROS: CODIGO_ALUNO, CODIGO_VIDEO_AULA)--

---- SELECT * FROM ALUNO_VIDEO_ASSISTIDO;

SELECT FROM ASSISTIR_VIDEO_AULA(2, 10); -- NÃO É PARA DAR CERTO POIS ESSE ALUNO NÃO ESTÁ NO CURSO
SELECT FROM ASSISTIR_VIDEO_AULA(1, 12); -- NÃO É PARA DAR CERTO POIS ESSE ALUNO NÃO TEM ACESSO AO MÓDULO DESSA VIDEO_AULA
SELECT FROM ASSISTIR_VIDEO_AULA(1, 1);

---- SELECT * FROM ALUNO_VIDEO_ASSISTIDO;

---- AGORA VAMOS ATIVAR ALGUNS MODULOS A PARTIR DO PRE_REQUISITO BATENDO A META DE ASSISTIR 60% DAS VIDEO_AULAS DELE (NESSE CASO O
---- MODULO 1 TEM 9 VIDEOAULAS, BASTA ASSISTIR 6, LEMBRANDO QUE O ALUNO 1 JÁ ASSISTIU 1):

---- SELECT * FROM MODULO;
---- SELECT * FROM PRE_REQUISITO;

-- PRECISAMOS QUE UM OUTRO ALUNO COMPRE O CURSO SÓ PARA VER SE UM ALUNO INFLUENCIA DE ALGUM MODO NO OUTRO
SELECT FROM COMPRAR_CURSO(5, 3);

---- SELECT * FROM ALUNO;
---- SELECT * FROM ALUNO_VIDEO_ASSISTIDO;
---- SELECT * FROM ALUNO_MODULO;

SELECT FROM ASSISTIR_VIDEO_AULA(1, 2);
SELECT FROM ASSISTIR_VIDEO_AULA(1, 3);
SELECT FROM ASSISTIR_VIDEO_AULA(1, 4);
SELECT FROM ASSISTIR_VIDEO_AULA(1, 5);

---- SELECT * FROM ALUNO_MODULO; -- AINDA NÃO BATEMOS A META PARA O ALUNO 1

SELECT FROM ASSISTIR_VIDEO_AULA(5, 1);
SELECT FROM ASSISTIR_VIDEO_AULA(5, 2);
SELECT FROM ASSISTIR_VIDEO_AULA(5, 3);

---- SELECT * FROM ALUNO_MODULO; -- ASSISTIMOS AULAS MAS AINDA NÃO BATEMOS A META PARA O ALUNO 5 E ISSO NÃO INFLUENCIA NO 1

SELECT FROM ASSISTIR_VIDEO_AULA(1, 6);

---- SELECT * FROM ALUNO_MODULO; -- BATEMOS A META DO MODULO 1 ESPECIFICADAMENTE PARA O ALUNO 1, E AGORA O MODULO 2 FICA ACESSIVEL PARA ELE

-------------------------------------------------------------------------- RECEBER_SALARIO --------------------------------------------------------------------------
--(PARAMENTROS: COD_PROFESSOR_ANALISADO)--

---- SELECT * FROM PROFESSOR; -- NÃO HOUVERAM ALTERAÇÕES NO SALDO

-- VAMOS FAZER UM OUTRO CURSO DO MESMO PROFESSOR SER COMPRADO E OUTRO CURSO DE OUTRO PROFESSOR
UPDATE CURSO SET DISPONIBILIDADE=TRUE WHERE COD_CURSO IN (1, 5); UPDATE CURSO SET PUBLICADO=TRUE WHERE COD_CURSO IN (1, 5); -- SÓ PARA PODERMOS COMPRAR O CURSO ....
SELECT FROM COMPRAR_CURSO(5, 5); -- O CURSO 5 TAMBÉM É DO PROFESSOR 3, ELE DEVE RECEBER O SALARIO POR ESSE CURSO TAMBÉM
SELECT FROM COMPRAR_CURSO(5, 1); -- O CURSO 1 É DO PROFESSOR 1, ENTÃO O PROFESSOR 3 NÃO DEVE RECEBER O SALÁRIO

-- SÓ PARA O PROFESSOR PEGAR UM INTERVALO EM QUE ELE POSSA RECEBER O DINHEIRO ....
UPDATE ALUNO_CURSO SET DATA_COMPRA = '2019-12-01'; UPDATE PROFESSOR SET DATA_ULTIMO_PAGAMENTO = '2018-07-01';

---- SELECT * FROM PROFESSOR;
---- SELECT * FROM ALUNO_CURSO;
---- SELECT * FROM CURSO;

SELECT FROM RECEBER_SALARIO(3);

---- SELECT * FROM PROFESSOR; -- AGORA O PROFESSOR 3 GANHOU O SALÁRIO DOS SEUS CURSOS QUE FORAM COMPRADOS.

--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! --
-- FAÇA UM UPDATE ALUNO_CURSO SET DATA_COMPRA = '2020-01-25', MAS COLOCANDO UMA DATA PRÓXIMA À QUE VOCÊ ESTÁ EXECUTANDO, PARA O ALUNO NÃO EXPIRAR DATA DE CURSAR.
--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! --

------------------------------------------------------------------- SUBMETER_RESPOSTA_DE_QUESTAO --------------------------------------------------------------------
--(PARAMENTROS: COD_ALUNO_ANALISADO, COD_QUESTAO_SUBMETIDA, RESPOSTA_ALUNO_SUBMETIDA)--

---- SELECT * FROM QUESTAO_ALUNO;

SELECT FROM SUBMETER_RESPOSTA_DE_QUESTAO(1, 1, 'O RESULTADO É 3'); -- COD_QUESTAO_ALUNO: 1
SELECT FROM SUBMETER_RESPOSTA_DE_QUESTAO(1, 2, 'O RESULTADO É 10'); -- COD_QUESTAO_ALUNO: 2
SELECT FROM SUBMETER_RESPOSTA_DE_QUESTAO(1, 3, 'O RESULTADO É 5'); -- COD_QUESTAO_ALUNO: 3
SELECT FROM SUBMETER_RESPOSTA_DE_QUESTAO(5, 1, 'O RESULTADO É 5'); -- COD_QUESTAO_ALUNO: 4
SELECT FROM SUBMETER_RESPOSTA_DE_QUESTAO(1, 8, 'O RESULTADO É 3'); -- NÃO DÁ CERTO POIS O ALUNO NÃO TEM ACESSO ÀS QUESTÕES DESSE MÓDULO

---- SELECT * FROM QUESTAO_ALUNO;

-------------------------------------------------------------------- LISTAR_QUESTOES_DOS_ALUNOS ---------------------------------------------------------------------
--(PARAMENTROS: CODIGO_PROFESSOR)--

---- SELECT * FROM QUESTAO_ALUNO;

SELECT LISTAR_QUESTOES_DOS_ALUNOS(3);

---- SELECT * FROM QUESTAO_ALUNO;

------------------------------------------------------------------------- CORRIGIR_QUESTAO --------------------------------------------------------------------------
--(PARAMENTROS: COD_QUESTAO_ALUNO_CORRIGIDA, RESPOSTA_CORRETA_INSERIDA)--

---- SELECT * FROM QUESTAO_ALUNO;

SELECT FROM CORRIGIR_QUESTAO(1, 'CORRETA');
SELECT FROM CORRIGIR_QUESTAO(2, 'INCORRETA');
SELECT FROM CORRIGIR_QUESTAO(3, 'CORRETA');
SELECT FROM CORRIGIR_QUESTAO(4, 'ERROU'); -- NÃO VAI SER ACEITO.
SELECT FROM CORRIGIR_QUESTAO(4, 'INCORRETA');

---- SELECT * FROM QUESTAO_ALUNO;

--------------------------------------------------------------------------- AVALIAR_CURSO ---------------------------------------------------------------------------
--(PARAMENTROS: COD_ALUNO_CURSO_ANALISADO, NOTA_AVALIACAO_ANALISADA)--

---- SELECT * FROM ALUNO_CURSO;

SELECT FROM AVALIAR_CURSO(1, 10); -- NÃO DÁ CERTO
SELECT FROM AVALIAR_CURSO(1, 4);
SELECT FROM AVALIAR_CURSO(2, 3);

---- SELECT * FROM ALUNO_CURSO;

