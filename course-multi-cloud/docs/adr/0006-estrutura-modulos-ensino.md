# ADR 0006: Estrutura Padronizada de Módulos de Ensino (Código Base e Exercícios)

* **Status:** Aceito
* **Data:** 2026-08-08
* **Autores:** Antigravity (IA), Govinda

## Contexto e Problema

Como este projeto é um repositório para ministrar um curso prático de HashiCorp Nomad e resiliência multi-cloud, a experiência de aprendizado dos alunos é prioridade. Se os arquivos estiverem desorganizados ou se não houver uma separação clara entre a teoria, o laboratório guiado, o código pronto para demonstração e os desafios práticos, os alunos enfrentarão atrito desnecessário para iniciar e acompanhar os exercícios.

## Decisão Consensual

Decidimos padronizar a estrutura de diretórios e arquivos de todos os módulos de ensino (`module-*`) seguindo o seguinte contrato de organização:

```
module-x-nome-do-modulo/
├── README.md           # Explicação teórica, objetivos do módulo e diagramas de arquitetura
├── LAB.md              # Roteiro passo a passo detalhado do exercício prático
├── base/               # Código base de referência (totalmente funcional para demonstração)
│   ├── terraform/      # Scripts Terraform funcionais
│   ├── ansible/        # Playbooks e inventários funcionais
│   └── jobs/           # Arquivos de Jobs Nomad (.nomad.hcl) funcionais
└── exercises/          # Código esqueleto dos exercícios (para o aluno completar)
    ├── terraform/      # Templates com lacunas (ex: "TODO: configure o health check")
    ├── ansible/        # Playbooks incompletos para preenchimento de variáveis
    └── jobs/           # Especificações de jobs para os alunos completarem
```

* **Código Base (`base/`):** Deve ser executável com um comando único e servir de gabarito.
* **Exercícios (`exercises/`):** Contêm comentários claros marcados com `TODO:` indicando exatamente onde e o que o aluno deve implementar para atingir o objetivo do módulo.

## Consequências

### Positivas
* **Experiência de Aprendizado Fluida:** Alunos conseguem facilmente diferenciar o que é o modelo correto/gabarito (`base/`) e o que é o seu espaço de prática (`exercises/`).
* **Consistência Educacional:** Todos os módulos seguem a mesma convenção, facilitando a navegação.

### Negativas
* **Duplicação de Código:** Alterações na infraestrutura ou versão do Nomad exigirão manutenção em duplicidade (tanto no diretório `base/` quanto no `exercises/`).
