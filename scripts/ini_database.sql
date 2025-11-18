/*
==================================================================
Create Database and Schemas in Google Cloud SQL
==================================================================

Script Purpose:
  This script create a new database name 'DataWarehouse' after checking if it alreadt exists.
  if the datavase exists, it is dropped and recreated. Additionally, the script sets up three schemas
  within the database: 'bronze', 'silver', and 'gold'.

WARNING:
  Running this script will drop the 'DataWarehouse' database if it exists.
  All data in the database will be permanently deleted. proceed with caution
  and ensure you have proper backups before running this script.

*/



DROP DATABASE IF EXISTS `DataWarehouse`;

CREATE DATABASE `DataWarehouse`;

USE `DataWarehouse`;


CREATE SCHEMA `bronze`;


CREATE SCHEMA `siler`;


CREATE SCHEMA `gold`;

