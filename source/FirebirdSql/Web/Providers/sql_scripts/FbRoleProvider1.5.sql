SET SQL DIALECT 3;

SET NAMES NONE;

CREATE TABLE ROLES (
    ROLENAME         VARCHAR(100) CHARACTER SET NONE NOT NULL,
    APPLICATIONNAME  VARCHAR(100) CHARACTER SET NONE NOT NULL
);

CREATE INDEX ROLES_IDX1 ON ROLES (ROLENAME);
CREATE INDEX ROLES_IDX2 ON ROLES (APPLICATIONNAME);

CREATE TABLE USERSINROLES (
    USERNAME         VARCHAR(100) CHARACTER SET NONE NOT NULL,
    ROLENAME         VARCHAR(100) CHARACTER SET NONE NOT NULL,
    APPLICATIONNAME  VARCHAR(100) CHARACTER SET NONE NOT NULL,
    UPPERUSERNAME    VARCHAR(100)  CHARACTER SET NONE
);

CREATE INDEX USERSINROLES_IDX1 ON USERSINROLES (USERNAME);
CREATE INDEX USERSINROLES_IDX2 ON USERSINROLES (ROLENAME);
CREATE INDEX USERSINROLES_IDX3 ON USERSINROLES (APPLICATIONNAME);
CREATE INDEX USERSINROLES_IDX4 ON USERSINROLES (UPPERUSERNAME);

SET TERM ^ ;

CREATE PROCEDURE ROLES_ADDUSERTOROLE(
    APPLICATIONNAME VARCHAR(100) CHARACTER SET NONE,
    ROLENAME VARCHAR(100) CHARACTER SET NONE,
    USERNAME VARCHAR(100) CHARACTER SET NONE)
AS
BEGIN
 INSERT INTO USERSINROLES (USERNAME,UPPERUSERNAME,ROLENAME,APPLICATIONNAME)
 VALUES (:USERNAME,UPPER(:USERNAME),:ROLENAME,:APPLICATIONNAME);
END^

CREATE PROCEDURE ROLES_CREATEROLE(
    APPLICATIONNAME VARCHAR(100) CHARACTER SET NONE,
    ROLENAME VARCHAR(100) CHARACTER SET NONE)
AS
BEGIN
 INSERT INTO ROLES (ROLENAME,APPLICATIONNAME)
 VALUES (:ROLENAME,:APPLICATIONNAME);
END^

CREATE PROCEDURE ROLES_DELETEROLE(
    APPLICATIONNAME VARCHAR(100) CHARACTER SET NONE,
    ROLENAME VARCHAR(100) CHARACTER SET NONE)
AS
BEGIN
 DELETE FROM ROLES WHERE rolename = :rolename
                        AND applicationname = :applicationname;
 DELETE FROM USERSINROLES WHERE rolename = :rolename
                          AND applicationname = :applicationname;
END^

CREATE PROCEDURE ROLES_GETALLROLES(
    APPLICATIONNAME VARCHAR(100) CHARACTER SET NONE)
RETURNS (
    ROLENAME VARCHAR(100) CHARACTER SET NONE)
AS
BEGIN
 FOR SELECT ROLENAME FROM ROLES WHERE applicationname = :applicationname
     INTO :ROLENAME
 DO BEGIN
  SUSPEND;
 END
END^

CREATE PROCEDURE ROLES_GETUSERROLES(
    APPLICATIONNAME VARCHAR(100) CHARACTER SET NONE,
    USERNAME VARCHAR(100) CHARACTER SET NONE)
RETURNS (
    ROLENAME VARCHAR(100) CHARACTER SET NONE)
AS
BEGIN
 FOR SELECT ROLENAME FROM USERSINROLES WHERE UPPERUSERNAME = UPPER(:USERNAME)
                                       AND APPLICATIONNAME = :applicationname
     INTO :ROLENAME
 DO BEGIN
  SUSPEND;
 END
END^

CREATE PROCEDURE ROLES_GETROLEUSERS(
    APPLICATIONNAME VARCHAR(100) CHARACTER SET NONE,
    ROLENAME VARCHAR(100) CHARACTER SET NONE)
RETURNS (
    USERNAME VARCHAR(100) CHARACTER SET NONE)
AS
BEGIN
 FOR SELECT USERNAME FROM USERSINROLES
                 WHERE ROLENAME = :ROLENAME AND APPLICATIONNAME = :APPLICATIONNAME

     INTO :USERNAME
 DO BEGIN
  SUSPEND;
 END
END^

