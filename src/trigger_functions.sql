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
--| ALUNO ENVOLVIDO NAS ALTERAÇÕES NÃO ESTAR CURSANDO; NÃO TER ASSISITDO VIDEOAULAS O SUFICIENTE    |--
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
