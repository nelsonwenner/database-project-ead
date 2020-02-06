<h1 align="center">
  <img src="https://user-images.githubusercontent.com/40550247/72228004-81071600-3581-11ea-9972-1cbe906001ed.png" width="120px" />
</h1>

<h1 align="center">Database project - EAD</h1>

<p align="center">

  <a href="https://github.com/nelsondiaas">
    <img alt="Made by @nelsondiaas" src="https://img.shields.io/badge/made%20by-%40nelsondiaas-%2304D361"> </img>
  </a>

  <a href="https://github.com/ofelipegabriel321">
    <img alt="Made by @ofelipegabriel321" src="https://img.shields.io/badge/made%20by-%40ofelipegabriel321-%2304D361"> </img>
  </a>
  
  <a href="LICENSE">
    <img alt="License" src="https://img.shields.io/badge/license-MIT-%2304D361">
  </a>
  
  <a href="https://github.com/nelsondiaas/database-project-ead/stargazers">
    <img alt="Stargazers" src="https://img.shields.io/github/stars/nelsondiaas/database-project-ead?style=social">
  </a>

</p>

O Projeto Plataforma EAD é um conjunto de comandos SQL que auxilia redes de Ensino à Distância com o fornecimento de um de um modelo básico para a armazenagem e manipulação de dados.

## Require
  * Postgres

## Features
- Suporte de armazenamento, manipulação e utilização de mecanismos de usuários para Alunos e Professores, que possuem diferentes propriedades/possibilidades dentro do sistema;
- Suporte de armazenamento e manipulação de cursos relacionados a um professor;
- Suporte de armazenamento e manipulação de módulos relacionados a um curso, a alunos cursando e a outros módulos pré-requisito;
- Suporte de armazenamento e manipulação de disciplinas relacionados a um módulo;
- Suporte de armazenamento e manipulação de vídeoaulas relacionados a uma disciplina e a alunos que as assistiram;
- Suporte de armazenamento e manipulação de questionários relacionados a uma disciplina;
- Suporte de armazenamento e manipulação de questões relacionados a uma disciplina, a questionários e a alunos que as responderam.

## Project Class Diagram