CREATE PROCEDURE ROLES_ISUSERINROLE(
    APPLICATIONNAME VARCHAR(100) CHARACTER SET NONE,
    ROLENAME VARCHAR(100) CHARACTER SET NONE,
    USERNAME VARCHAR(100) CHARACTER SET NONE)
RETURNS (
    RES INTEGER)
AS
BEGIN
 RES = 0;
 SELECT first(1) 1 FROM USERSINROLES
                 WHERE UPPERUSERNAME = UPPER(:USERNAME) AND ROLENAME = :ROLENAME
                       AND APPLICATIONNAME = :APPLICATIONNAME
                 INTO :RES;
 SUSPEND;
END^

CREATE PROCEDURE ROLES_DELETEUSERROLE(
    APPLICATIONNAME VARCHAR(100) CHARACTER SET NONE,
    ROLENAME VARCHAR(100) CHARACTER SET NONE,
    USERNAME VARCHAR(100) CHARACTER SET NONE)
AS
BEGIN
 DELETE FROM USERSINROLES WHERE
                          UPPERUSERNAME = UPPER(:username)
                          AND ROLENAME = :rolename
                          AND APPLICATIONNAME = :APPLICATIONNAME;
END^

CREATE PROCEDURE ROLES_ISEXISTS(
    APPLICATIONNAME VARCHAR(100) CHARACTER SET NONE,
    ROLENAME VARCHAR(100) CHARACTER SET NONE)
RETURNS (
    RES INTEGER)
AS
BEGIN
 RES = 0;
 SELECT first(1) 1 FROM ROLES
                 WHERE ROLENAME = :ROLENAME
                       AND APPLICATIONNAME = :APPLICATIONNAME
                 INTO :RES;
 SUSPEND;
END^

CREATE PROCEDURE ROLES_FINDROLEUSERS(
    APPLICATIONNAME VARCHAR(100) CHARACTER SET NONE,
    ROLENAME VARCHAR(100) CHARACTER SET NONE,
    USERNAMETOMATCH VARCHAR(100) CHARACTER SET NONE)
RETURNS (
    USERNAME VARCHAR(100) CHARACTER SET NONE)
AS
BEGIN
 FOR SELECT USERNAME FROM USERSINROLES WHERE ROLENAME = :ROLENAME
                                             AND APPLICATIONNAME = :APPLICATIONNAME
                                             AND UPPERUSERNAME LIKE :USERNAMETOMATCH
     INTO :USERNAME
 DO BEGIN
  SUSPEND;
 END
END^

SET TERM ; ^

GRANT INSERT ON USERSINROLES TO PROCEDURE ROLES_ADDUSERTOROLE;
GRANT EXECUTE ON PROCEDURE ROLES_ADDUSERTOROLE TO SYSDBA;
GRANT INSERT ON ROLES TO PROCEDURE ROLES_CREATEROLE;
GRANT EXECUTE ON PROCEDURE ROLES_CREATEROLE TO SYSDBA;
GRANT SELECT ON USERSINROLES TO PROCEDURE ROLES_ISUSERINROLE;
GRANT EXECUTE ON PROCEDURE ROLES_ISUSERINROLE TO SYSDBA;
GRANT SELECT ON ROLES TO PROCEDURE ROLES_ISEXISTS;
GRANT EXECUTE ON PROCEDURE ROLES_ISEXISTS TO SYSDBA;
GRANT SELECT ON USERSINROLES TO PROCEDURE ROLES_GETUSERROLES;
GRANT EXECUTE ON PROCEDURE ROLES_GETUSERROLES TO SYSDBA;
GRANT SELECT ON USERSINROLES TO PROCEDURE ROLES_GETROLEUSERS;
GRANT EXECUTE ON PROCEDURE ROLES_GETROLEUSERS TO SYSDBA;
GRANT SELECT ON ROLES TO PROCEDURE ROLES_GETALLROLES;
GRANT EXECUTE ON PROCEDURE ROLES_GETALLROLES TO SYSDBA;
GRANT SELECT ON USERSINROLES TO PROCEDURE ROLES_FINDROLEUSERS;
GRANT EXECUTE ON PROCEDURE ROLES_FINDROLEUSERS TO SYSDBA;
GRANT SELECT,DELETE ON USERSINROLES TO PROCEDURE ROLES_DELETEUSERROLE;
GRANT EXECUTE ON PROCEDURE ROLES_DELETEUSERROLE TO SYSDBA;
GRANT SELECT,DELETE ON ROLES TO PROCEDURE ROLES_DELETEROLE;
GRANT SELECT,DELETE ON USERSINROLES TO PROCEDURE ROLES_DELETEROLE;
GRANT EXECUTE ON PROCEDURE ROLES_DELETEROLE TO SYSDBA;