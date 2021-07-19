DELIMITER $$

USE `bancodedados`$$

DROP FUNCTION IF EXISTS `f_extenso`$$

CREATE DEFINER=`root`@`localhost` FUNCTION `f_extenso`(pNumero INT(11)) RETURNS VARCHAR(500) CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE unidade VARCHAR(500);
	DECLARE primeiraDezena VARCHAR(500);
	DECLARE dezenas VARCHAR(500);
	DECLARE centenas VARCHAR(500);
	DECLARE delim CHAR;
	DECLARE extenso VARCHAR(500);
	DECLARE extensoCentena VARCHAR(500);
	DECLARE extensoDezena VARCHAR(500);
	DECLARE extensoUnidade VARCHAR(500);
	DECLARE milhao INT(3);
	DECLARE	milhar INT (3);
	DECLARE centena INT(3);
	DECLARE dezena INT(2);
	DECLARE unidadeNum INT(1);
	DECLARE complemento VARCHAR(30);
	DECLARE tmp INT(11);
	
	SET complemento = 'Milhão';
	SET extenso = '';
	SET unidade = 'Um,Dois,Três,Quatro,Cinco,Seis,Sete,Oito,Nove';
	SET primeiraDezena = 'Onze,Doze,Treze,Catorze,Quinze,Dezesseis,Dezessete,Dezoito,Dezenove';
	SET dezenas = 'Dez,Vinte,Trinta,Quarenta,Cinquenta,Sessenta,Setenta,Oitenta,Noventa';
	SET centenas = 'Cento,Duzentos,Trezentos,Quatrocentos,Quinhentos,Seiscentos,Setecentos,Oitocentos,Novecentos';
	SET delim = ',';
	
	IF (pNumero) = 0 THEN
		SET extenso = 'Zero';
		RETURN extenso;
	END IF;	
	
	SET tmp = pNumero;
	
	WHILE complemento <> '' DO
		-- milhao
		SET milhao = FLOOR(tmp/1000000);
		IF milhao > 0 THEN
			SET complemento = IF(milhao=1,'Milhão','Milhões');
			SET tmp = milhao;
			SET pNumero = pNumero - milhao*1000000;
		ELSE
			SET complemento = 'Mil';
		END IF;
		
		-- milhar
		IF complemento = 'Mil' THEN
			SET milhar = FLOOR(pNumero/1000);
			IF milhar > 0 THEN
				SET tmp = milhar;
				SET pNumero = pNumero - milhar*1000;
			ELSE
				SET complemento = '';
			END IF;
		END IF;
		
		-- centena
		IF complemento = '' THEN
			SET tmp = pNumero;
		END IF;
		
		SET centena = FLOOR(tmp/100);
		SET dezena = FLOOR((tmp - centena * 100)/ 10);
		SET unidadeNum = tmp MOD 10;
		IF ((centena) = 1 AND (dezena) = 0 AND (unidadeNum) = 0) THEN
			SET extensoCentena = 'Cem';
			SET extensoDezena = '';
			SET extensoUnidade = '';
		ELSEIF ((dezena) = 1 AND (unidadeNum) = 0) THEN
			SET extensoCentena = REPLACE(SUBSTRING(SUBSTRING_INDEX(centenas, delim, centena), LENGTH(SUBSTRING_INDEX(centenas, delim, centena - 1)) + 1), delim, '');
			SET extensoDezena = REPLACE(SUBSTRING(SUBSTRING_INDEX(dezenas, delim, dezena), LENGTH(SUBSTRING_INDEX(dezenas, delim, dezena - 1)) + 1), delim, '');
			SET extensoUnidade = '';
		ELSEIF (dezena = 1) THEN
			SET extensoCentena = REPLACE(SUBSTRING(SUBSTRING_INDEX(centenas, delim, centena), LENGTH(SUBSTRING_INDEX(centenas, delim, centena - 1)) + 1), delim, '');
			SET extensoDezena = REPLACE(SUBSTRING(SUBSTRING_INDEX(primeiraDezena, delim, unidadeNum), LENGTH(SUBSTRING_INDEX(primeiraDezena, delim, unidadeNum - 1)) + 1), delim, '');
			SET extensoUnidade = '';
		ELSE
			SET extensoCentena = REPLACE(SUBSTRING(SUBSTRING_INDEX(centenas, delim, centena), LENGTH(SUBSTRING_INDEX(centenas, delim, centena - 1)) + 1), delim, '');
			SET extensoDezena = REPLACE(SUBSTRING(SUBSTRING_INDEX(dezenas, delim, dezena), LENGTH(SUBSTRING_INDEX(dezenas, delim, dezena - 1)) + 1), delim, '');
			SET extensoUnidade = REPLACE(SUBSTRING(SUBSTRING_INDEX(unidade, delim, unidadeNum), LENGTH(SUBSTRING_INDEX(unidade, delim, unidadeNum - 1)) + 1), delim, '');
		END IF;
		SET extenso = CONCAT(extenso
				,IF(extenso<>'' AND (extensoCentena<>'' OR extensoDezena<>'' OR extensoUnidade<>''),' e ','')
				,extensoCentena
				,IF(extensoCentena<>'' AND (extensoDezena<>'' OR extensoUnidade<>''),' e ','')
				,extensoDezena
				,IF(extensoDezena<>'' AND extensoUnidade<>'',' e ','')
				,extensoUnidade
				,' '
				,complemento
				);
	END WHILE;

	RETURN extenso;

    END$$

DELIMITER ;