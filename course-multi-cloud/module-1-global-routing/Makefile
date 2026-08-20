.PHONY: up down test bdd run-poc help

help:
	@echo "Comandos disponíveis:"
	@echo "  make up       - Inicia os containers da PoC (AWS, GCP e GTM)"
	@echo "  make down     - Para os containers e limpa os recursos"
	@echo "  make test     - Executa o teste de validação padrão (script bash)"
	@echo "  make bdd      - Executa o teste de integração em formato BDD (Given/When/Then)"
	@echo "  make load-test - Executa o teste de carga real-time (multi-threaded)"
	@echo "  make run-poc  - Executa o fluxo completo (inicia, roda testes BDD e limpa)"

up:
	./sandbox.sh up
	@echo "Aguardando inicialização do Grafana..."
	@sleep 2
	@open http://localhost:3000


down:
	./sandbox.sh down

test:
	./sandbox.sh test

bdd:
	python3 bdd_test.py

load-test:
	python3 load_test.py

run-poc: up
	@echo "Aguardando inicialização completa do ambiente..."
	@sleep 2
	@make bdd
	@make down

