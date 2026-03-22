# ==============================================================================
# PROJETO IBM HR ANALYTICS — Análise Exploratória de Dados (EDA)
# Cegid Academy — Data Analytics
# ==============================================================================
# Este script segue a etapa 3 do projeto: análise estatística descritiva
# com visualizações (histogramas, boxplots, correlações).
#
# Estrutura:
#   PARTE 1 — Setup e Carregamento
#   PARTE 2 — Limpeza Inicial (remover colunas constantes)
#   PARTE 3 — Estatísticas Descritivas
#   PARTE 4 — Visualizações: Distribuições (Histogramas + Boxplots)
#   PARTE 5 — Visualizações: Categóricas (Bar Plots)
#   PARTE 6 — Correlações
#   PARTE 7 — Análise de Attrition
#   PARTE 8 — Comparação Antes vs Depois (Ping Pong Survey)
# ==============================================================================





# =============================================================================
# PARTE 0 — Setup do ambiente
# =============================================================================

getwd()

list.files()

setwd("C:/Users/diogosilva/Documents/DCS_local/IBM_HR_Analytics/")
setwd("C:/Mac/Home/Documents/DCS_local/IBM_HR_Analytics")

list.files()

list.files("data/")



# =============================================================================
# PARTE 1 — Setup e Carregamento dos Dados
# =============================================================================

# Instalar pacotes se necessário (descomentar na primeira execução)
install.packages(c("tidyverse", "corrplot", "gridExtra", "scales"))

library(tidyverse)   # dplyr, ggplot2, tidyr, readr, etc.
library(corrplot)    # Matriz de correlações visual
library(gridExtra)   # Combinar múltiplos gráficos
library(scales)      # Formatação de eixos (percentagens, etc.)

# --- Carregar os dados ---
# IMPORTANTE: ajustar o caminho para a tua VM
# No Windows da VM será algo como:
#   "C:/Users/<user>/Documents/DCS_local/IBM HR Analytics/data/csv_original_projeto_1.csv"
# Aqui usamos um caminho relativo assumindo que o working directory é a pasta do projeto

df_original <- read_csv("data/csv_original_projeto_1.csv")
df_survey   <- read_csv("data/PingPongSurvey.csv")

# Verificação rápida
cat("=== CSV Original ===\n")
cat("Dimensões:", nrow(df_original), "linhas x", ncol(df_original), "colunas\n")
cat("\n=== Ping Pong Survey ===\n")
cat("Dimensões:", nrow(df_survey), "linhas x", ncol(df_survey), "colunas\n")

# Inspecionar estrutura
glimpse(df_original)
glimpse(df_survey)


# =============================================================================
# PARTE 2 — Limpeza Inicial
# =============================================================================
# O formador referiu na dica 3: "tirar todas as variáveis com desvio padrão zero"
# e na dica 11: "remover coluna count"
#
# Porquê? Colunas com desvio padrão zero são constantes — não trazem
# informação analítica porque todos os valores são iguais.
# É como ter uma coluna "País" onde todos os registos dizem "Portugal".

# Identificar colunas numéricas com desvio padrão zero
colunas_numericas <- df_original %>%
  select(where(is.numeric)) %>%
  names()

colunas_constantes <- colunas_numericas[
  sapply(df_original[colunas_numericas], sd, na.rm = TRUE) == 0
]

cat("\nColunas com desvio padrão zero (constantes):\n")
for (col in colunas_constantes) {
  cat("  -", col, "= valor constante:", unique(df_original[[col]]), "\n")
}

# Adicionamos Over18 que também é constante (sempre "Y"), embora seja texto
cat("  - Over18 = valor constante: Y\n")

# Remover as colunas constantes
df <- df_original %>%
  select(-EmployeeCount, -StandardHours, -Over18)

cat("\nApós limpeza:", ncol(df), "colunas (removidas", 
    ncol(df_original) - ncol(df), ")\n")





shell("cls")






# =============================================================================
# PARTE 3 — Estatísticas Descritivas
# =============================================================================
# O formador pede: médias, medianas, desvio padrão, distribuição das variáveis

