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
