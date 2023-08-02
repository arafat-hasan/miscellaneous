DECLARE @sql_document NVARCHAR(MAX), @document_alter_command NVARCHAR(MAX), @offset_command_doc NVARCHAR(MAX);
DECLARE @zzz VARCHAR(200);
SET @sql_document = '';
SET @zzz = (SELECT FORMAT(SYSDATETIMEOFFSET(), 'zzz') AS 'zzz');

SELECT @document_alter_command = 'ALTER TABLE [dbo].[document] ALTER COLUMN created datetimeoffset(3) NOT NULL;';

SELECT @sql_document += 'ALTER TABLE [dbo].[document] DROP CONSTRAINT ' +
                        ((SELECT OBJECT_NAME(constid) FROM sysconstraints
                        WHERE OBJECT_NAME(id) = 'document' AND colid IN
                        (SELECT ORDINAL_POSITION FROM INFORMATION_SCHEMA.COLUMNS
                        WHERE Table_Name = 'document' and COLUMN_NAME = 'created'))) + ';';

SELECT @offset_command_doc = 'UPDATE [dbo].[document] SET created = TODATETIMEOFFSET(created, ''' + @zzz + ''');';

IF @sql_document IS NOT NULL
    BEGIN
        PRINT @sql_document;
        PRINT @document_alter_command;
        PRINT @offset_command_doc;
        --EXECUTE (@sql_document);
        --EXECUTE (@document_alter_command);
        --EXECUTE (@offset_command_doc);
    END

DECLARE @i INT = 1, @doc_table_count INT;
SET @doc_table_count = (SELECT MAX(id) from project WHERE has_project_doc_table = 1);


WHILE @i <= @doc_table_count
    BEGIN
        DECLARE @constraints_command NVARCHAR(MAX), @table_name NVARCHAR(MAX), @alter_table_command NVARCHAR(MAX);
        DECLARE @offset_command NVARCHAR(MAX)
        SET @constraints_command = '';
        SET @table_name = 'documents_' + CAST(@i AS VARCHAR);

        SELECT @constraints_command += 'ALTER TABLE [dbo].[' + @table_name + '] DROP CONSTRAINT ' +
                                        ((SELECT OBJECT_NAME(constid) FROM sysconstraints
                                        WHERE OBJECT_NAME(id) = @table_name AND colid IN
                                        (SELECT ORDINAL_POSITION FROM INFORMATION_SCHEMA.COLUMNS
                                        WHERE Table_Name = @table_name and COLUMN_NAME = 'created'))) + ';';

        SELECT @alter_table_command = 'ALTER TABLE [dbo].[' + @table_name +
                                        '] ALTER COLUMN created datetimeoffset(3) NOT NULL;';

        SELECT @offset_command = 'UPDATE [dbo].[' + @table_name +
                                    '] SET created = TODATETIMEOFFSET(created, ''' + @zzz + ''');';


        IF @constraints_command IS NOT NULL
            BEGIN
                PRINT @constraints_command;
                PRINT @alter_table_command;
                PRINT @offset_command
                --EXECUTE (@constraints_command);
                --EXECUTE (@alter_table_command);
                --EXECUTE (@offset_command);
            END

        SET @i = @i + 1;
    END