# --- 3.1 Resumo das variáveis numéricas ---
resumo_numerico <- df %>%
  select(where(is.numeric), -EmployeeNumber) %>%
  pivot_longer(everything(), names_to = "variavel", values_to = "valor") %>%
  group_by(variavel) %>%
  summarise(
    n        = n(),
    media    = round(mean(valor, na.rm = TRUE), 2),
    mediana  = median(valor, na.rm = TRUE),
    desvio   = round(sd(valor, na.rm = TRUE), 2),
    minimo   = min(valor, na.rm = TRUE),
    maximo   = max(valor, na.rm = TRUE),
    q1       = quantile(valor, 0.25, na.rm = TRUE),
    q3       = quantile(valor, 0.75, na.rm = TRUE),
    .groups  = "drop"
  ) %>%
  arrange(variavel)

print(resumo_numerico, n = 30)

# --- 3.2 Resumo das variáveis categóricas ---
cat("\n=== Variáveis Categóricas ===\n")

variaveis_cat <- df %>%
  select(where(is.character)) %>%
  names()

for (col in variaveis_cat) {
  cat("\n", col, ":\n")
  freq <- table(df[[col]])
  prop <- round(prop.table(freq) * 100, 1)
  for (i in seq_along(freq)) {
    cat("  ", names(freq)[i], ":", freq[i], "(", prop[i], "%)\n")
  }
}

# --- 3.3 Dados Ausentes (Missing Values) ---
cat("\n=== Verificação de Dados Ausentes ===\n")
total_na <- sum(is.na(df))
cat("Total de valores NA no dataset:", total_na, "\n")

if (total_na > 0) {
  na_por_coluna <- colSums(is.na(df))
  print(na_por_coluna[na_por_coluna > 0])
} else {
  cat("Sem dados ausentes — dataset completo!\n")
}

# --- 3.4 Observação sobre PerformanceRating ---
# IMPORTANTE: PerformanceRating só contém valores 3 e 4
# Embora a escala vá de 1 a 4, nenhum colaborador tem rating 1 (Low) ou 2 (Good)
# Isto é relevante para a apresentação — pode indicar que:
#   a) A empresa é generosa nas avaliações
#   b) Os critérios de avaliação não diferenciam bem (inflação de ratings)
#   c) Quem tinha ratings baixos já saiu (survivorship bias)
cat("\n=== Nota sobre PerformanceRating ===\n")
cat("Distribuição:\n")
print(table(df$PerformanceRating))
cat("Apenas valores 3 (Excellent) e 4 (Outstanding) — sem ratings 1 ou 2!\n")



shell("cls")


# =============================================================================
# PARTE 4 — Visualizações: Distribuições
# =============================================================================
# O formador pediu: Histogramas e Boxplots
# Dica do formador: "Box plots - level, cargo, income" e "o salário e o level estão relacionados"

# --- 4.1 Histograma de Idade ---
p_age_hist <- ggplot(df, aes(x = Age)) +
  geom_histogram(binwidth = 2, fill = "#4472C4", color = "white", alpha = 0.8) +
  labs(title = "Distribuição de Idade dos Colaboradores",
       x = "Idade", y = "Contagem") +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14))

# --- 4.2 Histograma de MonthlyIncome ---
p_income_hist <- ggplot(df, aes(x = MonthlyIncome)) +
  geom_histogram(binwidth = 1000, fill = "#4472C4", color = "white", alpha = 0.8) +
  labs(title = "Distribuição do Salário Mensal",
       x = "Salário Mensal (Monthly Income)", y = "Contagem") +
  scale_x_continuous(labels = comma) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14))

# Mostrar lado a lado
grid.arrange(p_age_hist, p_income_hist, ncol = 2)

# --- 4.3 Boxplot: MonthlyIncome por JobLevel ---
# Esta é a relação que o formador referiu: salário e level estão relacionados
p_income_level <- ggplot(df, aes(x = factor(JobLevel), y = MonthlyIncome, 
                                  fill = factor(JobLevel))) +
  geom_boxplot(alpha = 0.7, outlier.color = "red", outlier.size = 2) +
  scale_fill_brewer(palette = "Blues") +
  labs(title = "Salário Mensal por Job Level",
       subtitle = "Há uma relação clara entre level e salário",
       x = "Job Level", y = "Salário Mensal") +
  scale_y_continuous(labels = comma) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14),
        legend.position = "none")

print(p_income_level)

# --- 4.4 Boxplot: MonthlyIncome por JobRole ---
p_income_role <- ggplot(df, aes(x = reorder(JobRole, MonthlyIncome, FUN = median), 
                                 y = MonthlyIncome)) +
  geom_boxplot(fill = "#4472C4", alpha = 0.7, outlier.color = "red") +
  labs(title = "Salário Mensal por Cargo",
       x = "", y = "Salário Mensal") +
  scale_y_continuous(labels = comma) +
  coord_flip() +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14))

