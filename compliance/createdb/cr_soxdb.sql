USE [master]
GO

/****** Object:  Database [sox]    Script Date: 5/18/2012 9:33:14 AM ******/
CREATE DATABASE [sox] ON  PRIMARY 
( NAME = N'sox', FILENAME = N'F:\Program Files\Microsoft SQL Server\MSSQL.1\Data\sox.mdf' , SIZE = 102400KB , MAXSIZE = UNLIMITED, FILEGROWTH = 102400KB )
 LOG ON 
( NAME = N'sox_log', FILENAME = N'S:\Program Files\Microsoft SQL Server\MSSQL.1\Log\sox_log.ldf' , SIZE = 102400KB , MAXSIZE = 2048GB , FILEGROWTH = 102400KB )
GO

ALTER DATABASE [sox] SET COMPATIBILITY_LEVEL = 90
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [sox].[dbo].[sp_fulltext_database] @action = 'disable'
end
GO

ALTER DATABASE [sox] SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [sox] SET ANSI_NULLS OFF 
GO

ALTER DATABASE [sox] SET ANSI_PADDING OFF 
GO

ALTER DATABASE [sox] SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [sox] SET ARITHABORT OFF 
GO

ALTER DATABASE [sox] SET AUTO_CLOSE OFF 
GO

ALTER DATABASE [sox] SET AUTO_CREATE_STATISTICS ON 
GO

ALTER DATABASE [sox] SET AUTO_SHRINK OFF 
GO

ALTER DATABASE [sox] SET AUTO_UPDATE_STATISTICS ON 
GO

ALTER DATABASE [sox] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO

ALTER DATABASE [sox] SET CURSOR_DEFAULT  GLOBAL 
GO

ALTER DATABASE [sox] SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [sox] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [sox] SET QUOTED_IDENTIFIER OFF 
GO

ALTER DATABASE [sox] SET RECURSIVE_TRIGGERS OFF 
GO

ALTER DATABASE [sox] SET  DISABLE_BROKER 
GO

ALTER DATABASE [sox] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO

ALTER DATABASE [sox] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO

ALTER DATABASE [sox] SET TRUSTWORTHY OFF 
GO

ALTER DATABASE [sox] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO

ALTER DATABASE [sox] SET PARAMETERIZATION SIMPLE 
GO

ALTER DATABASE [sox] SET READ_COMMITTED_SNAPSHOT OFF 
GO

ALTER DATABASE [sox] SET RECOVERY SIMPLE 
GO

ALTER DATABASE [sox] SET  MULTI_USER 
GO

ALTER DATABASE [sox] SET PAGE_VERIFY CHECKSUM  
GO

ALTER DATABASE [sox] SET DB_CHAINING OFF 
GO

USE [sox]
GO

/****** Object:  User [IIE\dkear]    Script Date: 5/18/2012 9:33:14 AM ******/
CREATE USER [IIE\dkear] FOR LOGIN [IIE\dkear] WITH DEFAULT_SCHEMA=[dbo]
GO

/****** Object:  User [IIE\dkukharenko]    Script Date: 5/18/2012 9:33:15 AM ******/
CREATE USER [IIE\dkukharenko] FOR LOGIN [IIE\dkukharenko] WITH DEFAULT_SCHEMA=[dbo]
GO

/****** Object:  User [IIE\Jchen2]    Script Date: 5/18/2012 9:33:15 AM ******/
CREATE USER [IIE\Jchen2] FOR LOGIN [IIE\Jchen2] WITH DEFAULT_SCHEMA=[dbo]
GO

/****** Object:  User [IIE\kmahadevan]    Script Date: 5/18/2012 9:33:15 AM ******/
CREATE USER [IIE\kmahadevan] FOR LOGIN [IIE\kmahadevan] WITH DEFAULT_SCHEMA=[dbo]
GO

/****** Object:  User [IIE\KSwamy]    Script Date: 5/18/2012 9:33:15 AM ******/
CREATE USER [IIE\KSwamy] FOR LOGIN [IIE\KSwamy] WITH DEFAULT_SCHEMA=[dbo]
GO

/****** Object:  User [IIE\mguddeti]    Script Date: 5/18/2012 9:33:15 AM ******/
CREATE USER [IIE\mguddeti] FOR LOGIN [IIE\mguddeti] WITH DEFAULT_SCHEMA=[dbo]
GO

/****** Object:  User [IIE\NParikh]    Script Date: 5/18/2012 9:33:15 AM ******/
CREATE USER [IIE\NParikh] FOR LOGIN [IIE\NParikh] WITH DEFAULT_SCHEMA=[dbo]
GO

/****** Object:  User [IIE\nrajmohan]    Script Date: 5/18/2012 9:33:15 AM ******/
CREATE USER [IIE\nrajmohan] FOR LOGIN [IIE\nrajmohan] WITH DEFAULT_SCHEMA=[dbo]
GO

/****** Object:  User [IIE\sshah]    Script Date: 5/18/2012 9:33:15 AM ******/
CREATE USER [IIE\sshah] FOR LOGIN [IIE\sshah] WITH DEFAULT_SCHEMA=[dbo]
GO

/****** Object:  User [nparikh]    Script Date: 5/18/2012 9:33:15 AM ******/
CREATE USER [nparikh] FOR LOGIN [nparikh] WITH DEFAULT_SCHEMA=[dbo]
GO

/****** Object:  User [soxuser]    Script Date: 5/18/2012 9:33:15 AM ******/
CREATE USER [soxuser] FOR LOGIN [soxuser] WITH DEFAULT_SCHEMA=[dbo]
GO

GRANT CONNECT TO [IIE\dkear] AS [dbo]
GO

GRANT CONNECT TO [IIE\dkukharenko] AS [dbo]
GO

GRANT CONNECT TO [IIE\Jchen2] AS [dbo]
GO

GRANT CONNECT TO [IIE\kmahadevan] AS [dbo]
GO

GRANT CONNECT TO [IIE\KSwamy] AS [dbo]
GO

GRANT CONNECT TO [IIE\mguddeti] AS [dbo]
GO

GRANT CONNECT TO [IIE\NParikh] AS [dbo]
GO

GRANT CONNECT TO [IIE\nrajmohan] AS [dbo]
GO

GRANT CONNECT TO [IIE\sshah] AS [dbo]
GO

GRANT CONNECT TO [nparikh] AS [dbo]
GO

GRANT CONNECT TO [soxuser] AS [dbo]
GO

ALTER DATABASE [sox] SET  READ_WRITE 
GO


