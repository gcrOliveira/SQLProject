--V_FUNCIONARIO
--TABELAS FUNCIONARIO,CARGOS,CENTRO_CUSTO
--SELECT * FROM V_FUNCIONARIO
USE MINIERP_MULT
GO

CREATE VIEW V_FUNCIONARIO
AS
	SELECT A.COD_EMPRESA,
		   A.MATRICULA,
		   A.COD_CC,
		   C.NOME_CC,  
		   A.NOME,
		   A.COD_CARGO,
		   B.NOME_CARGO,
		   A.DATA_ADMISS,
		   A.DATE_DEMISS,
		   CASE WHEN A.DATE_DEMISS='1900-01-01' THEN 'ATIVO'
		         ELSE 'DESLIGADO' END SITUACAO
		FROM 
		 FUNCIONARIO A
		 INNER JOIN CARGOS B
		 ON A.COD_EMPRESA=B.COD_EMPRESA
		 AND A.COD_CARGO=B.COD_CARGO
		 INNER JOIN CENTRO_CUSTO C
		 ON A.COD_CC=C.COD_CC
		 AND A.COD_EMPRESA=C.COD_EMPRESA
go
--TESTANDO VIEW
SELECT * FROM V_FUNCIONARIO
--V_FATURAMENTO
--NOTA_FISCAL, NOTA_FISCAL_ITENS,MATERIAL,CLIENTES, CIDADES,
--SELECT * FROM MATERIAL
--SELECT * FROM CLIENTES
--SELECT * FROM CIDADES
go
CREATE VIEW V_FATURAMENTO
AS
SELECT A.COD_EMPRESA,
	   A.NUM_NF,
	   A.ID_CLIFOR,
	   CAST(A.DATA_EMISSAO AS DATE) DATA_EMISSAO,
	   B.COD_MAT,
	   C.DESCRICAO,
	   D.RAZAO_CLIENTE,
	   E.NOME_MUN,
	   B.QTD,
	   B.VAL_UNIT,
	   B.QTD*B.VAL_UNIT TOTAL
FROM NOTA_FISCAL A 
INNER JOIN NOTA_FISCAL_ITENS B
ON A.COD_EMPRESA=B.COD_EMPRESA
AND A.NUM_NF=B.NUM_NF

INNER JOIN MATERIAL C
ON A.COD_EMPRESA=C.COD_EMPRESA
AND B.COD_MAT=C.COD_MAT

INNER JOIN CLIENTES D
ON A.COD_EMPRESA=D.COD_EMPRESA
AND A.ID_CLIFOR=D.ID_CLIENTE

INNER JOIN CIDADES E
ON D.COD_CIDADE=E.COD_CIDADE
WHERE A.TIP_NF='S'
go

--CRIAMOS INDICE PARA MELHORAR PERFORMANCE
--CREATE INDEX IX_FAT1 ON NOTA_FISCAL(TIP_NF)
--EXEC SP_STATISTICS NOTA_FISCAL
--TESTANDO VIEW
SELECT * FROM V_FATURAMENTO

--V_NECCESSIDADES
--ORDEM_PROD,FICHA_TECNICA, ESTOQUE,MATERIAL
go
CREATE VIEW V_NECCESSIDADES
   AS
	SELECT A.COD_EMPRESA,
	       A.ID_ORDEM,
		   A.COD_MAT_PROD,
		   A.QTD_PLAN,A.QTD_PROD,
		   A.QTD_PLAN-A.QTD_PROD SALDO,
		   B.COD_MAT_NECES,
		   D.DESCRICAO,
		   B.QTD_NECES,
		  (A.QTD_PLAN-A.QTD_PROD)*B.QTD_NECES QTD_REAL_NEC,
		   C.QTD_SALDO,
		CASE WHEN  (A.QTD_PLAN-A.QTD_PROD)*B.QTD_NECES>C.QTD_SALDO
	   THEN 'FALTA ESTOQUE' ELSE 'OK' END MSG
	 FROM ORDEM_PROD A
	 INNER JOIN FICHA_TECNICA B
	 ON A.COD_EMPRESA=B.COD_EMPRESA
	 AND A.COD_MAT_PROD=B.COD_MAT_PROD
	 INNER JOIN ESTOQUE C
	 ON A.COD_EMPRESA=C.COD_EMPRESA
	 AND B.COD_MAT_NECES=C.COD_MAT
	 INNER JOIN MATERIAL D
	 ON A.COD_EMPRESA=D.COD_EMPRESA
	 AND B.COD_MAT_NECES=D.COD_MAT
	 WHERE (A.QTD_PLAN-A.QTD_PROD)<>0
	 --AND A.ID_ORDEM=1