print(p_income_role)

# --- 4.5 Boxplot: Idade por Department ---
p_age_dept <- ggplot(df, aes(x = Department, y = Age, fill = Department)) +
  geom_boxplot(alpha = 0.7) +
  scale_fill_manual(values = c("#4472C4", "#ED7D31", "#70AD47")) +
  labs(title = "Distribuição de Idade por Departamento",
       x = "", y = "Idade") +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14),
        legend.position = "none")

print(p_age_dept)

# --- 4.6 Histograma de YearsAtCompany ---
p_years_hist <- ggplot(df, aes(x = YearsAtCompany)) +
  geom_histogram(binwidth = 1, fill = "#4472C4", color = "white", alpha = 0.8) +
  labs(title = "Distribuição de Anos na Empresa",
       x = "Anos na Empresa", y = "Contagem") +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14))

print(p_years_hist)


# =============================================================================
# PARTE 5 — Visualizações: Categóricas (Bar Plots)
# =============================================================================

# --- 5.1 Distribuição por Departamento ---
p_dept <- ggplot(df, aes(x = reorder(Department, Department, function(x) -length(x)))) +
  geom_bar(fill = "#4472C4", alpha = 0.8) +
  geom_text(stat = "count", aes(label = after_stat(count)), vjust = -0.5, size = 3.5) +
  labs(title = "Colaboradores por Departamento",
       x = "", y = "Contagem") +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14))

# --- 5.2 Distribuição por Género ---
p_gender <- ggplot(df, aes(x = Gender, fill = Gender)) +
  geom_bar(alpha = 0.8) +
  geom_text(stat = "count", aes(label = paste0(after_stat(count), "\n(",
            round(after_stat(count)/nrow(df)*100, 1), "%)")), 
            vjust = -0.3, size = 3.5) +
  scale_fill_manual(values = c("Female" = "#ED7D31", "Male" = "#4472C4")) +
  geom_hline(yintercept = nrow(df) / 2, linetype = "dashed", color = "red", linewidth = 0.8) +
  annotate("text", x = 2.4, y = nrow(df)/2 + 30, label = "Meta 50%", 
           color = "red", size = 3.5, fontface = "italic") +
  labs(title = "Distribuição por Género",
       subtitle = "Meta: 50% mulheres em todos os cargos",
       x = "", y = "Contagem") +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14),
        legend.position = "none")

grid.arrange(p_dept, p_gender, ncol = 2)

# --- 5.3 Género por Departamento (stacked bar) ---
p_gender_dept <- df %>%
  count(Department, Gender) %>%
  group_by(Department) %>%
  mutate(pct = n / sum(n) * 100) %>%
  ggplot(aes(x = Department, y = pct, fill = Gender)) +
  geom_col(alpha = 0.8) +
  geom_text(aes(label = paste0(round(pct, 1), "%")), 
            position = position_stack(vjust = 0.5), size = 3.5) +
  geom_hline(yintercept = 50, linetype = "dashed", color = "red", linewidth = 0.8) +
  scale_fill_manual(values = c("Female" = "#ED7D31", "Male" = "#4472C4")) +
  labs(title = "Proporção de Género por Departamento",
       subtitle = "Linha vermelha = meta de 50%",
       x = "", y = "Percentagem (%)") +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14))

print(p_gender_dept)

# --- 5.4 Attrition Rate ---
p_attrition <- df %>%
  count(Attrition) %>%
  mutate(pct = n / sum(n) * 100) %>%
  ggplot(aes(x = Attrition, y = n, fill = Attrition)) +
  geom_col(alpha = 0.8) +
  geom_text(aes(label = paste0(n, " (", round(pct, 1), "%)")), vjust = -0.3, size = 4) +
  scale_fill_manual(values = c("No" = "#70AD47", "Yes" = "#C00000")) +
  labs(title = "Taxa de Attrition (Turnover)",
       subtitle = paste0("Attrition Rate: ", 
                         round(sum(df$Attrition == "Yes") / nrow(df) * 100, 1), "%"),
       x = "", y = "Contagem") +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14),
        legend.position = "none")

print(p_attrition)

# --- 5.5 Distribuição por JobRole ---
p_jobrole <- ggplot(df, aes(x = reorder(JobRole, JobRole, function(x) length(x)))) +
  geom_bar(fill = "#4472C4", alpha = 0.8) +
  geom_text(stat = "count", aes(label = after_stat(count)), hjust = -0.2, size = 3.5) +
  labs(title = "Colaboradores por Cargo", x = "", y = "Contagem") +
  coord_flip() +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14))

