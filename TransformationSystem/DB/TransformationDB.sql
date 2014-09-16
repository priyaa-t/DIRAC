-- -------------------------------------------------------------------------------
--  Schema definition for the TransformationDB database a generic
--  engine to define input data streams and support dynamic data 
--  grouping per unit of execution.

-- When installing via dirac tools, the following is not needed (still here for reference)
-- 
-- DROP DATABASE IF EXISTS TransformationDB;
-- CREATE DATABASE TransformationDB;
-- ------------------------------------------------------------------------------
-- Database owner definition
-- USE mysql;
-- Must set passwords for database user by replacing "must_be_set".
-- GRANT SELECT,INSERT,LOCK TABLES,UPDATE,DELETE,CREATE,DROP,ALTER ON TransformationDB.* TO Dirac@'%' IDENTIFIED BY 'must_be_set';
-- FLUSH PRIVILEGES;

-- -----------------------------------------------------------------------------
USE TransformationDB;

SET FOREIGN_KEY_CHECKS = 0;

-- -------------------------------------------------------------------------------
DROP TABLE IF EXISTS Transformations;
CREATE TABLE Transformations (
    TransformationID INTEGER NOT NULL AUTO_INCREMENT,
    TransformationName VARCHAR(255) NOT NULL,
    Description VARCHAR(255),
    LongDescription  BLOB,
    CreationDate DATETIME,
    LastUpdate DATETIME,
    AuthorDN VARCHAR(255) NOT NULL,
    AuthorGroup VARCHAR(255) NOT NULL,
    Type CHAR(32) DEFAULT 'Simulation',
    Plugin CHAR(32) DEFAULT 'None',
    AgentType CHAR(32) DEFAULT 'Manual',
    Status  CHAR(32) DEFAULT 'New',
    FileMask VARCHAR(255),
    TransformationGroup varchar(64) NOT NULL default 'General',
    TransformationFamily varchar(64) default '0',
    GroupSize INT NOT NULL DEFAULT 1,
    InheritedFrom INTEGER DEFAULT 0,
    Body LONGBLOB,
    MaxNumberOfTasks INT NOT NULL DEFAULT 0,
    EventsPerTask INT NOT NULL DEFAULT 0,
    PRIMARY KEY(TransformationID),
    INDEX(TransformationName)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- -------------------------------------------------------------------------------
DROP TABLE IF EXISTS DataFiles;
CREATE TABLE DataFiles (
   FileID INTEGER NOT NULL AUTO_INCREMENT,
   LFN VARCHAR(255) NOT NULL DEFAULT '',
   Status varchar(32) DEFAULT 'AprioriGood',
   INDEX (Status),
   INDEX (LFN),
   PRIMARY KEY (FileID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- -------------------------------------------------------------------------------
DROP TABLE IF EXISTS AdditionalParameters;
CREATE TABLE AdditionalParameters (
    TransformationID INTEGER NOT NULL,
    ParameterName VARCHAR(32) NOT NULL,
    ParameterValue LONGBLOB NOT NULL,
    ParameterType VARCHAR(32) DEFAULT 'StringType', 
    PRIMARY KEY(TransformationID,ParameterName),
    FOREIGN KEY (TransformationID) REFERENCES Transformations(TransformationID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- -------------------------------------------------------------------------------
DROP TABLE IF EXISTS TransformationLog;
CREATE TABLE TransformationLog (
	recid INTEGER NOT NULL AUTO_INCREMENT,
    TransformationID INTEGER NOT NULL,
    Message VARCHAR(255) NOT NULL,
    Author VARCHAR(255) NOT NULL DEFAULT 'Unknown',
    MessageDate DATETIME NOT NULL,
    PRIMARY KEY(recid),
    INDEX (TransformationID),
    INDEX (MessageDate),
    FOREIGN KEY (TransformationID) REFERENCES Transformations(TransformationID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- -------------------------------------------------------------------------------
DROP TABLE IF EXISTS TransformationTasks;
CREATE TABLE TransformationTasks (
    TransformationID INTEGER NOT NULL,
    TaskID INTEGER NOT NULL,
    ExternalStatus char(16) DEFAULT 'Created',
    ExternalID char(16) DEFAULT '',
    TargetSE char(255) DEFAULT 'Unknown',
    CreationTime DATETIME NOT NULL,
    LastUpdateTime DATETIME NOT NULL,
    PRIMARY KEY(TransformationID,TaskID),
    INDEX(ExternalStatus),
	FOREIGN KEY (TransformationID) REFERENCES Transformations(TransformationID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- This is required to mimic the AUTO_INCREMENT behavior of TaskID which was possible with MyISAM:
CREATE TRIGGER `TaskID_Generator` BEFORE INSERT ON TransformationTasks
FOR EACH ROW SET NEW.TaskID = ( SELECT @last := IFNULL(MAX(TaskID) + 1,1) FROM TransformationTasks WHERE TransformationID=NEW.TransformationID );