go
--TESTANDO VIEW
SELECT * FROM V_NECCESSIDADES
WHERE COD_EMPRESA='1'
AND ID_ORDEM=2

--V_CONTAS_PAGAR
--CONTAS_PAGAR,FORNECEDORES
--SELECT * FROM V_CONTAS_PAGAR
go
CREATE VIEW V_CONTAS_PAGAR
AS
SELECT A.COD_EMPRESA,
	   A.ID_DOC,
	   A.ID_FOR,
	   B.RAZAO_FORNEC,
	   A.PARC,
	   A.DATA_VENC,
	   A.DATA_PAGTO,
	   A.VALOR,
	   CASE WHEN A.DATA_PAGTO IS NULL THEN 'ABERTO' ELSE 'PAGO' END SITUACAO,
	   CASE WHEN A.DATA_VENC>GETDATE() THEN 'NORMAL' 
		WHEN A.DATA_PAGTO>A.DATA_VENC   THEN 'PAGTO EF COM ATRASO'
		ELSE 'VENCIDO' END MSG
 FROM CONTAS_PAGAR A
 INNER JOIN FORNECEDORES B
 ON A.COD_EMPRESA=B.COD_EMPRESA 
 AND A.ID_FOR=B.ID_FOR
 go
--TESTANDO VIEW
SELECT * FROM V_CONTAS_PAGAR
go
--V_CONTAS_RECEBER
--CONTAS_RECEBER,CLIENTES
CREATE VIEW V_CONTAS_RECEBER
AS
SELECT A.COD_EMPRESA,
       A.ID_DOC,
	   A.ID_CLIENTE,
	   B.RAZAO_CLIENTE,
	   A.PARC,
	   A.DATA_VENC,
	   A.DATA_PAGTO,
	   A.VALOR,
		CASE WHEN A.DATA_PAGTO IS NULL THEN 'ABERTO' ELSE 'PAGO' END SITUACAO,
		CASE WHEN A.DATA_VENC>GETDATE() THEN 'NORMAL' 
			 WHEN A.DATA_PAGTO>A.DATA_VENC   THEN 'PAGTO EM COM ATRASO'
		ELSE 'VENCIDO' END MSG,
		CASE WHEN A.DATA_VENC=A.DATA_PAGTO THEN 0
			 WHEN A.DATA_PAGTO>A.DATA_VENC THEN CAST(CAST(A.DATA_PAGTO AS DATETIME)-CAST(A.DATA_VENC AS DATETIME) AS INT )
			 ELSE 
			 CAST(GETDATE()-CAST(A.DATA_VENC AS DATETIME) AS INT ) END DIAS_ATRASO
 FROM CONTAS_RECEBER A
 INNER JOIN CLIENTES B
 ON A.COD_EMPRESA=B.COD_EMPRESA
 AND A.ID_CLIENTE=B.ID_CLIENTE
