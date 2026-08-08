-- Este script é um exemplo prático das constraints que você usaria
-- em um ambiente CockroachDB para amarrar tabelas e localidades.

-- Cria a base de dados
CREATE DATABASE IF NOT EXISTS global_company;
USE global_company;

-- Cria uma tabela
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    city STRING,
    name STRING,
    -- Uma coluna escondida que mapeia de onde o dado veio (usada para otimização regional)
    crdb_region REGION "us-east-1"
);

-- Atribuímos a tabela ao banco multi-região
ALTER DATABASE global_company PRIMARY REGION "us-east-1";
ALTER DATABASE global_company ADD REGION "us-west1";

-- A grande magia do NewSQL:
-- Garantimos que a tabela irá tolerar a queda de UMA ZONA (ou região) inteira
-- sem perder o acesso aos dados, instruindo o banco a espalhar o quorum
ALTER TABLE users CONFIGURE ZONE USING survival_goal = 'region';

-- Inserindo um dado teste (que será replicado pela malha multi-cloud)
INSERT INTO users (city, name) VALUES ('São Paulo', 'João da Silva');