![Diagrama de Classes - Projeto Plataforma EAD](https://user-images.githubusercontent.com/40550247/73898195-54d07380-4867-11ea-93d0-ac4993f5589b.png)

## Installation

1. Faça o [download do projeto em ZIP](https://github.com/nelsondiaas/database-project-ead/archive/master.zip) ou clone o projeto pelo bash com o comando `$ git clone https://github.com/nelsondiaas/database-project-ead`.
2. Para a instalação de toda a estrutura do banco de dados existem duas opções:
   1. Executar toda parte do arquivo único [main.sql](main.sql) até antes da parte de execuções.
   2. Executar, na seguinte ordem, os aquivos [tables_creation.sql](tables_creation.sql), [auxiliary_functions.sql](auxiliary_functions.sql), [main_functions.sql](main_functions.sql), [user_functions.sql](user_functions.sql), [trigger_functions.sql](trigger_functions.sql), [triggers.sql](triggers.sql) e [groups.sql](groups.sql).

## Usage
É possível a execução dos métodos principais e métodos de usuários desenvolvidos por meio do arquivo [run.sql] (ou a parte execuções no arquivo main.sql) e, claro, a edição manual dos arquivos SQL desses métodos, das tabelas, dos outros métodos e das triggers.

### Principais especificações de funções e triggers:


<details><summary><b>Auxiliary Functions</b></summary><blockquote>


<details><summary><b>ALUNO_AINDA_CURSANDO</b></summary><blockquote>

  ***Verifica se o aluno ainda está cursando o curso.***
  - ***Entrada***:
    - *[int]* código do aluno que se deseja verificar se ainda está cursando;
    - *[int]* código do curso em que essa verificação será direcionada.
  - ***Saída***:
    - *[boolean]* boleano sobre o aluno ainda está cursando o curso.
</details>

<details><summary><b>ALUNO_JA_CURSOU</b></summary><blockquote>

  ***Verifica se o aluno já cursou (e não cursa mais) o curso.***
  - ***Entrada***:
    - *[int]* código do aluno que se deseja verificar se já cursou;
    - *[int]* código do curso em que essa verificação será direcionada.
  - ***Saída***:
    - *[boolean]* boleano sobre o aluno já ter cursado (e não cursar mais) o curso.

</details>

<details><summary><b>VERIFICAR_CPF_USUARIO_JA_REGISTRADO</b></summary><blockquote>

  ***Verifica se existe algum usuário da tabela especificada com o cpf especificado.***
  - ***Entrada***:
    - *[text]* cpf do usuário;
    - *[text]* tabela do usuário.
  - ***Saída***:
    - *[boolean]* booleano sobre existir algum usuário da tabela especificada com o cpf especificado.

</details>

<details><summary><b>VERIFICAR_EMAIL_USUARIO_JA_REGISTRADO</b></summary><blockquote>

  ***Verifica se existe algum usuário da tabela especificada com o email especificado.***
  - ***Entrada***:
    - *[text]* email do usuário;
    - *[text]* tabela do usuário.
  - ***Saída***: [boolean] booleano sobre existir algum usuário da tabela especificada com o email especificado.
</details>

<details><summary><b>VERIFICAR_EXISTENCIA_ALUNOS_CURSANDO</b></summary><blockquote>

  ***Verifica se existe algum aluno cursando o curso especificado.***
  - ***Entrada***:
    - *[int]* código do curso.
  - ***Saída***:
    - *[boolean]* booleano sobre existir algum aluno cursando o curso especificado.
</details>

<details><summary><b>VERIFICAR_POSSIBILIDADE_DELETE_UPDATE_NO_CURSO</b></summary><blockquote>

  ***Aplica casos de exceção caso ocorrer alguma alteração dentro de um curso com ele estando publicado ou com alunos que ainda estão cursando.***
  - ***Entrada***:
    - *[int]* código do curso.
  - ***Casos de exceções***:
    - curso publicado;
    - existência de alunos cursando.

</details>

<details><summary><b>VALIDAR_DISCIPLINA</b></summary><blockquote>
  
  ***Verifica se a disciplina é válida (possui 3 videoaulas).***
  - ***Entrada***:
    - *[int]* código da disciplina.
  - ***Saída***:
    - *[boolean]* booleano sobre a disciplina ser válida.

</details>

<details><summary><b>VALIDAR_MODULO</b></summary><blockquote>

  ***Verifica se o módulo é válido (possui 3 disciplinas válidas).***
  - ***Entrada***:
    - *[int]* código do módulo.
  - ***Saída***:
    - *[boolean]* booleano sobre o módulo ser válido.

</details>

<details><summary><b>VALIDAR_CURSO</b></summary><blockquote>

  ***Verifica se o curso é válido (possui 3 módulos válidos).***
  - ***Entrada***:
    - *[int]* código do curso.
  - ***Saída***:
    - *[boolean]* booleano sobre o curso ser válido.

</details>

<details><summary><b>CONFIGURAR_ACESSIBILIDADE_ALUNO_MODULO</b></summary><blockquote>

  ***Configura a acessabilidade de um aluno_modulo, adicionando um aluno_modulo para cada módulo do curso. a acessabilidade é configurada como true para os módulos que não possuem pré-requisitos.***
  - ***Entrada***:
    - *[int]* código do aluno;
    - *[int]* código do curso.
</details>

<details><summary><b>VERIFICAR_SUFICIENTE_ASSISTIDO_PARA_AVALIAR</b></summary><blockquote>

  ***Verifica se o aluno assistiu uma quantidade de videoaulas e uma quantidade de tempo suficiente para poder avaliar o curso (consideramos ter assistido 10% do número de vídeoaulas e 15% do tempo de vídeoaulas como o mínimo para isso).***
  - ***Entrada***:
    - *[int]* código do aluno;
    - *[int]* código do curso.
  - ***Saída***:
    - *[boolean]* booleano sobre o aluno poder avaliar o curso.

</details>

<details><summary><b>VERIFICAR_SE_MODULOS_FICAM_ACESSIVEIS</b></summary><blockquote>

  ***Torna acessivel algum(ns) módulo(s) que possuem, como pré-requisito o módulo passado, ficando ele(s) acessível(is) no aluno_modulo.***
  - ***Entrada***:
    - *[int]* código do modulo (que deve ter ficado com a meta_concluida antes de executar essa função) que pode ser pré-requisito para outros módulos; código do aluno que irá passar a ter seus módulos acessíveis.

</details>

<details><summary><b>VERIFICAR_VALIDADE_PRE_REQUISITO</b></summary><blockquote>

  ***Verifica se é válido relacionar um módulo com outro na tabela pré-requisito. ou seja, os módulos não devem entrar em um estado em que um não consiga acessar o outro e vice-versa pois eles têm um ao outro como pré-requisito (impasse de pré-requisito entre módulos).***
  - ***Entrada***:
    - *[int]* código do modulo que será o módulo no pré-requisito;
    - *[int]* código do modulo que será o módulo pré-requisito no pré-requisito.
  - ***Saída***:
    - *[boolean]* booleano sobre a possibilidade dos módulos se associarem entre si na tabela de pré-requisitos.

</details>


</details>


<details><summary><b>Main Functions</b></summary><blockquote>


<details><summary><b>INSERIR_ALUNO_E_PROFESSOR</b></summary><blockquote>

  ***Insere um usuário na sua tabela (existem as possibilidades de inserir aluno e professor).***
  - ***Entrada***:
    - *[text]* nome do usuário;
    - *[text]* cpf do usuário;
    - *[date]* data de nascimento do usuário;
    - *[text]* email do usuário;
    - *[text]* senha do usuário;
    - *[text]* tabela do usuário.

</details>

<details><summary><b>ATUALIZAR_SALDO</b></summary><blockquote>

  ***Atualiza o saldo de um usuário a partir do valor a ser alterado, seu código e tabela.***
  - ***Entrada***:
    - *[float]* valor a ser alterado no saldo do usuário;
    - *[int]* código do usuário;
    - *[text]* nome da tabela do usuário.
  - ***Casos de exceções***:
    - nome da tabela inválido; código de usuário inválido.

</details>

<details><summary><b>RECEBER_SALARIO</b></summary><blockquote>

  ***Faz o professor receber o salário adquirido pelas vendas dos seus curso.***
  - ***Entrada***:
    - *[int]* código do professor que irá receber o salário.
  - ***Casos de exceções***:
    - código de usuário inválido.

</details>

<details><summary><b>COMPRAR_CURSO</b></summary><blockquote>

  ***Realiza a compra do curso: insere ou atualiza o aluno_curso, dependendo se o aluno já cursou o curso.***
  - ***Entrada***:
    - *[int]* código do aluno;
    - *[int]* código do curso.

</details>

<details><summary><b>AVALIAR_CURSO</b></summary><blockquote>

  ***Permite a avaliação do curso por parte do aluno.***
  - ***Entrada***:
    - *[int]* código do aluno_curso;
    - *[float]* nota de avaliação para o curso.

</details>

<details><summary><b>CRIAR_CURSO</b></summary><blockquote>

  ***Cria um curso unido a um professor.***
  - ***Entrada***:
    - *[int]* código do professor;
    - *[text]* nome do curso;
    - *[text]* descrição do curso;
    - *[float]* preço do curso.

</details>

<details><summary><b>PUBLICAR_CURSO</b></summary><blockquote>

  ***Publica o curso.***
  - ***Entrada***:
    - *[int]* código do curso.

</details>

<details><summary><b>CRIAR_MODULOS</b></summary><blockquote>

  ***Cria módulos unidos a um professor.***
  - ***Entrada***:
    - *[int]* código do professor;
    - *[text[]]* nomes dos módulos;
    - *[text[]]* descrições dos módulos.

</details>

<details><summary><b>CRIAR_PRE_REQUISITO</b></summary><blockquote>

  ***Cria um vínculo entre módulos na tabela pré-requisito.***
  - ***Entrada***:
    - *[int]* código do módulo;
    - *[int]* código do módulo pré-requisito.

</details>

<details><summary><b>CRIAR_DISCIPLINAS</b></summary><blockquote>

  ***Cria disciplinas unidas a um módulo.***
  - ***Entrada***:
    - *[int]* código do módulo;
    - *[text[]]* nomes das disciplinas;
    - *[text[]]* descrições das disciplinas.

</details>

<details><summary><b>CRIAR_VIDEO_AULAS</b></summary><blockquote>

  ***Cria videoaulas unidas a disciplinas.***
  - ***Entrada***:
    - *[int]* código da disciplina;
    - *[text[]]* títulos das videoaulas;
    - *[text[]]* descrições das videoaulas;
    - *[int[]]* durações das videoaulas.

</details>

<details><summary><b>ASSISTIR_VIDEO_AULA</b></summary><blockquote>

  ***Faz o aluno assistir à videoaula (faz um vínculo aluno_video_assistido).***
  - ***Entrada***:
    - *[int]* código do aluno;
    - *[int]* código da videoaula.

</details>

<details><summary><b>CRIAR_QUESTAO</b></summary><blockquote>

  ***Cria uma questão unida a uma disciplina.***
  - ***Entrada***:
    - *[int]* código da disciplina;
    - *[text]* texto da questão.

</details>

<details><summary><b>CORRIGIR_QUESTAO</b></summary><blockquote>

  ***Corrige uma questao_aluno com um texto que representa se a resposta está correta.***
  - ***Entrada***:
    - *[int]* código do vínculo questao_aluno corrigido;
    - *[text]* resposta correta inserida.

</details>

<details><summary><b>CRIAR_QUESTIONARIO</b></summary><blockquote>

  ***Cria um questionário unido a uma disciplina.***
  - ***Entrada***:
    - *[int]* nome do questionário;
    - *[int]* código da disciplina.

</details>

<details><summary><b>VINCULAR_QUESTAO_A_QUESTIONARIO</b></summary><blockquote>

  ***Cria um vínculo entre a questão e o questionário na tabela questao_questionario.***
  - ***Entrada***:
    - *[int]* código do questionário vínculado;
    - *[int]* código da questão vinculada.

</details>

<details><summary><b>SUBMETER_RESPOSTA_DE_QUESTAO</b></summary><blockquote>

  ***Faz o aluno submeter uma resposta para uma questão por meio do aluno_questao.***
  - ***Entrada***:
    - *[int]* código do aluno;
    - *[int]* código da questão;
    - *[text]* resposta para a questão.

</details>


</details>


<details><summary><b>Trigger Functions</b></summary><blockquote>


<details><summary><b>CONTROLAR_EVENTOS_USUARIO_BEFORE</b></summary><blockquote>

  ***Faz controle sobre as ações tomadas antes de ocorrer um insert, update ou delete em uma tabela aluno ou professor.***
  - ***Casos de exceções***:
    - idade menor que 18;
    - cpf já registrado anteriormente;
    - email já registrado anteriormente;
    - saldo negativo;
    - alteração de data de nascimento;
    - alteração do email.
  - ***Saída***:
    - *[trigger]*.

</details>

<details><summary><b>CONTROLAR_EVENTOS_ALUNO_AFTER</b></summary><blockquote>

  ***Faz controle sobre as ações tomadas depois de ocorrer um insert, update ou delete em uma tabela aluno. ações: criar um novo usuário no grupo aluno (login role); atualizar a senha do usuário (login role); deletar usuário (login role).***
  - ***Saída***:
    - *[trigger]*.

</details>

<details><summary><b>CONTROLAR_EVENTOS_PROFESSOR_AFTER</b></summary><blockquote>

  ***Faz controle sobre as ações tomadas depois de ocorrer um insert, update ou delete em uma tabela professor. Ações: criar um novo usuário no grupo professor (login role); atualizar a senha do usuário (login role); deletar usuário (login role).***
  - ***Saída***:
    - *[trigger]*.

</details>

<details><summary><b>CONTROLAR_EVENTOS_CURSO_BEFORE</b></summary><blockquote>

  ***Faz controle sobre as ações tomadas antes de ocorrer um insert, update ou delete em uma tabela curso. ações: calcular duração do curso caso necessário.***
  - ***Casos de exceções***:
    - código de professor inválido;
    - curso ser publicado sem ter disponibilidade;
    - código de curso inválido.
  - ***Saída***:
    - *[trigger]*.

</details>

<details><summary><b>CONTROLAR_EVENTOS_ALUNO_CURSO_BEFORE</b></summary><blockquote>

  ***Faz controle sobre as ações tomadas antes de ocorrer um insert, update ou delete em uma tabela aluno_curso. ações: aplicar a cobrança pela compra do curso.***
  - ***Casos de exceções***:
    - código de aluno inválido;
    - código de curso inválido;
    - curso não publicado;
    - aluno envolvido nas alterações não estar cursando;
    - não ter assistido videoaulas o suficiente para poder avaliar o curso;
    - ter uma nota de avaliação fora do intervalo 0~5.
  - ***Saída***:
    - *[trigger]*.

</details>

<details><summary><b>CONTROLAR_EVENTOS_ALUNO_CURSO_AFTER</b></summary><blockquote>

  ***Faz controle sobre as ações tomadas depois de ocorrer um insert, update ou delete em uma tabela aluno_curso.***
  - ***Saída***:
    - *[trigger]*.

</details>

<details><summary><b>CONTROLAR_EVENTOS_MODULO_AFTER</b></summary><blockquote>

  ***Faz controle sobre as ações tomadas depois de ocorrer um insert, update ou delete em uma tabela módulo. ações: incrementar/decrementar o número de módulos; atualizar o publicado e a disponibilidade do curso caso necessário.***
  - ***Saída***:
    - *[trigger]*.

</details>

<details><summary><b>CONTROLAR_EVENTOS_ALUNO_MODULO_AFTER</b></summary><blockquote>

  ***Faz controle sobre as ações tomadas depois de ocorrer um insert, update ou delete em uma tabela aluno_modulo. ações: tornar módulos acessíveis.***
  - ***Saída***:
    - *[trigger]*.

</details>

<details><summary><b>CONTROLAR_EVENTOS_DISCIPLINA_AFTER</b></summary><blockquote>

  ***Faz controle sobre as ações tomadas depois de ocorrer um insert, update ou delete em uma tabela disciplina. ações: atualizar o publicado e a disponibilidade do curso caso necessário.***
  - ***Saída***:
    - *[trigger]*.

</details>

<details><summary><b>CONTROLAR_EVENTOS_VIDEO_AULA_AFTER</b></summary><blockquote>

  ***Faz controle sobre as ações tomadas depois de ocorrer um insert, update ou delete em uma tabela disciplina. ações: atualizar o publicado e a disponibilidade do curso caso necessário.***
  - ***Saída***:
    - *[trigger]*.

</details>

<details><summary><b>CONTROLAR_EVENTOS_ALUNO_VIDEO_ASSISTIDO_AFTER</b></summary><blockquote>

  ***Faz controle sobre as ações tomadas depois de ocorrer um insert, update ou delete em uma tabela aluno_video_assistido. ações: atualizar o booleano que representa que a meta do módulo foi concluída/alcançada, caso necessário.***
  - ***Saída***:
    - *[trigger]*.

</details>


</details>


<details><summary><b>Triggers</b></summary><blockquote>

<details><summary><b>EVENTOS_ALUNO_BEFORE</b></summary><blockquote>

  ***Gatilho para ações tomadas antes de ocorrer um insert, update ou delete em uma tabela aluno.***

</details>

<details><summary><b>EVENTOS_ALUNO_AFTER</b></summary><blockquote>

  ***Gatilho para ações tomadas depois de ocorrer um insert, update ou delete em uma tabela aluno.***

</details>

<details><summary><b>EVENTOS_PROFESSOR_BEFORE</b></summary><blockquote>

  ***Gatilho: para ações tomadas antes de ocorrer um insert, update ou delete em uma tabela professor.***

</details>

<details><summary><b>EVENTOS_PROFESSOR_AFTER</b></summary><blockquote>

  ***Gatilho: para ações tomadas depois de ocorrer um insert, update ou delete em uma tabela professor.***

</details>

<details><summary><b>EVENTOS_CURSO_BEFORE</b></summary><blockquote>

  ***Gatilho: para ações tomadas antes de ocorrer um insert, update ou delete em uma tabela curso.***

</details>

<details><summary><b>EVENTOS_ALUNO_CURSO_BEFORE</b></summary><blockquote>

  ***Gatilho: para ações tomadas depois de ocorrer um insert, update ou delete em uma tabela curso.***  

</details>

<details><summary><b>EVENTOS_ALUNO_CURSO_AFTER</b></summary><blockquote>

  ***Gatilho: para ações tomadas depois de ocorrer um insert, update ou delete em uma tabela aluno_curso.***

</details>

<details><summary><b>EVENTOS_MODULO_AFTER</b></summary><blockquote>

  ***Gatilho: para ações tomadas depois de ocorrer um insert, update ou delete em uma tabela módulo.***

</details>

<details><summary><b>EVENTOS_ALUNO_MODULO_AFTER</b></summary><blockquote>

  ***Gatilho: para ações tomadas depois de ocorrer um insert, update ou delete em uma tabela aluno_modulo.***

</details>

<details><summary><b>EVENTOS_DISCIPLINA_AFTER</b></summary><blockquote>

  ***Gatilho: para ações tomadas depois de ocorrer um insert, update ou delete em uma tabela disciplina.***

</details>

<details><summary><b>EVENTOS_VIDEO_AULA_AFTER</b></summary><blockquote>

  ***Gatilho: para ações tomadas depois de ocorrer um insert, update ou delete em uma tabela videoaula.***

</details>

<details><summary><b>EVENTOS_ALUNO_VIDEO_ASSISTIDO_AFTER</b></summary><blockquote>

  ***Gatilho: para ações tomadas depois de ocorrer um insert, update ou delete em uma tabela aluno_video_assistido.***

</details>



</details>


## License
Este projeto está licenciado sob a licença MIT. Consulte o arquivo [LICENSE](LICENSE) para obter mais detalhes.

---
