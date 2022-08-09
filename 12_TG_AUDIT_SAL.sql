--CRIACAO TRIGGER AUDITA SALARIO
--DROP TRIGGER TG_AUDIT_SAL 
--TRIGGER PARA AUDITAR ALTERACOES DE SALARIO
USE MINIERP_MULT
GO
CREATE TRIGGER TG_AUDIT_SAL
ON SALARIO 
AFTER UPDATE 
AS 
  BEGIN 
      DECLARE @COD_EMPRESA INT 
      DECLARE @MATRICULA_AUX INT 

	 IF UPDATE(SALARIO)-- SE ATUALIZAR CAMPO SALARIO TABELA SALARIO
	 BEGIN 
     DECLARE CURSOR_AUDITORIA CURSOR FOR 

	  SELECT COD_EMPRESA,MATRICULA  FROM   INSERTED /*TABELA VIRTUAL INSERT */

      OPEN CURSOR_AUDITORIA 

      FETCH NEXT FROM CURSOR_AUDITORIA INTO @COD_EMPRESA,@MATRICULA_AUX 

      WHILE @@FETCH_STATUS = 0 
        BEGIN 
            INSERT INTO AUDITORIA_SALARIO 
            SELECT       i.COD_EMPRESA,
						 i.MATRICULA, 
                         d.SALARIO, 
                         i.SALARIO, 
                         SYSTEM_USER, 
                         Getdate() 
            FROM   deleted d, 
                   inserted i 
            WHERE  d.COD_EMPRESA=@COD_EMPRESA
				   AND d.COD_EMPRESA=i.COD_EMPRESA	  
				   AND d.MATRICULA = i.MATRICULA 
                   AND @MATRICULA_AUX= i.MATRICULA 

            FETCH next FROM CURSOR_AUDITORIA 
			INTO @COD_EMPRESA,@MATRICULA_AUX 
        END 

      CLOSE CURSOR_AUDITORIA 

      DEALLOCATE CURSOR_AUDITORIA 
	END
  END 
go