

CREATE TABLE IF NOT EXISTS transacoes (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    descricao       VARCHAR(120)   NOT NULL,
    valor           DECIMAL(10,2)  NOT NULL,
    data_transacao  DATETIME       NOT NULL
);
