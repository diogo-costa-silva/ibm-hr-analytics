este é o primeiro projeto inserido no curso que estou a fazer na Cegid Academy de Data Analytics.

inicialmente o nosso formador deu-nos um ficheiro csv do kaggle https://www.kaggle.com/datasets/pavansubhasht/ibm-hr-analytics-attrition-dataset que é o @data/csv_original_projeto_1.csv .

na página do kaggle podemos ver que o dataset tem 1470 linhas e 35 colunas.

eis a descrição do que aparece na página do dataset:

About Dataset
Uncover the factors that lead to employee attrition and explore important questions such as ‘show me a breakdown of distance from home by job role and attrition’ or ‘compare average monthly income by education and attrition’. This is a fictional data set created by IBM data scientists.

Education
1 'Below College'
2 'College'
3 'Bachelor'
4 'Master'
5 'Doctor'

EnvironmentSatisfaction
1 'Low'
2 'Medium'
3 'High'
4 'Very High'

JobInvolvement
1 'Low'
2 'Medium'
3 'High'
4 'Very High'

JobSatisfaction
1 'Low'
2 'Medium'
3 'High'
4 'Very High'

PerformanceRating
1 'Low'
2 'Good'
3 'Excellent'
4 'Outstanding'

RelationshipSatisfaction
1 'Low'
2 'Medium'
3 'High'
4 'Very High'

WorkLifeBalance
1 'Bad'
2 'Good'
3 'Better'
4 'Best'



depois do formador nos ter dado o primeiro csv @data/csv_original_projeto_1.csv , o meu grupo teve uma reunião com ele para um pequeno alinhamento de requisitos iniciais. essas notas estão em @notas_entrevista.md . 


depois, num momento posterior, o formador deu-nos o segundo csv, o @PingPongSurvey.md que supostamente pretende obrigar-nos a comparar a felicidade e satisfação dos colaboradores antes e depois da introdução de uma mesa de ping-pong no escritório.


vamos começar por analisar completamente todos os ficheiros presentes neste repositório, para teres o contexto geral do que o sistema é atualmente e irá ser.

Dado que no curso da Cegid estamos a utilizar máquinas virtuais da Microsoft, e que a máquina virtual que me foi atribuída tem o SQL Server 2022 Developer Edition instalado, vamos utilizar essa base de dados para armazenar os dados e depois criar os relatórios em Power BI e adicionalmente fazer alguns notebooks em sql e R.



O objetivo final é criar a pipeline que o formador pretende que permita analisar os dados de RH da empresa e tomar decisões estratégicas para melhorar a felicidade e satisfação dos colaboradores, bem como atingir a meta de 50% de mulheres em todos os cargos, melhorando tanto a qualidade do departamento de RH como da propria empresa!

Vamos começar esta discussão!
