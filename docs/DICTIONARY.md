# Dicionário de Dados (IBM HR Analytics)

Este documento define formalmente a origem dos dados (Source System) e o significado prático (Regras de Negócio) de cada um dos campos extraídos para o projeto, de modo a garantir que toda a equipa fala a mesma "linguagem" antes de qualquer modelo ou código de Base de Dados ser criado.

## 1. Fonte: `csv_original_projeto_1.csv`
Ficheiro originário do Kaggle, contendo uma fotografia (snapshot) simulada por estatísticos da IBM de 1470 colaboradores ativos e já saídos, contendo variáveis demográficas, financeiras e de satisfação.

| Nome da Coluna | Tipo na Origem | Descrição / Regra de Negócio | Valores Possíveis / Domínio |
| :--- | :--- | :--- | :--- |
| `Age` | Numérico | Idade do colaborador à data do registo do dataset. | Numérico Inteiro. |
| `Attrition` | Texto | **Métrica-Alvo!** Indica se o colaborador deixou a empresa (Atrito/Turnover). | `Yes` (saiu), `No` (ativo) |
| `BusinessTravel` | Texto | A frequência com que o colaborador viaja a trabalho. | `Non-Travel`, `Travel_Rarely`, `Travel_Frequently` |
| `DailyRate` | Numérico | Valor da taxa diária salarial praticada para o colaborador. | Numérico. |
| `Department` | Texto | Secção macro onde o cargo do colaborador se insere. | `Sales`, `Research & Development`, `Human Resources` |
| `DistanceFromHome` | Numérico | Distância reportada de casa ao escritório (milhas/km). | Numérico. |
| `Education` | Numérico | Código do nível de escolaridade formal e grau académico. | `1` 'Below College'<br>`2` 'College'<br>`3` 'Bachelor'<br>`4` 'Master'<br>`5` 'Doctor' |
| `EducationField` | Texto | A área ou o curso principal do nível de educação. | `Life Sciences`, `HR`, `Marketing`, etc. |
| `EmployeeCount` | Numérico | Constante da base de dados de origem. | Sempre `1`. |
| `EmployeeNumber` | Numérico | Número único do registo ou do ID corporativo. | Chave Primária Lógica do CSV. |
| `EnvironmentSatisfaction` | Numérico | Grau de satisfação reportado com o ambiente de trabalho físico e social. | `1` 'Low' a `4` 'Very High' |
| `Gender` | Texto | Identificação de género para os relatórios de paridade. | `Male` ou `Female`. |
| `HourlyRate` | Numérico | Custo à hora para a empresa. | Numérico. |
| `JobInvolvement` | Numérico | Perceção do quão "veste a camisola" ou está focado no trabalho diário. | `1` 'Low' a `4` 'Very High' |
| `JobLevel` | Numérico | Grau numérico de responsabilidade (Junior vs Senior). | 1 a 5. |
| `JobRole` | Texto | Título oficial do cargo. | `Sales Executive`, `Laboratory Technician`, etc. |
| `JobSatisfaction` | Numérico | Grau de satisfação geral com o papel desempenhado. | `1` 'Low' a `4` 'Very High' |
| `MaritalStatus` | Texto | Estado civil atual. | `Single`, `Married`, `Divorced` |
| `MonthlyIncome` | Numérico | Salário base mensal bruto. | Numérico. |
| `MonthlyRate` | Numérico | Métrica complementar financeira originária da IBM. | Numérico. |
| `NumCompaniesWorked` | Numérico | Número de empregadores passados antes da IBM. | Numérico de 0 a X. |
| `Over18` | Texto | Validação legal se possui maioridade. | Sempre `Y`. |
| `OverTime` | Texto | Indicador se a pessoa em questão trabalha habitualmente horas extra. | `Yes` ou `No`. |
| `PercentSalaryHike` | Numérico | Qual o incremento % obtido no último aumento salarial verificado. | Numérico %. |
| `PerformanceRating` | Numérico | Nota oficial de avaliação global do ano transato. | `1` 'Low'<br>`2` 'Good'<br>`3` 'Excellent'<br>`4` 'Outstanding' |
| `RelationshipSatisfaction` | Numérico | Grau de satisfação nas relações de chefia/equipa. | `1` 'Low' a `4` 'Very High' |
| `StandardHours` | Numérico | Teto oficial de horas consideradas "Standard" no pacote de trabalho. | Sempre `80`. |
| `StockOptionLevel` | Numérico | Nível descritivo do pacote de ações detidas pelo colaborador. | 0 a 3. |
| `TotalWorkingYears` | Numérico | Experiência de trabalho ativa total na vida da pessoa. | Numérico inteiro. |
| `TrainingTimesLastYear` | Numérico | Quantas formações completadas no último período fiscalizado. | Numérico inteiro. |
| `WorkLifeBalance` | Numérico | Quão bem a pessoa sente que alinha a vida privada à corporativa. | `1` 'Bad'<br>`2` 'Good'<br>`3` 'Better'<br>`4` 'Best' |
| `YearsAtCompany` | Numérico | Longevidade contínua na casa atual da IBM. | Numérico inteiro. |
| `YearsInCurrentRole` | Numérico | Consecutividade de anos sem mudar o `JobRole`. | Numérico inteiro. |
| `YearsSinceLastPromotion` | Numérico | Quantidade de anos retidos no mesmo nível sem promoção formal atestada. | Numérico inteiro. |
| `YearsWithCurrManager` | Numérico | Anos em que está subordinado ininterruptamente à mesma pessoa de hierarquia superior. | Numérico inteiro. |

---

## 2. Fonte: `PingPongSurvey.csv`
Um segundo inquérito transacional efetuado aos mesmos colaboradores (ou a um subset), pós-implementação de uma mesa comunitária de distração e bem-estar. Serve para análise comparativa ('Antes' vs 'Depois').

| Nome da Coluna | Tipo na Origem | Descrição / Regra de Negócio | Domínio |
| :--- | :--- | :--- | :--- |
| `Datasurvey` | Data (Texto) | Registo temporal explícito do momento da submissão desde este novo inquérito! | Formato data do sistema. |
| `EmployeeNumber` | Numérico | A chave única inter-ficheiros que permite cruzar a demografia do "quem votou" com a avaliação no tempo. | Chave Estrangeira do CSV 1. |
| `EnvironmentSatisfaction` | Numérico | Nova votação de ambiente pós "evento de Ping Pong". | `1` a `4` |
| `JobInvolvement` | Numérico | Nova votação de envolvimento prático com causa e local. | `1` a `4` |
| `JobSatisfaction` | Numérico | Nova nota de satisfação de papel. | `1` a `4` |
| `RelationshipSatisfaction` | Numérico | Nova nota que demonstra se o ping pong uniu ou dividiu os colegas. | `1` a `4` |
| `WorkLifeBalance` | Numérico | Votação de como os breakos de jogo afetam o escape mental à pressão. | `1` a `4` |
