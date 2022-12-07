# Introdução

O [Bash](https://www.gnu.org/software/bash/) se torna super poderoso para testes de APIs quando aliado a ferramentas como [curl](https://curl.se/), [httpie](https://httpie.io/) e [jq](https://stedolan.github.io/jq/). Ao escrever código com essa *stack*, você verá que ele é sucinto e eficiente para trabalhar com requisições e respostas na chamada a APIs. Conheça o [bash-api-test](https://github.com/paulojeronimo/bash-api-test), um *framework* que te ajudará nisso.

**NOTA**: Este documento foi convertido (via [pandoc](https://pandoc.org/)) de [AsciiDoc](https://asciidoctor.org/) para [DocBook](https://docbook.org/) e, por fim, para [GitHub Flavored Markdown](https://github.github.com/gfm/) (o formato menos rico desses três). [Essa conversão](https://paulojeronimo.com/posts/bash-test-api/README.md), infelizmente, perde detalhes em formatação e deixa alguns links quebrados. Então, para ver este documento renderizado sem imperfeições, acesse <https://paulojeronimo.com/posts/bash-test-api>.

[Frameworks para teste de APIs](#frameworks-para-teste-de-apis) são numerosos nas linguagens de programação mais apropriadas para este finalidade. Eu confesso que, [Para programadores JavaScript](#para-programadores-javascript) (ou Typescript), alguns *frameworks* ainda podem ser mais simples de serem usados do que esse que estou desenvolvendo. Porém, em se tratando de opções para teste de APIs via linha de comando, e [Para quem gosta de Shell](#para-quem-gosta-de-shell), essas [ferramentas](#ferramentas) são incríveis\!

Quando surgiu-me [a ideia de desenvolver um *framework* que automatiza a execução de testes de APIs](#a-ideia), o que eu queria mesmo era responder a pergunta: **será que eu consigo aprimorar meu conhecimento em Bash enquanto desenvolvo scripts mais simples criar testes usando essas [ferramentas](#ferramentas) que gosto?** Nessa época faltava-me conhecimento em uma peça fundamental para escrever esse *framework*: o [jq](https://stedolan.github.io/jq/). Mas, [desenvolvi minhas habilidades nele](#desenvolvendo-habilidades-no-jq) e, hoje, isso tem sido peça chave na construção do [bash-api-test](https://github.com/paulojeronimo/bash-api-test).

## Minhas motivações na escrita deste framework

1.  **Testes leves e rápidos**.
    
    1.  Até mesmo utilizando o [Termux](https://github.com/termux/termux-app) em meu celular.

<!-- end list -->

1.  **Aprendizado**.  
    Eu posso te garantir que, mesmo desenvolvendo soluções em Bash há vários anos (desde 2007), todo vez que eu crio algo novo com ele eu aprendo, ainda, muito mais. Portanto, meu objetivo na construção desse framework é meu aperfeiçoamento tanto no Bash quanto [nessas ferramentas](#ferramentas) Além disso, eu também espero conseguir te ajudar a entender um pouco mais sobre elas.

## O surgimento da ideia

A ideia de criação deste framework surgiu em Junho de 2020 quando eu criei [um exemplo de como utilizar essas ferramentas](https://github.com/paulojeronimo/spring-boot-api-sample) na utilização de testes automatizados. [Como escrevi](#conhecimento-em-jq), nesse tempo eu não dominava o [jq](https://stedolan.github.io/jq/). Mas, comecei a trabalhar bastante com o ele para fazer testes de integração de APIs com o [Keycloak](https://www.keycloak.org/), uma ferramenta que [já me deu muito trabalho](https://paulojeronimo.com/sitemap/#keycloak) (no bom sentido dessa expressão).

Em fevereiro de 2021, [trabalhei em um projeto na](https://paulojeronimo.com/cv/en/resume.html) [OSO DevOps](https://oso.sh/) no qual aprimorei bastante meu conhecimento no [jq](https://stedolan.github.io/jq/). Para expressar um pouco desse conhecimento de forma pública, e me aprimorar um pouco mais, também [desenvolvi alguns brinquedos](https://github.com/paulojeronimo?tab=repositories&q=jq).

Hoje eu sei o enorme poder que a junção dessas ferramentas oferece e, dessa forma, acho importante compartilhar esse [aprendizado](#aprendizado).

# Tutorial: como testar uma API com o bash-api-test?

Neste primeiro tutorial ([de uma série](#proximos-tutoriais)) eu te mostrarei como testar uma API utilizando o [Bash](https://www.gnu.org/software/bash/) para excutar o [bash-api-test](https://github.com/paulojeronimo/bash-api-test) de duas formas diferentes. A primeira será no seu próprio celular, se ele for um Android. Você fará isso [No Termux](#no-termux).

Outra forma que você poderá executar o [bash-api-test](https://github.com/paulojeronimo/bash-api-test), neste tutorial, será [Via Docker](#via-docker). Em [Próximos Tutoriais](#proximos-tutoriais) eu te explicarei, em detalhes, como escrever seus próprios testes para que eles sejam executados pelo [bash-api-test](https://github.com/paulojeronimo/bash-api-test).

## No Termux

Copie e cole os comandos abaixo em seu shell. Se tiver dúvidas sobre como instalar o Termux ou sobre como executar os comandos abaixo dentro dele, veja [esses vídeos](#videos-termux).

``` bash
source <(curl -sSL https://raw.githubusercontent.com/paulojeronimo/bash-api-test/main/termux-setup.sh) v0.5.0
```

Inicie o script `api-server.sh` em uma nova sessão [tmux](https://github.com/tmux/tmux) com esse comando:

    ./api-server.sh start --with-tmux

Esse comando abrirá o tmux com dois (2) paineis. O de baixo executará o [JSON Server](https://github.com/typicode/json-server) e uma API que testaremos.

No painel de cima você testará essa API através do seguinte comando:

    ./sample-tests.runner.sh

### Vídeos

1.  Instalação do Termux no Android. (← TODO)

2.  Configuração e execução do bash-api-test no Termux. (← TODO)

## Via Docker

Você pode testar o [bash-api-test](https://github.com/paulojeronimo/bash-api-test) se tiver o [Docker](https://www.docker.com/) instalado em sua máquina. Particularmente eu, até o momento, só realizei testes utilizando o Docker que tenho instalado em um sistema operacional Ubuntu e em um macOS. Para utilizar o Windows, você deverá ter o [WSL 2](https://learn.microsoft.com/en-us/windows/wsl/install) instalado executando um Linux (além do Docker) e executar os procedimentos a seguir.

Até mesmo para iniciar este projeto via Docker eu utilizo um script que desenvolvi, em [Bash](https://www.gnu.org/software/bash/), e que chamei de [docker-termux](https://github.com/paulojeronimo/dotfiles/blob/master/.scripts/docker/docker-termux).

O procedimento abaixo é ligeiramente diferente do que eu descrevo no [README.adoc](https://github.com/paulojeronimo/bash-api-test) do projeto (em inglês) e que está publicado também (em HTML) em <https://paulojeronimo.com/bash-api-test/#through-docker>.

Na prática, a forma que eu apresento a execução do projeto a seguir é interessante pois ela não te obriga a ter nenhuma outra ferramenta, além de um Bash (na versão igual ou superior a que vem instalada por padrão no macOS) e do [Docker](https://www.docker.com/). Porém, quem já possui um ambiente de desenvolvimento instalado é beneficiado com o procedimento que descrevi no README.adoc do projeto [bash-api-test](https://github.com/paulojeronimo/bash-api-test).

De qualquer forma, vamos lá:

Baixe o script [docker-termux](https://github.com/paulojeronimo/dotfiles/blob/master/.scripts/docker/docker-termux) em sua máquina e coloque-o em execução (ele criará um contêiner Docker que utilizo para testar, localmente em meu notebook e fora de um Android, minhas aplicações no [Termux](https://github.com/termux/termux-app)):

    $ curl -sSL
    https://raw.githubusercontent.com/paulojeronimo/dotfiles/master/.scripts/docker/docker-termux
    -o docker-termux
    
    $ ./docker-termux

Após obter acesso ao shell do contêiner Docker você pode testar os mesmos passos que descrevo para a execução [No Termux](#no-termux).

### Vídeos

1.  [Desenvolvimento Mobile NÃO CONVENCIONAL utilizando o Termux](https://youtu.be/tZc3jQRC-Cw).

2.  Executando o bash-api-test via docker-termux. (← TODO)

# Frameworks para teste de APIs

## Para programadores JavaScript

  - [Jest](https://jestjs.io/) e [SuperTest](https://github.com/ladjs/supertest)  
    Se você programa em JavaScript (ou TypeScript) e deseja utilizar o Jest unido ao SuperTest, essa é uma ótima opção\! ![smile o](./images/icons/smile-o.png)  
    
    Com eles você terá ainda mais facilidade e rapidez na codificação de testes para APIs.

## Para quem gosta de Shell

  - <https://stackoverflow.com/questions/29042593/rest-api-testing-from-commandline>
    
      - <https://github.com/melezhik/swat>
    
      - <https://github.com/subeshb1/api-test>

# Próximos Tutoriais

O objetivo dessa série de tutoriais é ajudá-lo a conhecer um pouco mais sobre a junção que cola todas as [ferramentas](#ferramentas) no framework [bash-api-test](https://github.com/paulojeronimo/bash-api-test) (o [Bash](https://www.gnu.org/software/bash/)) além de, obviamente, melhorar seus *skills* em todas elas.

Caso deseje ser notificado da criação ou da atualiação desse conteúdo, por favor, assine meu canal no Telegram: <https://t.me/paulojeronimo_com>.