go
--TESTANDO VIEW
SELECT * FROM V_CONTAS_RECEBER
go
--MATERIAL,FICHA_TECNICA
CREATE VIEW V_CUSTO_PRODUTO_DET
AS
SELECT A.COD_EMPRESA,
	  A.COD_MAT,
	  A.DESCRICAO,
	  B.COD_MAT_NECES,
	  C.DESCRICAO DESCRICAO_MAT_N,
	  B.QTD_NECES,
	  C.PRECO_UNIT,
	  B.QTD_NECES*C.PRECO_UNIT CUSTO_NEC
 FROM MATERIAL A
 INNER JOIN FICHA_TECNICA B
 ON A.COD_EMPRESA=B.COD_EMPRESA
 AND A.COD_MAT=B.COD_MAT_PROD
 INNER JOIN MATERIAL C
 ON A.COD_EMPRESA=C.COD_EMPRESA
 AND B.COD_MAT_NECES=C.COD_MAT
WHERE A.COD_TIP_MAT='2'
go
--TESTANDO VIEW
SELECT * FROM V_CUSTO_PRODUTO_DET
go
--CRIICAO VIEW RESUMO DE CUSTO
CREATE VIEW V_CUSTO_PRODUTO_RESUMO
AS
SELECT A.COD_EMPRESA,
       A.COD_MAT,
	   A.DESCRICAO,
	   A.PRECO_UNIT PRECO_VENDA,
	  SUM(B.QTD_NECES*C.PRECO_UNIT) CUSTO,
	  A.PRECO_UNIT-SUM(B.QTD_NECES*C.PRECO_UNIT) MARGEM
 FROM MATERIAL A
 INNER JOIN FICHA_TECNICA B
 ON A.COD_EMPRESA=B.COD_EMPRESA
 AND A.COD_MAT=B.COD_MAT_PROD
 INNER JOIN MATERIAL C
 ON A.COD_EMPRESA=C.COD_EMPRESA
 AND B.COD_MAT_NECES=C.COD_MAT
WHERE A.COD_TIP_MAT='2'
GROUP BY A.COD_EMPRESA,A.COD_MAT,A.DESCRICAO,A.PRECO_UNIT
go
--TESTANDO VIEW
SELECT * FROM V_CUSTO_PRODUTO_RESUMO
go
--V_CANAL_VENDAS
--CLIENTES,CANAL_VENDAS_G_V,CANAL_VENDAS_V_C


CREATE VIEW V_CANAL_VENDAS
AS
	SELECT A.COD_EMPRESA,
	       A.ID_CLIENTE,
		   A.RAZAO_CLIENTE,
		   ISNULL(B.MATRICULA_VEND,0)ID_VEND,
		   ISNULL(D.NOME,'SEM CANAL')NOME_VEND,
		   ISNULL(E.MATRICULA_GER,0) ID_GER,
		   ISNULL(G.NOME,'SEM CANAL') NOME_GER
	FROM CLIENTES A
	LEFT JOIN CANAL_VENDAS_V_C B
	ON A.COD_EMPRESA=B.COD_EMPRESA
	AND A.ID_CLIENTE=B.ID_CLIENTE

	LEFT JOIN VENDEDORES C
	ON A.COD_EMPRESA=C.COD_EMPRESA
	AND B.MATRICULA_VEND=C.MATRICULA

	LEFT JOIN FUNCIONARIO D --PARA RELACIONAR VENDEDOR
	ON A.COD_EMPRESA=D.COD_EMPRESA 
	AND C.MATRICULA=D.MATRICULA

	LEFT JOIN CANAL_VENDAS_G_V E
	ON A.COD_EMPRESA=E.COD_EMPRESA 
	AND B.MATRICULA_VEND=E.MATRICULA_VEND
	LEFT JOIN GERENTES F
	ON A.COD_EMPRESA=F.COD_EMPRESA
	AND E.MATRICULA_GER=F.MATRICULA
	LEFT JOIN FUNCIONARIO G --PARA RELACIONAR GERENTE
	ON A.COD_EMPRESA=G.COD_EMPRESA
	AND F.MATRICULA=G.MATRICULA

go
--TESTANDO VIEW V_CANAL_VENDAS
SELECT * FROM V_CANAL_VENDAS

go