print(p_jobrole)

# --- 5.6 Satisfação (todas as variáveis de satisfação num só gráfico) ---
satisfacao_vars <- c("EnvironmentSatisfaction", "JobSatisfaction", 
                     "JobInvolvement", "RelationshipSatisfaction", "WorkLifeBalance")

df_satisfacao <- df %>%
  select(all_of(satisfacao_vars)) %>%
  pivot_longer(everything(), names_to = "Metrica", values_to = "Score") %>%
  mutate(
    Score_Label = case_when(
      Score == 1 ~ "1 - Low",
      Score == 2 ~ "2 - Medium",
      Score == 3 ~ "3 - High",
      Score == 4 ~ "4 - Very High"
    ),
    Metrica = str_replace_all(Metrica, "([a-z])([A-Z])", "\\1 \\2")  # CamelCase -> espaços
  )

p_satisfacao <- ggplot(df_satisfacao, aes(x = factor(Score), fill = factor(Score))) +
  geom_bar(alpha = 0.8) +
  facet_wrap(~ Metrica, scales = "free_y", ncol = 3) +
  scale_fill_manual(values = c("1" = "#C00000", "2" = "#ED7D31", 
                                "3" = "#FFC000", "4" = "#70AD47"),
                    labels = c("Low", "Medium", "High", "Very High")) +
  labs(title = "Distribuição das Variáveis de Satisfação (Antes do Ping Pong)",
       x = "Score", y = "Contagem", fill = "Nível") +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14))

print(p_satisfacao)


# =============================================================================
# PARTE 6 — Correlações
# =============================================================================
# O formador referiu na dica 8: "não precisamos de R para mostrar correlações 
# antes e depois da mesa de ping pong" — mas SIM precisamos de R para a 
# análise exploratória geral!

# --- 6.1 Matriz de correlação das variáveis numéricas ---
# Selecionar apenas colunas numéricas relevantes (excluir IDs e constantes)
df_corr <- df %>%
  select(where(is.numeric), -EmployeeNumber) %>%
  cor(use = "complete.obs")

# Visualizar a matriz
# method = "color" para heatmap, order = "hclust" para agrupar variáveis semelhantes
corrplot(df_corr, 
         method = "color", 
         type = "upper", 
         order = "hclust",
         tl.col = "black", 
         tl.cex = 0.7,
         col = colorRampPalette(c("#C00000", "white", "#4472C4"))(200),
         title = "Matriz de Correlação — Variáveis Numéricas",
         mar = c(0, 0, 2, 0),
         addCoef.col = "black",
         number.cex = 0.5)

# --- 6.2 Correlações mais fortes (top 10) ---
# Transformar a matriz em formato longo para extrair os pares mais correlacionados
cor_long <- as.data.frame(as.table(df_corr)) %>%
  filter(Var1 != Var2) %>%                  # remover diagonal
  mutate(abs_corr = abs(Freq)) %>%
  arrange(desc(abs_corr)) %>%
  filter(!duplicated(abs_corr)) %>%         # remover duplicados (A-B = B-A)
  head(10)

cat("\n=== Top 10 Correlações Mais Fortes ===\n")
for (i in 1:nrow(cor_long)) {
  cat(sprintf("  %s <-> %s : r = %.3f\n", 
              cor_long$Var1[i], cor_long$Var2[i], cor_long$Freq[i]))
}


# =============================================================================
# PARTE 7 — Análise de Attrition (Turnover)
# =============================================================================
# Attrition é a métrica-alvo do dataset! Vamos ver o que distingue quem sai

# --- 7.1 Attrition por Departamento ---
p_attr_dept <- df %>%
  count(Department, Attrition) %>%
  group_by(Department) %>%
  mutate(pct = n / sum(n) * 100) %>%
  filter(Attrition == "Yes") %>%
  ggplot(aes(x = reorder(Department, pct), y = pct, fill = Department)) +
  geom_col(alpha = 0.8) +
  geom_text(aes(label = paste0(round(pct, 1), "%")), hjust = -0.2, size = 4) +
  scale_fill_manual(values = c("#4472C4", "#ED7D31", "#70AD47")) +
  labs(title = "Taxa de Attrition por Departamento",
       x = "", y = "Attrition Rate (%)") +
  coord_flip() +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14),
        legend.position = "none")

print(p_attr_dept)

# --- 7.2 Attrition por OverTime ---
p_attr_ot <- df %>%
  count(OverTime, Attrition) %>%
  group_by(OverTime) %>%
  mutate(pct = n / sum(n) * 100) %>%
  filter(Attrition == "Yes") %>%
  ggplot(aes(x = OverTime, y = pct, fill = OverTime)) +
  geom_col(alpha = 0.8, width = 0.5) +
  geom_text(aes(label = paste0(round(pct, 1), "%")), vjust = -0.3, size = 4) +
  scale_fill_manual(values = c("No" = "#70AD47", "Yes" = "#C00000")) +
  labs(title = "Attrition Rate: OverTime vs Non-OverTime",
       x = "Trabalha Horas Extra?", y = "Attrition Rate (%)") +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14),
        legend.position = "none")

print(p_attr_ot)

# --- 7.3 Comparação de médias: quem saiu vs quem ficou ---
comparacao <- df %>%
  group_by(Attrition) %>%
  summarise(
    Media_Idade              = round(mean(Age), 1),
    Media_Salario            = round(mean(MonthlyIncome), 0),
    Media_AnosEmpresa        = round(mean(YearsAtCompany), 1),
    Media_DistanciaCasa      = round(mean(DistanceFromHome), 1),
    Media_AnosSemPromocao    = round(mean(YearsSinceLastPromotion), 1),
    Media_SatisfacaoAmbiente = round(mean(EnvironmentSatisfaction), 2),
    Media_SatisfacaoTrabalho = round(mean(JobSatisfaction), 2),
    Media_WorkLifeBalance    = round(mean(WorkLifeBalance), 2),
    Pct_OverTime             = round(mean(OverTime == "Yes") * 100, 1),
    .groups = "drop"
  )

cat("\n=== Comparação: Quem saiu vs Quem ficou ===\n")
print(as.data.frame(comparacao))

# --- 7.4 Attrition por JobLevel ---
p_attr_level <- df %>%
  count(JobLevel, Attrition) %>%
  group_by(JobLevel) %>%
  mutate(pct = n / sum(n) * 100) %>%
  filter(Attrition == "Yes") %>%
  ggplot(aes(x = factor(JobLevel), y = pct)) +
  geom_col(fill = "#C00000", alpha = 0.8, width = 0.5) +
  geom_text(aes(label = paste0(round(pct, 1), "%")), vjust = -0.3, size = 4) +
  labs(title = "Attrition Rate por Job Level",
       subtitle = "Níveis mais baixos têm maior turnover",
       x = "Job Level", y = "Attrition Rate (%)") +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14))

print(p_attr_level)


# =============================================================================
# PARTE 8 — Comparação Antes vs Depois do Ping Pong
# =============================================================================
# O PingPongSurvey tem 1233 respostas — exatamente os colaboradores ativos
# (Attrition = "No"). Quem saiu da empresa (237 pessoas) não respondeu.
#
# PONTO ANALÍTICO IMPORTANTE (dica 10 do formador):
# "Perdi o contingente que gostava de trabalhar?"
# Se quem saiu tinha satisfação alta, a média pode ter caído não por causa
# do ping pong, mas porque perdemos as pessoas mais satisfeitas.

# --- 8.1 Preparar dados do "Antes" (apenas colaboradores ativos) ---
# Para comparar corretamente, temos de filtrar o dataset original
# para incluir APENAS quem respondeu ao survey (Attrition = "No")
df_antes <- df %>%
  filter(Attrition == "No") %>%
  select(EmployeeNumber, EnvironmentSatisfaction, JobInvolvement,
         JobSatisfaction, RelationshipSatisfaction, WorkLifeBalance)

# Survey (Depois)
df_depois <- df_survey %>%
  select(EmployeeNumber, EnvironmentSatisfaction, JobInvolvement,
         JobSatisfaction, RelationshipSatisfaction, WorkLifeBalance)

cat("Antes (ativos): ", nrow(df_antes), "colaboradores\n")
cat("Depois (survey):", nrow(df_depois), "colaboradores\n")

# --- 8.2 Calcular médias Antes vs Depois ---
medias_antes <- df_antes %>%
  select(-EmployeeNumber) %>%
  summarise(across(everything(), mean)) %>%
  pivot_longer(everything(), names_to = "Metrica", values_to = "Antes")

medias_depois <- df_depois %>%
  select(-EmployeeNumber) %>%
  summarise(across(everything(), mean)) %>%
  pivot_longer(everything(), names_to = "Metrica", values_to = "Depois")

comparacao_pp <- medias_antes %>%
  inner_join(medias_depois, by = "Metrica") %>%
  mutate(
    Diferenca = round(Depois - Antes, 3),
    Variacao_pct = round((Depois - Antes) / Antes * 100, 2)
  )

cat("\n=== Comparação Antes vs Depois do Ping Pong ===\n")
print(as.data.frame(comparacao_pp))

# Dica 9 do formador: "Caiu a moral média?"
cat("\nMoral média (média de todas as métricas):\n")
cat("  Antes:", round(mean(comparacao_pp$Antes), 3), "\n")
cat("  Depois:", round(mean(comparacao_pp$Depois), 3), "\n")

# --- 8.3 Gráfico comparativo ---
df_comp_long <- comparacao_pp %>%
  select(Metrica, Antes, Depois) %>%
  pivot_longer(cols = c(Antes, Depois), names_to = "Periodo", values_to = "Media") %>%
  mutate(
    Metrica = str_replace_all(Metrica, "([a-z])([A-Z])", "\\1 \\2"),
    Periodo = factor(Periodo, levels = c("Antes", "Depois"))
  )

p_comparacao <- ggplot(df_comp_long, aes(x = Metrica, y = Media, fill = Periodo)) +
  geom_col(position = position_dodge(width = 0.7), width = 0.6, alpha = 0.8) +
  geom_text(aes(label = round(Media, 2)), 
            position = position_dodge(width = 0.7), vjust = -0.3, size = 3.5) +
  scale_fill_manual(values = c("Antes" = "#4472C4", "Depois" = "#ED7D31")) +
  labs(title = "Satisfação: Antes vs Depois do Ping Pong",
       subtitle = "Comparação das médias das 5 variáveis de satisfação",
       x = "", y = "Média (1-4)", fill = "") +
  ylim(0, 4) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14),
        axis.text.x = element_text(angle = 15, hjust = 1))

print(p_comparacao)

# --- 8.4 Análise individual: quem melhorou vs quem piorou? ---
df_individual <- df_antes %>%
  inner_join(df_depois, by = "EmployeeNumber", suffix = c("_antes", "_depois"))

# Para cada métrica, calcular a diferença por pessoa
metricas <- c("EnvironmentSatisfaction", "JobInvolvement", "JobSatisfaction",
              "RelationshipSatisfaction", "WorkLifeBalance")

cat("\n=== Análise Individual: Quem melhorou, manteve ou piorou? ===\n")
for (m in metricas) {
  antes_col <- paste0(m, "_antes")
  depois_col <- paste0(m, "_depois")
  
  diff <- df_individual[[depois_col]] - df_individual[[antes_col]]
  
  melhorou <- sum(diff > 0)
  manteve  <- sum(diff == 0)
  piorou   <- sum(diff < 0)
  total    <- length(diff)
  
  cat(sprintf("\n%s:\n  Melhorou: %d (%.1f%%)  |  Manteve: %d (%.1f%%)  |  Piorou: %d (%.1f%%)\n",
              m, melhorou, melhorou/total*100, manteve, manteve/total*100, piorou, piorou/total*100))
}

# --- 8.5 Contexto crítico: satisfação de quem SAIU ---
# Para responder à dica 10: "perdi o contingente que gostava de trabalhar?"
df_saiu <- df %>%
  filter(Attrition == "Yes") %>%
  select(all_of(metricas))

df_ficou <- df %>%
  filter(Attrition == "No") %>%
  select(all_of(metricas))

cat("\n=== Satisfação média: Quem saiu vs Quem ficou ===\n")
cat("(Isto responde: perdemos as pessoas mais felizes ou mais infelizes?)\n\n")

for (m in metricas) {
  media_saiu  <- round(mean(df_saiu[[m]]), 3)
  media_ficou <- round(mean(df_ficou[[m]]), 3)
  cat(sprintf("  %s:\n    Saiu: %.3f  |  Ficou: %.3f  |  Diff: %+.3f\n",
              m, media_saiu, media_ficou, media_saiu - media_ficou))
}


# =============================================================================
# FIM DA ANÁLISE EXPLORATÓRIA
# =============================================================================
cat("\n\n========================================\n")
cat("Análise exploratória concluída!\n")
cat("Próximos passos:\n")
cat("  1. Importar CSVs no SQL Server\n")
cat("  2. Correr o Projeto1.sql (star schema)\n")
cat("  3. Conectar Power BI ao SQL Server\n")
cat("========================================\n")
