USE [SCD]
GO
/****** Object:  Database [Scard2.0]    Script Date: 4/12/2021 5:39:39 PM ******/
GO
/****** Object:  UserDefinedFunction [dbo].[FN_REPLACE_FIRST]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FN_REPLACE_FIRST](@X NVARCHAR(MAX), @F NVARCHAR(MAX), @R NVARCHAR(MAX)) RETURNS NVARCHAR(MAX) AS BEGIN
RETURN STUFF(@X, CHARINDEX(@F, @X), LEN(@F), @R)
END
GO
/****** Object:  UserDefinedFunction [dbo].[Split]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Split](@String varchar(MAX), @Delimiter char(1))       
returns @temptable TABLE (items varchar(MAX))       
as       
begin      
    declare @idx int       
    declare @slice varchar(8000)       

    select @idx = 1       
        if len(@String)<1 or @String is null  return       

    while @idx!= 0       
    begin       
        set @idx = charindex(@Delimiter,@String)       
        if @idx!=0       
            set @slice = left(@String,@idx - 1)       
        else       
            set @slice = @String       

        if(len(@slice)>0)  
            insert into @temptable(Items) values(@slice)       

        set @String = right(@String,len(@String) - @idx)       
        if len(@String) = 0 break       
    end   
return 
end
GO
/****** Object:  Table [dbo].[ScorecardMaster]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ScorecardMaster](
	[ScorecardID] [numeric](4, 0) NOT NULL,
	[ScorecardName] [varchar](20) NOT NULL,
	[Status] [numeric](1, 0) NOT NULL,
	[CompanyID] [numeric](5, 0) NULL,
 CONSTRAINT [PK_ScorecardMastet] PRIMARY KEY CLUSTERED 
(
	[ScorecardID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[scQLov]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[scQLov](
	[scQLOVID] [numeric](5, 0) NOT NULL,
	[scQuestionID] [numeric](3, 0) NOT NULL,
	[scQuestionValues] [varchar](12) NOT NULL,
	[scWeightage] [varchar](max) NULL,
 CONSTRAINT [PK_scQLov] PRIMARY KEY CLUSTERED 
(
	[scQLOVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[scQuestions]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[scQuestions](
	[scQuestionID] [numeric](3, 0) NOT NULL,
	[ParamID] [numeric](3, 0) NOT NULL,
	[ParamTitle] [varchar](90) NOT NULL,
	[Seq] [numeric](2, 0) NOT NULL,
	[scSectionID] [numeric](2, 0) NOT NULL,
	[QWght] [numeric](2, 0) NULL,
	[isMandatory] [bit] NULL,
	[IsCommentReq] [bit] NULL,
	[ScorecardID] [numeric](4, 0) NULL,
 CONSTRAINT [PK_scQuestions] PRIMARY KEY CLUSTERED 
(
	[scQuestionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[scSections]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[scSections](
	[scSectionID] [numeric](2, 0) NOT NULL,
	[SectionName] [varchar](50) NOT NULL,
	[SectionWght] [numeric](3, 0) NULL,
	[IsNewPage] [bit] NULL,
	[ScorecardID] [numeric](4, 0) NULL,
	[Seq] [numeric](2, 0) NULL,
 CONSTRAINT [PK_scSections] PRIMARY KEY CLUSTERED 
(
	[scSectionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[AuditQuestionsVW]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AuditQuestionsVW]
AS
SELECT TOP (100) PERCENT dbo.ScorecardMaster.ScorecardName, dbo.ScorecardMaster.ScorecardID, dbo.ScorecardMaster.CompanyID, dbo.scSections.Seq AS SSeq, dbo.scSections.SectionName, dbo.scSections.SectionWght, dbo.scSections.IsNewPage, dbo.scQuestions.ParamTitle, 
             dbo.scQuestions.Seq AS QSeq, dbo.scQLov.scQuestionValues
FROM   dbo.scSections INNER JOIN
             dbo.scQuestions ON dbo.scSections.scSectionID = dbo.scQuestions.scSectionID INNER JOIN
             dbo.ScorecardMaster ON dbo.scSections.ScorecardID = dbo.ScorecardMaster.ScorecardID LEFT OUTER JOIN
             dbo.scQLov ON dbo.scQuestions.scQuestionID = dbo.scQLov.scQuestionID
ORDER BY SSeq, QSeq
GO
/****** Object:  Table [dbo].[CompanyMaster]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CompanyMaster](
	[CompanyID] [numeric](5, 0) IDENTITY(1,1) NOT NULL,
	[CompanyName] [varchar](50) NOT NULL,
	[Address] [varchar](250) NULL,
	[ContactNo] [varchar](15) NULL,
	[url] [varchar](90) NULL,
	[Status] [numeric](1, 0) NULL,
 CONSTRAINT [PK_CompanyMaster] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RoleMaster]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RoleMaster](
	[RoleID] [numeric](2, 0) NOT NULL,
	[RoleName] [varchar](50) NOT NULL,
 CONSTRAINT [PK_RoleMaster] PRIMARY KEY CLUSTERED 
(
	[RoleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserMaster]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserMaster](
	[UserID] [numeric](4, 0) IDENTITY(1,1) NOT NULL,
	[CompanyID] [numeric](5, 0) NOT NULL,
	[RoleID] [numeric](2, 0) NULL,
	[UserName] [varchar](10) NOT NULL,
	[PCode] [varchar](10) NOT NULL,
	[DisplayName] [varchar](25) NOT NULL,
	[Status] [numeric](1, 0) NOT NULL,
	[MgrID] [numeric](4, 0) NULL,
	[Email] [varchar](50) NULL,
	[DOB] [date] NULL,
	[Country] [nvarchar](25) NULL,
	[Gender] [nvarchar](10) NULL,
	[StartDate] [date] NULL,
	[EndDate] [date] NULL,
 CONSTRAINT [PK_UserMaster] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[UserInfo]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[UserInfo]
AS
SELECT        dbo.UserMaster.UserID, dbo.UserMaster.UserName, dbo.UserMaster.DisplayName, dbo.CompanyMaster.CompanyName, dbo.RoleMaster.RoleName, dbo.UserMaster.PCode, dbo.UserMaster.CompanyID, 
                         dbo.UserMaster.Email, ISNULL(dbo.UserMaster.MgrID, 0) AS MgrID, dbo.UserMaster.Status
FROM            dbo.CompanyMaster WITH (nolock) INNER JOIN
                         dbo.UserMaster WITH (nolock) ON dbo.CompanyMaster.CompanyID = dbo.UserMaster.CompanyID INNER JOIN
                         dbo.RoleMaster WITH (nolock) ON dbo.UserMaster.RoleID = dbo.RoleMaster.RoleID
GO
/****** Object:  Table [dbo].[AuditReponses]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AuditReponses](
	[AuditResponeID] [bigint] IDENTITY(1,1) NOT NULL,
	[AuditID] [numeric](5, 0) NULL,
	[scQuestionID] [numeric](3, 0) NULL,
	[Response] [varchar](20) NULL,
	[Score] [varchar](10) NULL,
	[QWgt] [nvarchar](10) NULL,
	[comments] [varchar](max) NULL,
 CONSTRAINT [PK_AuditReponses] PRIMARY KEY CLUSTERED 
(
	[AuditResponeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Audits]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Audits](
	[AuditID] [numeric](5, 0) NOT NULL,
	[ScorecardID] [numeric](4, 0) NULL,
	[ADate] [datetime] NULL,
	[Status] [numeric](1, 0) NULL,
	[UserID] [numeric](4, 0) NULL,
 CONSTRAINT [PK_Audits] PRIMARY KEY CLUSTERED 
(
	[AuditID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ParaMaster]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ParaMaster](
	[ParamID] [numeric](3, 0) IDENTITY(1,1) NOT NULL,
	[ParamName] [varchar](90) NOT NULL,
	[ParamType] [varchar](10) NOT NULL,
	[IsDefault] [bit] NULL,
	[Status] [numeric](1, 0) NOT NULL,
 CONSTRAINT [PK_ParaMaster] PRIMARY KEY CLUSTERED 
(
	[ParamID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[UserAuditsVw]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[UserAuditsVw]
AS
SELECT        dbo.Audits.AuditID, dbo.ScorecardMaster.ScorecardName, dbo.ParaMaster.ParamID, dbo.AuditReponses.Response, dbo.AuditReponses.scQuestionID, dbo.scQuestions.ParamTitle, dbo.ParaMaster.ParamName, 
                         dbo.Audits.UserID, dbo.ScorecardMaster.CompanyID
FROM            dbo.Audits INNER JOIN
                         dbo.AuditReponses ON dbo.Audits.AuditID = dbo.AuditReponses.AuditID INNER JOIN
                         dbo.ScorecardMaster ON dbo.Audits.ScorecardID = dbo.ScorecardMaster.ScorecardID INNER JOIN
                         dbo.scQuestions ON dbo.AuditReponses.scQuestionID = dbo.scQuestions.scQuestionID INNER JOIN
                         dbo.ParaMaster ON dbo.scQuestions.ParamID = dbo.ParaMaster.ParamID
WHERE        (dbo.ParaMaster.ParamID = 1) OR
                         (dbo.ParaMaster.ParamID = 33) OR
                         (dbo.ParaMaster.ParamID = 4)
GO
/****** Object:  Table [dbo].[AuditResponseCalculations]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AuditResponseCalculations](
	[AuditResponseCalculationId] [int] IDENTITY(1,1) NOT NULL,
	[AuditResponseId] [int] NULL,
	[AuditId] [int] NULL,
	[SecSectionId] [int] NULL,
	[SecScore] [numeric](5, 2) NULL,
 CONSTRAINT [PK_AuditResponseCalculations] PRIMARY KEY CLUSTERED 
(
	[AuditResponseCalculationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Countries]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Countries](
	[Cint] [int] IDENTITY(1,1) NOT NULL,
	[Country] [nvarchar](50) NULL,
	[Code] [nvarchar](5) NULL,
 CONSTRAINT [PK_Countries] PRIMARY KEY CLUSTERED 
(
	[Cint] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Teams]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Teams](
	[TeamID] [numeric](5, 0) IDENTITY(1,1) NOT NULL,
	[TeamName] [varchar](20) NOT NULL,
	[TeamLeadID] [numeric](4, 0) NOT NULL,
 CONSTRAINT [PK_Teams] PRIMARY KEY CLUSTERED 
(
	[TeamID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserLog]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserLog](
	[LogiD] [numeric](7, 0) NOT NULL,
	[UserId] [numeric](4, 0) NULL,
	[LoggedIn] [datetime] NULL,
	[LoggedOut] [datetime] NULL,
 CONSTRAINT [PK_UserLog] PRIMARY KEY CLUSTERED 
(
	[LogiD] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[AuditReponses] ON 
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40168, CAST(1 AS Numeric(5, 0)), CAST(2 AS Numeric(3, 0)), N'Agent 2', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40169, CAST(1 AS Numeric(5, 0)), CAST(3 AS Numeric(3, 0)), N'Bosch Admin', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40170, CAST(1 AS Numeric(5, 0)), CAST(4 AS Numeric(3, 0)), N'JH88458', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40171, CAST(1 AS Numeric(5, 0)), CAST(5 AS Numeric(3, 0)), N'2021 04 04', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40172, CAST(1 AS Numeric(5, 0)), CAST(6 AS Numeric(3, 0)), N'2021 04 01', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40173, CAST(1 AS Numeric(5, 0)), CAST(7 AS Numeric(3, 0)), N'7', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40174, CAST(1 AS Numeric(5, 0)), CAST(8 AS Numeric(3, 0)), N'Harish', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40175, CAST(1 AS Numeric(5, 0)), CAST(9 AS Numeric(3, 0)), N'1', NULL, NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40176, CAST(1 AS Numeric(5, 0)), CAST(10 AS Numeric(3, 0)), N'5', NULL, NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40177, CAST(1 AS Numeric(5, 0)), CAST(11 AS Numeric(3, 0)), N'6', NULL, NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40178, CAST(1 AS Numeric(5, 0)), CAST(12 AS Numeric(3, 0)), N'6', NULL, NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40179, CAST(2 AS Numeric(5, 0)), CAST(2 AS Numeric(3, 0)), N'Agent 2', N'215', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40180, CAST(2 AS Numeric(5, 0)), CAST(3 AS Numeric(3, 0)), N'Bosch Admin', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40181, CAST(2 AS Numeric(5, 0)), CAST(4 AS Numeric(3, 0)), N'HJ04045', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40182, CAST(2 AS Numeric(5, 0)), CAST(5 AS Numeric(3, 0)), N'2021 04 04', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40183, CAST(2 AS Numeric(5, 0)), CAST(6 AS Numeric(3, 0)), N'2021 04 04', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40184, CAST(2 AS Numeric(5, 0)), CAST(7 AS Numeric(3, 0)), N'5', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40185, CAST(2 AS Numeric(5, 0)), CAST(8 AS Numeric(3, 0)), N'Lalitha', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40186, CAST(2 AS Numeric(5, 0)), CAST(9 AS Numeric(3, 0)), N'2', N'75', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40187, CAST(2 AS Numeric(5, 0)), CAST(10 AS Numeric(3, 0)), N'5', N'20', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40188, CAST(2 AS Numeric(5, 0)), CAST(11 AS Numeric(3, 0)), N'5', N'33', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40189, CAST(2 AS Numeric(5, 0)), CAST(12 AS Numeric(3, 0)), N'7', N'14', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40190, CAST(3 AS Numeric(5, 0)), CAST(2 AS Numeric(3, 0)), N'Agent 2', N'215', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40191, CAST(3 AS Numeric(5, 0)), CAST(3 AS Numeric(3, 0)), N'Bosch Admin', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40192, CAST(3 AS Numeric(5, 0)), CAST(4 AS Numeric(3, 0)), N'HJ04045', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40193, CAST(3 AS Numeric(5, 0)), CAST(5 AS Numeric(3, 0)), N'2021 04 04', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40194, CAST(3 AS Numeric(5, 0)), CAST(6 AS Numeric(3, 0)), N'2021 04 04', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40195, CAST(3 AS Numeric(5, 0)), CAST(7 AS Numeric(3, 0)), N'5', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40196, CAST(3 AS Numeric(5, 0)), CAST(8 AS Numeric(3, 0)), N'Lalitha', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40197, CAST(3 AS Numeric(5, 0)), CAST(9 AS Numeric(3, 0)), N'2', N'75', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40198, CAST(3 AS Numeric(5, 0)), CAST(10 AS Numeric(3, 0)), N'5', N'20', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40199, CAST(3 AS Numeric(5, 0)), CAST(11 AS Numeric(3, 0)), N'5', N'33', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40200, CAST(3 AS Numeric(5, 0)), CAST(12 AS Numeric(3, 0)), N'7', N'14', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40201, CAST(4 AS Numeric(5, 0)), CAST(2 AS Numeric(3, 0)), N'Agent 3', N'215', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40202, CAST(4 AS Numeric(5, 0)), CAST(3 AS Numeric(3, 0)), N'Bosch Admin', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40203, CAST(4 AS Numeric(5, 0)), CAST(4 AS Numeric(3, 0)), N'HJ8945', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40204, CAST(4 AS Numeric(5, 0)), CAST(5 AS Numeric(3, 0)), N'2021 04 04', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40205, CAST(4 AS Numeric(5, 0)), CAST(6 AS Numeric(3, 0)), N'2021 04 04', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40206, CAST(4 AS Numeric(5, 0)), CAST(7 AS Numeric(3, 0)), N'5', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40207, CAST(4 AS Numeric(5, 0)), CAST(8 AS Numeric(3, 0)), N'Kishore', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40208, CAST(4 AS Numeric(5, 0)), CAST(9 AS Numeric(3, 0)), N'2', N'75.00', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40209, CAST(4 AS Numeric(5, 0)), CAST(10 AS Numeric(3, 0)), N'5', N'20.00', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40210, CAST(4 AS Numeric(5, 0)), CAST(11 AS Numeric(3, 0)), N'5', N'33.33', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40211, CAST(4 AS Numeric(5, 0)), CAST(12 AS Numeric(3, 0)), N'7', N'14.28', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40212, CAST(5 AS Numeric(5, 0)), CAST(27 AS Numeric(3, 0)), N'Agent 2', N'215', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40213, CAST(5 AS Numeric(5, 0)), CAST(28 AS Numeric(3, 0)), N'Bosch Admin', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40214, CAST(5 AS Numeric(5, 0)), CAST(29 AS Numeric(3, 0)), N'HJ77457', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40215, CAST(5 AS Numeric(5, 0)), CAST(30 AS Numeric(3, 0)), N'2021 04 05', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40216, CAST(5 AS Numeric(5, 0)), CAST(31 AS Numeric(3, 0)), N'2021 04 01', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40217, CAST(5 AS Numeric(5, 0)), CAST(32 AS Numeric(3, 0)), N'5', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40218, CAST(5 AS Numeric(5, 0)), CAST(33 AS Numeric(3, 0)), N'Harish', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40219, CAST(5 AS Numeric(5, 0)), CAST(34 AS Numeric(3, 0)), N'0', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40220, CAST(5 AS Numeric(5, 0)), CAST(35 AS Numeric(3, 0)), N'4', N'40.00', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40221, CAST(5 AS Numeric(5, 0)), CAST(36 AS Numeric(3, 0)), N'5', N'33.33', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40222, CAST(5 AS Numeric(5, 0)), CAST(37 AS Numeric(3, 0)), N'Met', N'100', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40223, CAST(5 AS Numeric(5, 0)), CAST(38 AS Numeric(3, 0)), N'Met', N'100', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40224, CAST(6 AS Numeric(5, 0)), CAST(27 AS Numeric(3, 0)), N'Agent 1', N'214', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40225, CAST(6 AS Numeric(5, 0)), CAST(28 AS Numeric(3, 0)), N'Bosch Admin', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40226, CAST(6 AS Numeric(5, 0)), CAST(29 AS Numeric(3, 0)), N'HJ88458', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40227, CAST(6 AS Numeric(5, 0)), CAST(30 AS Numeric(3, 0)), N'2021 04 05', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40228, CAST(6 AS Numeric(5, 0)), CAST(31 AS Numeric(3, 0)), N'2021 04 01', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40229, CAST(6 AS Numeric(5, 0)), CAST(32 AS Numeric(3, 0)), N'6', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40230, CAST(6 AS Numeric(5, 0)), CAST(33 AS Numeric(3, 0)), N'Harish', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40231, CAST(6 AS Numeric(5, 0)), CAST(34 AS Numeric(3, 0)), N'0', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40232, CAST(6 AS Numeric(5, 0)), CAST(35 AS Numeric(3, 0)), N'4', N'40.00', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40233, CAST(6 AS Numeric(5, 0)), CAST(36 AS Numeric(3, 0)), N'4', N'50.00', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40234, CAST(6 AS Numeric(5, 0)), CAST(37 AS Numeric(3, 0)), N'Met', N'100', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40235, CAST(6 AS Numeric(5, 0)), CAST(38 AS Numeric(3, 0)), N'Met', N'100', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40236, CAST(7 AS Numeric(5, 0)), CAST(27 AS Numeric(3, 0)), N'Agent 1', N'214', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40237, CAST(7 AS Numeric(5, 0)), CAST(28 AS Numeric(3, 0)), N'Bosch Admin', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40238, CAST(7 AS Numeric(5, 0)), CAST(29 AS Numeric(3, 0)), N'94949', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40239, CAST(7 AS Numeric(5, 0)), CAST(30 AS Numeric(3, 0)), N'2021 04 05', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40240, CAST(7 AS Numeric(5, 0)), CAST(31 AS Numeric(3, 0)), N'2021 04 02', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40241, CAST(7 AS Numeric(5, 0)), CAST(32 AS Numeric(3, 0)), N'6', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40242, CAST(7 AS Numeric(5, 0)), CAST(33 AS Numeric(3, 0)), N'Kishore', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40243, CAST(7 AS Numeric(5, 0)), CAST(34 AS Numeric(3, 0)), N'0', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40244, CAST(7 AS Numeric(5, 0)), CAST(35 AS Numeric(3, 0)), N'5', N'20.00', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40245, CAST(7 AS Numeric(5, 0)), CAST(36 AS Numeric(3, 0)), N'6', N'16.66', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40246, CAST(7 AS Numeric(5, 0)), CAST(37 AS Numeric(3, 0)), N'Met', N'100', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40247, CAST(7 AS Numeric(5, 0)), CAST(38 AS Numeric(3, 0)), N'Met', N'100', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40248, CAST(8 AS Numeric(5, 0)), CAST(27 AS Numeric(3, 0)), N'Agent 1', N'214', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40249, CAST(8 AS Numeric(5, 0)), CAST(28 AS Numeric(3, 0)), N'Bosch Admin', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40250, CAST(8 AS Numeric(5, 0)), CAST(29 AS Numeric(3, 0)), N'HI88484', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40251, CAST(8 AS Numeric(5, 0)), CAST(30 AS Numeric(3, 0)), N'2021 04 07', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40252, CAST(8 AS Numeric(5, 0)), CAST(31 AS Numeric(3, 0)), N'2021 04 05', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40253, CAST(8 AS Numeric(5, 0)), CAST(32 AS Numeric(3, 0)), N'7', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40254, CAST(8 AS Numeric(5, 0)), CAST(33 AS Numeric(3, 0)), N'Lilly', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40255, CAST(8 AS Numeric(5, 0)), CAST(34 AS Numeric(3, 0)), N'0', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40256, CAST(8 AS Numeric(5, 0)), CAST(35 AS Numeric(3, 0)), N'4', N'40.00', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40257, CAST(8 AS Numeric(5, 0)), CAST(36 AS Numeric(3, 0)), N'5', N'33.33', NULL, N'l')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40258, CAST(8 AS Numeric(5, 0)), CAST(37 AS Numeric(3, 0)), N'Met', N'100', NULL, N'm')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40259, CAST(8 AS Numeric(5, 0)), CAST(38 AS Numeric(3, 0)), N'Not Met', N'0', NULL, N'n')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40260, CAST(9 AS Numeric(5, 0)), CAST(27 AS Numeric(3, 0)), N'Agent 1', N'214', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40261, CAST(9 AS Numeric(5, 0)), CAST(28 AS Numeric(3, 0)), N'Bosch Admin', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40262, CAST(9 AS Numeric(5, 0)), CAST(29 AS Numeric(3, 0)), N'JH88458', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40263, CAST(9 AS Numeric(5, 0)), CAST(30 AS Numeric(3, 0)), N'2021 04 06', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40264, CAST(9 AS Numeric(5, 0)), CAST(31 AS Numeric(3, 0)), N'2021 04 05', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40265, CAST(9 AS Numeric(5, 0)), CAST(32 AS Numeric(3, 0)), N'7', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40266, CAST(9 AS Numeric(5, 0)), CAST(33 AS Numeric(3, 0)), N'Suresh', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40267, CAST(9 AS Numeric(5, 0)), CAST(34 AS Numeric(3, 0)), N'0', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40268, CAST(9 AS Numeric(5, 0)), CAST(35 AS Numeric(3, 0)), N'5', N'20.00', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40269, CAST(9 AS Numeric(5, 0)), CAST(36 AS Numeric(3, 0)), N'6', N'16.66', NULL, N'p')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40270, CAST(9 AS Numeric(5, 0)), CAST(37 AS Numeric(3, 0)), N'Met', N'100', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40271, CAST(9 AS Numeric(5, 0)), CAST(38 AS Numeric(3, 0)), N'Met', N'100', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40272, CAST(10 AS Numeric(5, 0)), CAST(27 AS Numeric(3, 0)), N'Agent 2', N'215', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40273, CAST(10 AS Numeric(5, 0)), CAST(28 AS Numeric(3, 0)), N'Bosch Admin', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40274, CAST(10 AS Numeric(5, 0)), CAST(29 AS Numeric(3, 0)), N'IHS9088', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40275, CAST(10 AS Numeric(5, 0)), CAST(30 AS Numeric(3, 0)), N'2021 04 06', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40276, CAST(10 AS Numeric(5, 0)), CAST(31 AS Numeric(3, 0)), N'2021 04 01', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40277, CAST(10 AS Numeric(5, 0)), CAST(32 AS Numeric(3, 0)), N'7', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40278, CAST(10 AS Numeric(5, 0)), CAST(33 AS Numeric(3, 0)), N'Hari', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40279, CAST(10 AS Numeric(5, 0)), CAST(34 AS Numeric(3, 0)), N'0', N'76', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40280, CAST(10 AS Numeric(5, 0)), CAST(35 AS Numeric(3, 0)), N'4', N'40.00', NULL, N'list')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40281, CAST(10 AS Numeric(5, 0)), CAST(36 AS Numeric(3, 0)), N'3', N'66.66', NULL, N'findings')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40282, CAST(10 AS Numeric(5, 0)), CAST(37 AS Numeric(3, 0)), N'Met', N'100', NULL, N'ok')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40283, CAST(10 AS Numeric(5, 0)), CAST(38 AS Numeric(3, 0)), N'Met', N'100', NULL, N'ok')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40284, CAST(11 AS Numeric(5, 0)), CAST(28 AS Numeric(3, 0)), N'Bosch Admin', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40285, CAST(11 AS Numeric(5, 0)), CAST(29 AS Numeric(3, 0)), N'JK9945', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40286, CAST(11 AS Numeric(5, 0)), CAST(30 AS Numeric(3, 0)), N'2021 04 06', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40287, CAST(11 AS Numeric(5, 0)), CAST(31 AS Numeric(3, 0)), N'2021 04 02', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40288, CAST(11 AS Numeric(5, 0)), CAST(32 AS Numeric(3, 0)), N'5', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40289, CAST(11 AS Numeric(5, 0)), CAST(33 AS Numeric(3, 0)), N'Vihari', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40290, CAST(11 AS Numeric(5, 0)), CAST(34 AS Numeric(3, 0)), N'0', N'50', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40291, CAST(11 AS Numeric(5, 0)), CAST(35 AS Numeric(3, 0)), N'5', N'20.00', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40292, CAST(11 AS Numeric(5, 0)), CAST(36 AS Numeric(3, 0)), N'2', N'83.33', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40293, CAST(11 AS Numeric(5, 0)), CAST(37 AS Numeric(3, 0)), N'Met', N'100', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40294, CAST(11 AS Numeric(5, 0)), CAST(38 AS Numeric(3, 0)), N'Not Met', N'0', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40295, CAST(12 AS Numeric(5, 0)), CAST(27 AS Numeric(3, 0)), N'Agent 1', N'214', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40296, CAST(12 AS Numeric(5, 0)), CAST(28 AS Numeric(3, 0)), N'Bosch Admin', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40297, CAST(12 AS Numeric(5, 0)), CAST(29 AS Numeric(3, 0)), N'IHS9393', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40298, CAST(12 AS Numeric(5, 0)), CAST(30 AS Numeric(3, 0)), N'2021 04 07', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40299, CAST(12 AS Numeric(5, 0)), CAST(31 AS Numeric(3, 0)), N'2021 04 04', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40300, CAST(12 AS Numeric(5, 0)), CAST(32 AS Numeric(3, 0)), N'4', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40301, CAST(12 AS Numeric(5, 0)), CAST(33 AS Numeric(3, 0)), N'Kisore', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40302, CAST(12 AS Numeric(5, 0)), CAST(34 AS Numeric(3, 0)), N'0', N'86', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40303, CAST(12 AS Numeric(5, 0)), CAST(35 AS Numeric(3, 0)), N'3', N'60.00', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40304, CAST(12 AS Numeric(5, 0)), CAST(36 AS Numeric(3, 0)), N'2', N'83.33', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40305, CAST(12 AS Numeric(5, 0)), CAST(37 AS Numeric(3, 0)), N'Met', N'100', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40306, CAST(12 AS Numeric(5, 0)), CAST(38 AS Numeric(3, 0)), N'Met', N'100', NULL, N'kk')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40307, CAST(13 AS Numeric(5, 0)), CAST(27 AS Numeric(3, 0)), N'Agent 1', N'214', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40308, CAST(13 AS Numeric(5, 0)), CAST(28 AS Numeric(3, 0)), N'Bosch Admin', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40309, CAST(13 AS Numeric(5, 0)), CAST(29 AS Numeric(3, 0)), N'HSA8828', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40310, CAST(13 AS Numeric(5, 0)), CAST(30 AS Numeric(3, 0)), N'2021 04 07', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40311, CAST(13 AS Numeric(5, 0)), CAST(31 AS Numeric(3, 0)), N'2021 04 05', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40312, CAST(13 AS Numeric(5, 0)), CAST(32 AS Numeric(3, 0)), N'6', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40313, CAST(13 AS Numeric(5, 0)), CAST(33 AS Numeric(3, 0)), N'John', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40314, CAST(13 AS Numeric(5, 0)), CAST(34 AS Numeric(3, 0)), N'0', N'73.30', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40315, CAST(13 AS Numeric(5, 0)), CAST(35 AS Numeric(3, 0)), N'3', N'60.00', NULL, N'koinm')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40316, CAST(13 AS Numeric(5, 0)), CAST(36 AS Numeric(3, 0)), N'5', N'33.33', NULL, N'ppti')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40317, CAST(13 AS Numeric(5, 0)), CAST(37 AS Numeric(3, 0)), N'Met', N'100', NULL, N'ok')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40318, CAST(13 AS Numeric(5, 0)), CAST(38 AS Numeric(3, 0)), N'Met', N'100', NULL, N'ok')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40319, CAST(14 AS Numeric(5, 0)), CAST(27 AS Numeric(3, 0)), N'Agent 2', N'215', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40320, CAST(14 AS Numeric(5, 0)), CAST(28 AS Numeric(3, 0)), N'Bosch Admin', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40321, CAST(14 AS Numeric(5, 0)), CAST(29 AS Numeric(3, 0)), N'JK88494', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40322, CAST(14 AS Numeric(5, 0)), CAST(30 AS Numeric(3, 0)), N'2021 04 07', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40323, CAST(14 AS Numeric(5, 0)), CAST(31 AS Numeric(3, 0)), N'2021 04 05', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40324, CAST(14 AS Numeric(5, 0)), CAST(32 AS Numeric(3, 0)), N'5', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40325, CAST(14 AS Numeric(5, 0)), CAST(33 AS Numeric(3, 0)), N'David', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40326, CAST(14 AS Numeric(5, 0)), CAST(34 AS Numeric(3, 0)), N'0', N'52.50', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40327, CAST(14 AS Numeric(5, 0)), CAST(35 AS Numeric(3, 0)), N'3', N'60.00', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40328, CAST(14 AS Numeric(5, 0)), CAST(36 AS Numeric(3, 0)), N'4', N'50.00', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40329, CAST(14 AS Numeric(5, 0)), CAST(37 AS Numeric(3, 0)), N'Met', N'100', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40330, CAST(14 AS Numeric(5, 0)), CAST(38 AS Numeric(3, 0)), N'Not Met', N'0', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40331, CAST(15 AS Numeric(5, 0)), CAST(27 AS Numeric(3, 0)), N'Test Agent', N'313', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40332, CAST(15 AS Numeric(5, 0)), CAST(28 AS Numeric(3, 0)), N'Suresh BH', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40333, CAST(15 AS Numeric(5, 0)), CAST(29 AS Numeric(3, 0)), N'IHG8388', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40334, CAST(15 AS Numeric(5, 0)), CAST(30 AS Numeric(3, 0)), N'2021 04 07', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40335, CAST(15 AS Numeric(5, 0)), CAST(31 AS Numeric(3, 0)), N'2021 04 02', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40336, CAST(15 AS Numeric(5, 0)), CAST(32 AS Numeric(3, 0)), N'5', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40337, CAST(15 AS Numeric(5, 0)), CAST(33 AS Numeric(3, 0)), N'Prasad', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40338, CAST(15 AS Numeric(5, 0)), CAST(34 AS Numeric(3, 0)), N'0', N'90.80', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40339, CAST(15 AS Numeric(5, 0)), CAST(35 AS Numeric(3, 0)), N'2', N'80.00', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40340, CAST(15 AS Numeric(5, 0)), CAST(36 AS Numeric(3, 0)), N'2', N'83.33', NULL, N'j')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40341, CAST(15 AS Numeric(5, 0)), CAST(37 AS Numeric(3, 0)), N'Met', N'100', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40342, CAST(15 AS Numeric(5, 0)), CAST(38 AS Numeric(3, 0)), N'Met', N'100', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40343, CAST(16 AS Numeric(5, 0)), CAST(27 AS Numeric(3, 0)), N'Test Agent', N'313', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40344, CAST(16 AS Numeric(5, 0)), CAST(28 AS Numeric(3, 0)), N'Suresh BH', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40345, CAST(16 AS Numeric(5, 0)), CAST(29 AS Numeric(3, 0)), N'IPE8388', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40346, CAST(16 AS Numeric(5, 0)), CAST(30 AS Numeric(3, 0)), N'2021 04 07', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40347, CAST(16 AS Numeric(5, 0)), CAST(31 AS Numeric(3, 0)), N'2021 04 02', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40348, CAST(16 AS Numeric(5, 0)), CAST(32 AS Numeric(3, 0)), N'5', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40349, CAST(16 AS Numeric(5, 0)), CAST(33 AS Numeric(3, 0)), N'Kapil', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40350, CAST(16 AS Numeric(5, 0)), CAST(34 AS Numeric(3, 0)), N'0', N'390.80', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40351, CAST(16 AS Numeric(5, 0)), CAST(35 AS Numeric(3, 0)), N'2', N'80.00', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40352, CAST(16 AS Numeric(5, 0)), CAST(36 AS Numeric(3, 0)), N'2', N'83.33', NULL, N'j')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40353, CAST(16 AS Numeric(5, 0)), CAST(37 AS Numeric(3, 0)), N'Met', N'100', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40354, CAST(16 AS Numeric(5, 0)), CAST(38 AS Numeric(3, 0)), N'Met', N'100', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40355, CAST(17 AS Numeric(5, 0)), CAST(27 AS Numeric(3, 0)), N'Test Agent', N'313', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40356, CAST(17 AS Numeric(5, 0)), CAST(28 AS Numeric(3, 0)), N'Suresh BH', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40357, CAST(17 AS Numeric(5, 0)), CAST(29 AS Numeric(3, 0)), N'IPE8388', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40358, CAST(17 AS Numeric(5, 0)), CAST(30 AS Numeric(3, 0)), N'2021 04 07', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40359, CAST(17 AS Numeric(5, 0)), CAST(31 AS Numeric(3, 0)), N'2021 04 02', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40360, CAST(17 AS Numeric(5, 0)), CAST(32 AS Numeric(3, 0)), N'5', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40361, CAST(17 AS Numeric(5, 0)), CAST(33 AS Numeric(3, 0)), N'Kapil', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40362, CAST(17 AS Numeric(5, 0)), CAST(34 AS Numeric(3, 0)), N'0', N'391.26', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40363, CAST(17 AS Numeric(5, 0)), CAST(35 AS Numeric(3, 0)), N'2', N'80.00', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40364, CAST(17 AS Numeric(5, 0)), CAST(36 AS Numeric(3, 0)), N'2', N'83.33', NULL, N'j')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40365, CAST(17 AS Numeric(5, 0)), CAST(37 AS Numeric(3, 0)), N'Met', N'100', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40366, CAST(17 AS Numeric(5, 0)), CAST(38 AS Numeric(3, 0)), N'Met', N'100', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40367, CAST(18 AS Numeric(5, 0)), CAST(27 AS Numeric(3, 0)), N'Test Agent', N'313', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40368, CAST(18 AS Numeric(5, 0)), CAST(28 AS Numeric(3, 0)), N'Suresh BH', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40369, CAST(18 AS Numeric(5, 0)), CAST(29 AS Numeric(3, 0)), N'IPE8388', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40370, CAST(18 AS Numeric(5, 0)), CAST(30 AS Numeric(3, 0)), N'2021 04 07', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40371, CAST(18 AS Numeric(5, 0)), CAST(31 AS Numeric(3, 0)), N'2021 04 02', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40372, CAST(18 AS Numeric(5, 0)), CAST(32 AS Numeric(3, 0)), N'5', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40373, CAST(18 AS Numeric(5, 0)), CAST(33 AS Numeric(3, 0)), N'Kapil', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40374, CAST(18 AS Numeric(5, 0)), CAST(34 AS Numeric(3, 0)), N'0', N'91.26', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40375, CAST(18 AS Numeric(5, 0)), CAST(35 AS Numeric(3, 0)), N'2', N'80.00', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40376, CAST(18 AS Numeric(5, 0)), CAST(36 AS Numeric(3, 0)), N'2', N'83.33', NULL, N'j')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40377, CAST(18 AS Numeric(5, 0)), CAST(37 AS Numeric(3, 0)), N'Met', N'100', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40378, CAST(18 AS Numeric(5, 0)), CAST(38 AS Numeric(3, 0)), N'Met', N'100', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40379, CAST(19 AS Numeric(5, 0)), CAST(27 AS Numeric(3, 0)), N'Test Agent', N'313', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40380, CAST(19 AS Numeric(5, 0)), CAST(28 AS Numeric(3, 0)), N'Suresh BH', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40381, CAST(19 AS Numeric(5, 0)), CAST(29 AS Numeric(3, 0)), N'IHG8388', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40382, CAST(19 AS Numeric(5, 0)), CAST(30 AS Numeric(3, 0)), N'2021 04 07', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40383, CAST(19 AS Numeric(5, 0)), CAST(31 AS Numeric(3, 0)), N'2021 04 02', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40384, CAST(19 AS Numeric(5, 0)), CAST(32 AS Numeric(3, 0)), N'5', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40385, CAST(19 AS Numeric(5, 0)), CAST(33 AS Numeric(3, 0)), N'Prasad', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40386, CAST(19 AS Numeric(5, 0)), CAST(34 AS Numeric(3, 0)), N'0', N'90.75', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40387, CAST(19 AS Numeric(5, 0)), CAST(35 AS Numeric(3, 0)), N'2', N'80.00', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40388, CAST(19 AS Numeric(5, 0)), CAST(36 AS Numeric(3, 0)), N'2', N'83.33', NULL, N'j')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40389, CAST(19 AS Numeric(5, 0)), CAST(37 AS Numeric(3, 0)), N'Met', N'100', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40390, CAST(19 AS Numeric(5, 0)), CAST(38 AS Numeric(3, 0)), N'Met', N'100', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40391, CAST(20 AS Numeric(5, 0)), CAST(27 AS Numeric(3, 0)), N'Test Agent', N'313', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40392, CAST(20 AS Numeric(5, 0)), CAST(28 AS Numeric(3, 0)), N'Suresh BH', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40393, CAST(20 AS Numeric(5, 0)), CAST(29 AS Numeric(3, 0)), N'IPE8388', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40394, CAST(20 AS Numeric(5, 0)), CAST(30 AS Numeric(3, 0)), N'2021 04 07', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40395, CAST(20 AS Numeric(5, 0)), CAST(31 AS Numeric(3, 0)), N'2021 04 02', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40396, CAST(20 AS Numeric(5, 0)), CAST(32 AS Numeric(3, 0)), N'5', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40397, CAST(20 AS Numeric(5, 0)), CAST(33 AS Numeric(3, 0)), N'Kapil', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40398, CAST(20 AS Numeric(5, 0)), CAST(34 AS Numeric(3, 0)), N'0', N'91.26', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40399, CAST(20 AS Numeric(5, 0)), CAST(35 AS Numeric(3, 0)), N'2', N'80.00', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40400, CAST(20 AS Numeric(5, 0)), CAST(36 AS Numeric(3, 0)), N'2', N'83.33', NULL, N'j')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40401, CAST(20 AS Numeric(5, 0)), CAST(37 AS Numeric(3, 0)), N'Met', N'100', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40402, CAST(20 AS Numeric(5, 0)), CAST(38 AS Numeric(3, 0)), N'Met', N'100', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40403, CAST(21 AS Numeric(5, 0)), CAST(28 AS Numeric(3, 0)), N'Suresh BH', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40404, CAST(21 AS Numeric(5, 0)), CAST(29 AS Numeric(3, 0)), N'IPR8977', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40405, CAST(21 AS Numeric(5, 0)), CAST(30 AS Numeric(3, 0)), N'2021 04 07', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40406, CAST(21 AS Numeric(5, 0)), CAST(31 AS Numeric(3, 0)), N'2021 04 02', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40407, CAST(21 AS Numeric(5, 0)), CAST(32 AS Numeric(3, 0)), N'4', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40408, CAST(21 AS Numeric(5, 0)), CAST(33 AS Numeric(3, 0)), N'Jillar', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40409, CAST(21 AS Numeric(5, 0)), CAST(34 AS Numeric(3, 0)), N'0', N'77.50', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40410, CAST(21 AS Numeric(5, 0)), CAST(35 AS Numeric(3, 0)), N'3', N'60.00', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40411, CAST(21 AS Numeric(5, 0)), CAST(36 AS Numeric(3, 0)), N'4', N'50.00', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40412, CAST(21 AS Numeric(5, 0)), CAST(37 AS Numeric(3, 0)), N'Met', N'100', NULL, N'p')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40413, CAST(21 AS Numeric(5, 0)), CAST(38 AS Numeric(3, 0)), N'Met', N'100', NULL, N'j')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40414, CAST(22 AS Numeric(5, 0)), CAST(21 AS Numeric(3, 0)), N'Suresh BH', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40415, CAST(22 AS Numeric(5, 0)), CAST(22 AS Numeric(3, 0)), N'IHS', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40416, CAST(22 AS Numeric(5, 0)), CAST(23 AS Numeric(3, 0)), N'2021 04 07', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40417, CAST(22 AS Numeric(5, 0)), CAST(24 AS Numeric(3, 0)), N'2021 04 05', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40418, CAST(22 AS Numeric(5, 0)), CAST(25 AS Numeric(3, 0)), N'7', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40419, CAST(22 AS Numeric(5, 0)), CAST(26 AS Numeric(3, 0)), N'Jagadesh', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40420, CAST(22 AS Numeric(5, 0)), CAST(44 AS Numeric(3, 0)), N'0', N'88.56', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40421, CAST(22 AS Numeric(5, 0)), CAST(39 AS Numeric(3, 0)), N'Met', N'100', NULL, N'j')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40422, CAST(22 AS Numeric(5, 0)), CAST(40 AS Numeric(3, 0)), N'Met', N'100', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40423, CAST(22 AS Numeric(5, 0)), CAST(41 AS Numeric(3, 0)), N'Not Met', N'0', NULL, N'j')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40424, CAST(22 AS Numeric(5, 0)), CAST(42 AS Numeric(3, 0)), N'1', N'100', NULL, N'p')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40425, CAST(22 AS Numeric(5, 0)), CAST(43 AS Numeric(3, 0)), N'3', N'66.66', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40426, CAST(23 AS Numeric(5, 0)), CAST(21 AS Numeric(3, 0)), N'Suresh BH', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40427, CAST(23 AS Numeric(5, 0)), CAST(22 AS Numeric(3, 0)), N'HDF0987', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40428, CAST(23 AS Numeric(5, 0)), CAST(23 AS Numeric(3, 0)), N'2021 04 07', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40429, CAST(23 AS Numeric(5, 0)), CAST(24 AS Numeric(3, 0)), N'2021 04 05', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40430, CAST(23 AS Numeric(5, 0)), CAST(25 AS Numeric(3, 0)), N'7', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40431, CAST(23 AS Numeric(5, 0)), CAST(26 AS Numeric(3, 0)), N'Kumar', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40432, CAST(23 AS Numeric(5, 0)), CAST(44 AS Numeric(3, 0)), N'0', N'50.28', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40433, CAST(23 AS Numeric(5, 0)), CAST(39 AS Numeric(3, 0)), N'Met', N'100', NULL, N'did as per need')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40434, CAST(23 AS Numeric(5, 0)), CAST(40 AS Numeric(3, 0)), N'Not Met', N'0', NULL, N'preformed ')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40435, CAST(23 AS Numeric(5, 0)), CAST(41 AS Numeric(3, 0)), N'Met', N'100', NULL, N'process followed')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40436, CAST(23 AS Numeric(5, 0)), CAST(42 AS Numeric(3, 0)), N'3', N'50.00', NULL, N'ok')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40437, CAST(23 AS Numeric(5, 0)), CAST(43 AS Numeric(3, 0)), N'5', N'33.33', NULL, N'systems')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40438, CAST(24 AS Numeric(5, 0)), CAST(20 AS Numeric(3, 0)), N'Agent 2', N'215', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40439, CAST(24 AS Numeric(5, 0)), CAST(21 AS Numeric(3, 0)), N'Suresh BH', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40440, CAST(24 AS Numeric(5, 0)), CAST(22 AS Numeric(3, 0)), N'HJG8386', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40441, CAST(24 AS Numeric(5, 0)), CAST(23 AS Numeric(3, 0)), N'2021 04 07', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40442, CAST(24 AS Numeric(5, 0)), CAST(24 AS Numeric(3, 0)), N'2021 04 05', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40443, CAST(24 AS Numeric(5, 0)), CAST(25 AS Numeric(3, 0)), N'7', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40444, CAST(24 AS Numeric(5, 0)), CAST(26 AS Numeric(3, 0)), N'John', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40445, CAST(24 AS Numeric(5, 0)), CAST(44 AS Numeric(3, 0)), N'0', N'62.56', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40446, CAST(24 AS Numeric(5, 0)), CAST(39 AS Numeric(3, 0)), N'Met', N'100', NULL, N'ok')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40447, CAST(24 AS Numeric(5, 0)), CAST(40 AS Numeric(3, 0)), N'Met', N'100', NULL, N'ok')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40448, CAST(24 AS Numeric(5, 0)), CAST(41 AS Numeric(3, 0)), N'Met', N'100', NULL, N'ok')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40449, CAST(24 AS Numeric(5, 0)), CAST(42 AS Numeric(3, 0)), N'5', N'0', NULL, N'ok')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40450, CAST(24 AS Numeric(5, 0)), CAST(43 AS Numeric(3, 0)), N'6', N'16.66', NULL, N'ok')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40451, CAST(25 AS Numeric(5, 0)), CAST(21 AS Numeric(3, 0)), N'Bosch Admin', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40452, CAST(25 AS Numeric(5, 0)), CAST(22 AS Numeric(3, 0)), N'JH8766', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40453, CAST(25 AS Numeric(5, 0)), CAST(23 AS Numeric(3, 0)), N'2021 04 08', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40454, CAST(25 AS Numeric(5, 0)), CAST(24 AS Numeric(3, 0)), N'2021 04 05', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40455, CAST(25 AS Numeric(5, 0)), CAST(25 AS Numeric(3, 0)), N'6', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40456, CAST(25 AS Numeric(5, 0)), CAST(26 AS Numeric(3, 0)), N'Williams', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40457, CAST(25 AS Numeric(5, 0)), CAST(44 AS Numeric(3, 0)), N'80', N'80.00', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40458, CAST(25 AS Numeric(5, 0)), CAST(39 AS Numeric(3, 0)), N'Met', N'100', NULL, N'ok')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40459, CAST(25 AS Numeric(5, 0)), CAST(40 AS Numeric(3, 0)), N'Met', N'100', NULL, N'ok')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40460, CAST(25 AS Numeric(5, 0)), CAST(41 AS Numeric(3, 0)), N'Met', N'100', NULL, N'ok')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40461, CAST(25 AS Numeric(5, 0)), CAST(42 AS Numeric(3, 0)), N'3', N'50.00', NULL, N'ok')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40462, CAST(25 AS Numeric(5, 0)), CAST(43 AS Numeric(3, 0)), N'4', N'50.00', NULL, N'ok')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40463, CAST(26 AS Numeric(5, 0)), CAST(27 AS Numeric(3, 0)), N'Agent 2', N'215', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40464, CAST(26 AS Numeric(5, 0)), CAST(28 AS Numeric(3, 0)), N'Bosch Admin', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40465, CAST(26 AS Numeric(5, 0)), CAST(29 AS Numeric(3, 0)), N'JH8388', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40466, CAST(26 AS Numeric(5, 0)), CAST(30 AS Numeric(3, 0)), N'2021 04 08', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40467, CAST(26 AS Numeric(5, 0)), CAST(31 AS Numeric(3, 0)), N'2021 04 05', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40468, CAST(26 AS Numeric(5, 0)), CAST(32 AS Numeric(3, 0)), N'5', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40469, CAST(26 AS Numeric(5, 0)), CAST(33 AS Numeric(3, 0)), N'Prasad', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40470, CAST(26 AS Numeric(5, 0)), CAST(34 AS Numeric(3, 0)), N'0', N'43.25', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40471, CAST(26 AS Numeric(5, 0)), CAST(35 AS Numeric(3, 0)), N'4', N'40.00', NULL, N'performed')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40472, CAST(26 AS Numeric(5, 0)), CAST(36 AS Numeric(3, 0)), N'5', N'33.33', NULL, N'ok')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40473, CAST(26 AS Numeric(5, 0)), CAST(37 AS Numeric(3, 0)), N'Met', N'100', NULL, N'ok')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40474, CAST(26 AS Numeric(5, 0)), CAST(38 AS Numeric(3, 0)), N'Not Met', N'0', NULL, N'ok')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40475, CAST(27 AS Numeric(5, 0)), CAST(21 AS Numeric(3, 0)), N'Suresh BH', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40476, CAST(27 AS Numeric(5, 0)), CAST(22 AS Numeric(3, 0)), N'HJ6778', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40477, CAST(27 AS Numeric(5, 0)), CAST(23 AS Numeric(3, 0)), N'2021 04 07', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40478, CAST(27 AS Numeric(5, 0)), CAST(24 AS Numeric(3, 0)), N'2021 04 05', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40479, CAST(27 AS Numeric(5, 0)), CAST(25 AS Numeric(3, 0)), N'6', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40480, CAST(27 AS Numeric(5, 0)), CAST(26 AS Numeric(3, 0)), N'Tariq', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40481, CAST(27 AS Numeric(5, 0)), CAST(44 AS Numeric(3, 0)), N'50', N'50.28', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40482, CAST(27 AS Numeric(5, 0)), CAST(39 AS Numeric(3, 0)), N'Met', N'100', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40483, CAST(27 AS Numeric(5, 0)), CAST(40 AS Numeric(3, 0)), N'Not Met', N'0', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40484, CAST(27 AS Numeric(5, 0)), CAST(41 AS Numeric(3, 0)), N'Met', N'100', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40485, CAST(27 AS Numeric(5, 0)), CAST(42 AS Numeric(3, 0)), N'3', N'50.00', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40486, CAST(27 AS Numeric(5, 0)), CAST(43 AS Numeric(3, 0)), N'5', N'33.33', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40487, CAST(28 AS Numeric(5, 0)), CAST(28 AS Numeric(3, 0)), N'Bosch Admin', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40488, CAST(28 AS Numeric(5, 0)), CAST(29 AS Numeric(3, 0)), N'IHS76364', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40489, CAST(28 AS Numeric(5, 0)), CAST(30 AS Numeric(3, 0)), N'2021 04 07', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40490, CAST(28 AS Numeric(5, 0)), CAST(31 AS Numeric(3, 0)), N'2021 04 05', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40491, CAST(28 AS Numeric(5, 0)), CAST(32 AS Numeric(3, 0)), N'7', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40492, CAST(28 AS Numeric(5, 0)), CAST(33 AS Numeric(3, 0)), N'Hemanth', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40493, CAST(28 AS Numeric(5, 0)), CAST(34 AS Numeric(3, 0)), N'59', N'59.00', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40494, CAST(28 AS Numeric(5, 0)), CAST(35 AS Numeric(3, 0)), N'5', N'20.00', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40495, CAST(28 AS Numeric(5, 0)), CAST(36 AS Numeric(3, 0)), N'6', N'16.66', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40496, CAST(28 AS Numeric(5, 0)), CAST(37 AS Numeric(3, 0)), N'Met', N'100', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40497, CAST(28 AS Numeric(5, 0)), CAST(38 AS Numeric(3, 0)), N'Met', N'100', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40498, CAST(29 AS Numeric(5, 0)), CAST(45 AS Numeric(3, 0)), N'Agent 1', N'214', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40499, CAST(29 AS Numeric(5, 0)), CAST(46 AS Numeric(3, 0)), N'Bosch Admin', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40500, CAST(29 AS Numeric(5, 0)), CAST(47 AS Numeric(3, 0)), N'IHS8857', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40501, CAST(29 AS Numeric(5, 0)), CAST(48 AS Numeric(3, 0)), N'2021 04 07', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40502, CAST(29 AS Numeric(5, 0)), CAST(49 AS Numeric(3, 0)), N'2021 04 05', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40503, CAST(29 AS Numeric(5, 0)), CAST(50 AS Numeric(3, 0)), N'7', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40504, CAST(29 AS Numeric(5, 0)), CAST(51 AS Numeric(3, 0)), N'Harish', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40505, CAST(29 AS Numeric(5, 0)), CAST(52 AS Numeric(3, 0)), N'99', N'99.25', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40506, CAST(29 AS Numeric(5, 0)), CAST(53 AS Numeric(3, 0)), N'1', N'100', NULL, N'some')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40507, CAST(29 AS Numeric(5, 0)), CAST(54 AS Numeric(3, 0)), N'Met', N'100', NULL, N'some')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40508, CAST(29 AS Numeric(5, 0)), CAST(55 AS Numeric(3, 0)), N'Met', N'100', NULL, N'sone')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40509, CAST(29 AS Numeric(5, 0)), CAST(56 AS Numeric(3, 0)), N'Met', N'100', NULL, N'score')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40510, CAST(29 AS Numeric(5, 0)), CAST(57 AS Numeric(3, 0)), N'Met', N'100', NULL, N'score')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40511, CAST(30 AS Numeric(5, 0)), CAST(45 AS Numeric(3, 0)), N'Night Lead', N'8', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40512, CAST(30 AS Numeric(5, 0)), CAST(46 AS Numeric(3, 0)), N'Bosch Admin', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40513, CAST(30 AS Numeric(5, 0)), CAST(47 AS Numeric(3, 0)), N'IHS8488', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40514, CAST(30 AS Numeric(5, 0)), CAST(48 AS Numeric(3, 0)), N'2021 04 10', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40515, CAST(30 AS Numeric(5, 0)), CAST(49 AS Numeric(3, 0)), N'2021 04 05', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40516, CAST(30 AS Numeric(5, 0)), CAST(50 AS Numeric(3, 0)), N'7', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40517, CAST(30 AS Numeric(5, 0)), CAST(51 AS Numeric(3, 0)), N'Harish', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40518, CAST(30 AS Numeric(5, 0)), CAST(52 AS Numeric(3, 0)), N'100', N'100.00', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40519, CAST(30 AS Numeric(5, 0)), CAST(53 AS Numeric(3, 0)), N'1', N'100', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40520, CAST(30 AS Numeric(5, 0)), CAST(54 AS Numeric(3, 0)), N'Met', N'100', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40521, CAST(30 AS Numeric(5, 0)), CAST(55 AS Numeric(3, 0)), N'Met', N'100', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40522, CAST(30 AS Numeric(5, 0)), CAST(56 AS Numeric(3, 0)), N'Met', N'100', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40523, CAST(30 AS Numeric(5, 0)), CAST(57 AS Numeric(3, 0)), N'Met', N'100', NULL, N'k')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40524, CAST(31 AS Numeric(5, 0)), CAST(46 AS Numeric(3, 0)), N'Bosch Admin', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40525, CAST(31 AS Numeric(5, 0)), CAST(47 AS Numeric(3, 0)), N'IGH8976', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40526, CAST(31 AS Numeric(5, 0)), CAST(48 AS Numeric(3, 0)), N'2021 04 10', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40527, CAST(31 AS Numeric(5, 0)), CAST(49 AS Numeric(3, 0)), N'2021 04 05', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40528, CAST(31 AS Numeric(5, 0)), CAST(50 AS Numeric(3, 0)), N'7', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40529, CAST(31 AS Numeric(5, 0)), CAST(51 AS Numeric(3, 0)), N'Lokesh', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40530, CAST(31 AS Numeric(5, 0)), CAST(52 AS Numeric(3, 0)), N'86', N'86.75', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40531, CAST(31 AS Numeric(5, 0)), CAST(53 AS Numeric(3, 0)), N'1', N'100', NULL, N'K')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40532, CAST(31 AS Numeric(5, 0)), CAST(54 AS Numeric(3, 0)), N'Met', N'100', NULL, N'L')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40533, CAST(31 AS Numeric(5, 0)), CAST(55 AS Numeric(3, 0)), N'Not Met', N'0', NULL, N'M')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40534, CAST(31 AS Numeric(5, 0)), CAST(56 AS Numeric(3, 0)), N'Not Met', N'0', NULL, N'N')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40535, CAST(31 AS Numeric(5, 0)), CAST(57 AS Numeric(3, 0)), N'Met', N'100', NULL, N'O')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40536, CAST(32 AS Numeric(5, 0)), CAST(46 AS Numeric(3, 0)), N'Bosch Admin', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40537, CAST(32 AS Numeric(5, 0)), CAST(47 AS Numeric(3, 0)), N'AQS8767', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40538, CAST(32 AS Numeric(5, 0)), CAST(48 AS Numeric(3, 0)), N'2021 04 10', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40539, CAST(32 AS Numeric(5, 0)), CAST(49 AS Numeric(3, 0)), N'2021 04 06', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40540, CAST(32 AS Numeric(5, 0)), CAST(50 AS Numeric(3, 0)), N'7', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40541, CAST(32 AS Numeric(5, 0)), CAST(51 AS Numeric(3, 0)), N'Kishore', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40542, CAST(32 AS Numeric(5, 0)), CAST(52 AS Numeric(3, 0)), N'100', N'100.00', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40543, CAST(32 AS Numeric(5, 0)), CAST(53 AS Numeric(3, 0)), N'1', N'100', NULL, N'1 comment')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40544, CAST(32 AS Numeric(5, 0)), CAST(54 AS Numeric(3, 0)), N'Met', N'100', NULL, N'2 comment')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40545, CAST(32 AS Numeric(5, 0)), CAST(55 AS Numeric(3, 0)), N'Met', N'100', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40546, CAST(32 AS Numeric(5, 0)), CAST(56 AS Numeric(3, 0)), N'Met', N'100', NULL, N'no comment')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40547, CAST(32 AS Numeric(5, 0)), CAST(57 AS Numeric(3, 0)), N'Met', N'100', NULL, N'yes comment')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40548, CAST(33 AS Numeric(5, 0)), CAST(27 AS Numeric(3, 0)), N'Ramesh AK', N'4', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40549, CAST(33 AS Numeric(5, 0)), CAST(28 AS Numeric(3, 0)), N'Bosch Admin', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40550, CAST(33 AS Numeric(5, 0)), CAST(29 AS Numeric(3, 0)), N'PIT8765', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40551, CAST(33 AS Numeric(5, 0)), CAST(30 AS Numeric(3, 0)), N'2021 04 10', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40552, CAST(33 AS Numeric(5, 0)), CAST(31 AS Numeric(3, 0)), N'2021 04 05', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40553, CAST(33 AS Numeric(5, 0)), CAST(32 AS Numeric(3, 0)), N'5', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40554, CAST(33 AS Numeric(5, 0)), CAST(33 AS Numeric(3, 0)), N'Jasmine', NULL, NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40555, CAST(33 AS Numeric(5, 0)), CAST(34 AS Numeric(3, 0)), N'82', N'82.50', NULL, NULL)
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40556, CAST(33 AS Numeric(5, 0)), CAST(35 AS Numeric(3, 0)), N'2', N'80.00', NULL, N'K')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40557, CAST(33 AS Numeric(5, 0)), CAST(36 AS Numeric(3, 0)), N'4', N'50.00', NULL, N'K2')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40558, CAST(33 AS Numeric(5, 0)), CAST(37 AS Numeric(3, 0)), N'Met', N'100', NULL, N'K3')
GO
INSERT [dbo].[AuditReponses] ([AuditResponeID], [AuditID], [scQuestionID], [Response], [Score], [QWgt], [comments]) VALUES (40559, CAST(33 AS Numeric(5, 0)), CAST(38 AS Numeric(3, 0)), N'Met', N'100', NULL, N'K5')
GO
SET IDENTITY_INSERT [dbo].[AuditReponses] OFF
GO
SET IDENTITY_INSERT [dbo].[AuditResponseCalculations] ON 
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1017, NULL, 1, 3, CAST(60.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1018, NULL, 1, 4, CAST(22.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1019, NULL, 2, 3, CAST(47.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1020, NULL, 2, 4, CAST(23.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1021, NULL, 3, 3, CAST(47.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1022, NULL, 3, 4, CAST(23.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1023, NULL, 4, 3, CAST(47.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1024, NULL, 4, 4, CAST(23.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1025, NULL, 5, 8, CAST(18.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1026, NULL, 5, 9, CAST(50.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1027, NULL, 6, 8, CAST(22.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1028, NULL, 6, 9, CAST(50.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1029, NULL, 7, 8, CAST(9.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1030, NULL, 7, 9, CAST(50.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1031, NULL, 8, 8, CAST(18.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1032, NULL, 8, 9, CAST(25.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1033, NULL, 9, 8, CAST(9.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1034, NULL, 9, 9, CAST(50.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1035, NULL, 10, 8, CAST(26.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1036, NULL, 10, 9, CAST(50.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1037, NULL, 11, 8, CAST(25.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1038, NULL, 11, 9, CAST(25.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1039, NULL, 12, 8, CAST(35.80 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1040, NULL, 12, 9, CAST(50.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1041, NULL, 13, 8, CAST(23.30 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1042, NULL, 13, 9, CAST(50.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1043, NULL, 14, 8, CAST(27.50 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1044, NULL, 14, 9, CAST(25.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1045, NULL, 15, 8, CAST(40.80 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1046, NULL, 15, 9, CAST(50.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1047, NULL, 16, 8, CAST(40.80 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1048, NULL, 16, 9, CAST(50.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1049, NULL, 17, 8, CAST(40.68 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1050, NULL, 17, 9, CAST(50.58 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1051, NULL, 18, 8, CAST(40.68 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1052, NULL, 18, 9, CAST(50.58 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1053, NULL, 19, 8, CAST(40.75 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1054, NULL, 19, 9, CAST(50.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1055, NULL, 20, 8, CAST(40.68 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1056, NULL, 20, 9, CAST(50.58 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1057, NULL, 21, 8, CAST(27.50 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1058, NULL, 21, 9, CAST(50.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1059, NULL, 22, 10, CAST(54.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1060, NULL, 22, 11, CAST(34.56 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1061, NULL, 23, 10, CAST(33.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1062, NULL, 23, 11, CAST(17.28 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1063, NULL, 24, 10, CAST(60.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1064, NULL, 24, 11, CAST(2.56 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1065, NULL, 25, 10, CAST(60.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1066, NULL, 25, 11, CAST(20.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1067, NULL, 26, 8, CAST(18.25 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1068, NULL, 26, 9, CAST(25.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1069, NULL, 27, 10, CAST(33.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1070, NULL, 27, 11, CAST(17.28 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1071, NULL, 28, 8, CAST(9.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1072, NULL, 28, 9, CAST(50.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1073, NULL, 29, 13, CAST(74.75 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1074, NULL, 29, 14, CAST(24.50 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1075, NULL, 30, 13, CAST(75.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1076, NULL, 30, 14, CAST(25.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1077, NULL, 31, 13, CAST(74.25 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1078, NULL, 31, 14, CAST(12.50 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1079, NULL, 32, 13, CAST(75.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1080, NULL, 32, 14, CAST(25.00 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1081, NULL, 33, 8, CAST(32.50 AS Numeric(5, 2)))
GO
INSERT [dbo].[AuditResponseCalculations] ([AuditResponseCalculationId], [AuditResponseId], [AuditId], [SecSectionId], [SecScore]) VALUES (1082, NULL, 33, 9, CAST(50.00 AS Numeric(5, 2)))
GO
SET IDENTITY_INSERT [dbo].[AuditResponseCalculations] OFF
GO
INSERT [dbo].[Audits] ([AuditID], [ScorecardID], [ADate], [Status], [UserID]) VALUES (CAST(1 AS Numeric(5, 0)), CAST(2 AS Numeric(4, 0)), CAST(N'2021-04-04T23:28:25.530' AS DateTime), CAST(0 AS Numeric(1, 0)), CAST(2 AS Numeric(4, 0)))
GO
INSERT [dbo].[Audits] ([AuditID], [ScorecardID], [ADate], [Status], [UserID]) VALUES (CAST(2 AS Numeric(5, 0)), CAST(2 AS Numeric(4, 0)), CAST(N'2021-04-04T23:57:57.243' AS DateTime), CAST(1 AS Numeric(1, 0)), CAST(2 AS Numeric(4, 0)))
GO
INSERT [dbo].[Audits] ([AuditID], [ScorecardID], [ADate], [Status], [UserID]) VALUES (CAST(3 AS Numeric(5, 0)), CAST(2 AS Numeric(4, 0)), CAST(N'2021-04-05T00:00:46.743' AS DateTime), CAST(1 AS Numeric(1, 0)), CAST(2 AS Numeric(4, 0)))
GO
INSERT [dbo].[Audits] ([AuditID], [ScorecardID], [ADate], [Status], [UserID]) VALUES (CAST(4 AS Numeric(5, 0)), CAST(2 AS Numeric(4, 0)), CAST(N'2021-04-05T00:11:12.090' AS DateTime), CAST(1 AS Numeric(1, 0)), CAST(2 AS Numeric(4, 0)))
GO
INSERT [dbo].[Audits] ([AuditID], [ScorecardID], [ADate], [Status], [UserID]) VALUES (CAST(5 AS Numeric(5, 0)), CAST(5 AS Numeric(4, 0)), CAST(N'2021-04-05T22:26:42.060' AS DateTime), CAST(1 AS Numeric(1, 0)), CAST(2 AS Numeric(4, 0)))
GO
INSERT [dbo].[Audits] ([AuditID], [ScorecardID], [ADate], [Status], [UserID]) VALUES (CAST(6 AS Numeric(5, 0)), CAST(5 AS Numeric(4, 0)), CAST(N'2021-04-05T22:30:59.633' AS DateTime), CAST(1 AS Numeric(1, 0)), CAST(2 AS Numeric(4, 0)))
GO
INSERT [dbo].[Audits] ([AuditID], [ScorecardID], [ADate], [Status], [UserID]) VALUES (CAST(7 AS Numeric(5, 0)), CAST(5 AS Numeric(4, 0)), CAST(N'2021-04-05T23:40:27.313' AS DateTime), CAST(1 AS Numeric(1, 0)), CAST(2 AS Numeric(4, 0)))
GO
INSERT [dbo].[Audits] ([AuditID], [ScorecardID], [ADate], [Status], [UserID]) VALUES (CAST(8 AS Numeric(5, 0)), CAST(5 AS Numeric(4, 0)), CAST(N'2021-04-07T10:26:50.290' AS DateTime), CAST(1 AS Numeric(1, 0)), CAST(2 AS Numeric(4, 0)))
GO
INSERT [dbo].[Audits] ([AuditID], [ScorecardID], [ADate], [Status], [UserID]) VALUES (CAST(9 AS Numeric(5, 0)), CAST(5 AS Numeric(4, 0)), CAST(N'2021-04-07T10:34:25.910' AS DateTime), CAST(1 AS Numeric(1, 0)), CAST(2 AS Numeric(4, 0)))
GO
INSERT [dbo].[Audits] ([AuditID], [ScorecardID], [ADate], [Status], [UserID]) VALUES (CAST(10 AS Numeric(5, 0)), CAST(5 AS Numeric(4, 0)), CAST(N'2021-04-07T10:37:32.127' AS DateTime), CAST(1 AS Numeric(1, 0)), CAST(2 AS Numeric(4, 0)))
GO
INSERT [dbo].[Audits] ([AuditID], [ScorecardID], [ADate], [Status], [UserID]) VALUES (CAST(11 AS Numeric(5, 0)), CAST(5 AS Numeric(4, 0)), CAST(N'2021-04-07T11:07:37.393' AS DateTime), CAST(1 AS Numeric(1, 0)), CAST(2 AS Numeric(4, 0)))
GO
INSERT [dbo].[Audits] ([AuditID], [ScorecardID], [ADate], [Status], [UserID]) VALUES (CAST(12 AS Numeric(5, 0)), CAST(5 AS Numeric(4, 0)), CAST(N'2021-04-07T11:22:23.130' AS DateTime), CAST(1 AS Numeric(1, 0)), CAST(2 AS Numeric(4, 0)))
GO
INSERT [dbo].[Audits] ([AuditID], [ScorecardID], [ADate], [Status], [UserID]) VALUES (CAST(13 AS Numeric(5, 0)), CAST(5 AS Numeric(4, 0)), CAST(N'2021-04-07T11:29:30.500' AS DateTime), CAST(1 AS Numeric(1, 0)), CAST(2 AS Numeric(4, 0)))
GO
INSERT [dbo].[Audits] ([AuditID], [ScorecardID], [ADate], [Status], [UserID]) VALUES (CAST(14 AS Numeric(5, 0)), CAST(5 AS Numeric(4, 0)), CAST(N'2021-04-07T12:34:42.987' AS DateTime), CAST(1 AS Numeric(1, 0)), CAST(2 AS Numeric(4, 0)))
GO
INSERT [dbo].[Audits] ([AuditID], [ScorecardID], [ADate], [Status], [UserID]) VALUES (CAST(15 AS Numeric(5, 0)), CAST(5 AS Numeric(4, 0)), CAST(N'2021-04-07T13:31:08.657' AS DateTime), CAST(1 AS Numeric(1, 0)), CAST(3 AS Numeric(4, 0)))
GO
INSERT [dbo].[Audits] ([AuditID], [ScorecardID], [ADate], [Status], [UserID]) VALUES (CAST(16 AS Numeric(5, 0)), CAST(5 AS Numeric(4, 0)), CAST(N'2021-04-07T13:36:24.967' AS DateTime), CAST(1 AS Numeric(1, 0)), CAST(3 AS Numeric(4, 0)))
GO
INSERT [dbo].[Audits] ([AuditID], [ScorecardID], [ADate], [Status], [UserID]) VALUES (CAST(17 AS Numeric(5, 0)), CAST(5 AS Numeric(4, 0)), CAST(N'2021-04-07T13:38:40.480' AS DateTime), CAST(1 AS Numeric(1, 0)), CAST(3 AS Numeric(4, 0)))
GO
INSERT [dbo].[Audits] ([AuditID], [ScorecardID], [ADate], [Status], [UserID]) VALUES (CAST(18 AS Numeric(5, 0)), CAST(5 AS Numeric(4, 0)), CAST(N'2021-04-07T13:42:10.503' AS DateTime), CAST(1 AS Numeric(1, 0)), CAST(3 AS Numeric(4, 0)))
GO
INSERT [dbo].[Audits] ([AuditID], [ScorecardID], [ADate], [Status], [UserID]) VALUES (CAST(19 AS Numeric(5, 0)), CAST(5 AS Numeric(4, 0)), CAST(N'2021-04-07T13:44:17.463' AS DateTime), CAST(1 AS Numeric(1, 0)), CAST(3 AS Numeric(4, 0)))
GO
INSERT [dbo].[Audits] ([AuditID], [ScorecardID], [ADate], [Status], [UserID]) VALUES (CAST(20 AS Numeric(5, 0)), CAST(5 AS Numeric(4, 0)), CAST(N'2021-04-07T13:48:47.290' AS DateTime), CAST(1 AS Numeric(1, 0)), CAST(3 AS Numeric(4, 0)))
GO
INSERT [dbo].[Audits] ([AuditID], [ScorecardID], [ADate], [Status], [UserID]) VALUES (CAST(21 AS Numeric(5, 0)), CAST(5 AS Numeric(4, 0)), CAST(N'2021-04-07T14:01:22.763' AS DateTime), CAST(1 AS Numeric(1, 0)), CAST(3 AS Numeric(4, 0)))
GO
INSERT [dbo].[Audits] ([AuditID], [ScorecardID], [ADate], [Status], [UserID]) VALUES (CAST(22 AS Numeric(5, 0)), CAST(4 AS Numeric(4, 0)), CAST(N'2021-04-08T17:29:00.420' AS DateTime), CAST(1 AS Numeric(1, 0)), CAST(3 AS Numeric(4, 0)))
GO
INSERT [dbo].[Audits] ([AuditID], [ScorecardID], [ADate], [Status], [UserID]) VALUES (CAST(23 AS Numeric(5, 0)), CAST(4 AS Numeric(4, 0)), CAST(N'2021-04-08T18:02:07.937' AS DateTime), CAST(1 AS Numeric(1, 0)), CAST(3 AS Numeric(4, 0)))
GO
INSERT [dbo].[Audits] ([AuditID], [ScorecardID], [ADate], [Status], [UserID]) VALUES (CAST(24 AS Numeric(5, 0)), CAST(4 AS Numeric(4, 0)), CAST(N'2021-04-08T18:20:14.767' AS DateTime), CAST(1 AS Numeric(1, 0)), CAST(3 AS Numeric(4, 0)))
GO
INSERT [dbo].[Audits] ([AuditID], [ScorecardID], [ADate], [Status], [UserID]) VALUES (CAST(25 AS Numeric(5, 0)), CAST(4 AS Numeric(4, 0)), CAST(N'2021-04-08T18:26:22.127' AS DateTime), CAST(1 AS Numeric(1, 0)), CAST(2 AS Numeric(4, 0)))
GO
INSERT [dbo].[Audits] ([AuditID], [ScorecardID], [ADate], [Status], [UserID]) VALUES (CAST(26 AS Numeric(5, 0)), CAST(5 AS Numeric(4, 0)), CAST(N'2021-04-08T18:28:49.563' AS DateTime), CAST(1 AS Numeric(1, 0)), CAST(2 AS Numeric(4, 0)))
GO
INSERT [dbo].[Audits] ([AuditID], [ScorecardID], [ADate], [Status], [UserID]) VALUES (CAST(27 AS Numeric(5, 0)), CAST(4 AS Numeric(4, 0)), CAST(N'2021-04-08T18:35:43.353' AS DateTime), CAST(1 AS Numeric(1, 0)), CAST(3 AS Numeric(4, 0)))
GO
INSERT [dbo].[Audits] ([AuditID], [ScorecardID], [ADate], [Status], [UserID]) VALUES (CAST(28 AS Numeric(5, 0)), CAST(5 AS Numeric(4, 0)), CAST(N'2021-04-08T21:59:59.270' AS DateTime), CAST(1 AS Numeric(1, 0)), CAST(2 AS Numeric(4, 0)))
GO
INSERT [dbo].[Audits] ([AuditID], [ScorecardID], [ADate], [Status], [UserID]) VALUES (CAST(29 AS Numeric(5, 0)), CAST(6 AS Numeric(4, 0)), CAST(N'2021-04-08T22:28:15.053' AS DateTime), CAST(1 AS Numeric(1, 0)), CAST(2 AS Numeric(4, 0)))
GO
INSERT [dbo].[Audits] ([AuditID], [ScorecardID], [ADate], [Status], [UserID]) VALUES (CAST(30 AS Numeric(5, 0)), CAST(6 AS Numeric(4, 0)), CAST(N'2021-04-10T13:22:56.693' AS DateTime), CAST(1 AS Numeric(1, 0)), CAST(2 AS Numeric(4, 0)))
GO
INSERT [dbo].[Audits] ([AuditID], [ScorecardID], [ADate], [Status], [UserID]) VALUES (CAST(31 AS Numeric(5, 0)), CAST(6 AS Numeric(4, 0)), CAST(N'2021-04-10T15:27:44.280' AS DateTime), CAST(1 AS Numeric(1, 0)), CAST(2 AS Numeric(4, 0)))
GO
INSERT [dbo].[Audits] ([AuditID], [ScorecardID], [ADate], [Status], [UserID]) VALUES (CAST(32 AS Numeric(5, 0)), CAST(6 AS Numeric(4, 0)), CAST(N'2021-04-10T17:17:49.263' AS DateTime), CAST(1 AS Numeric(1, 0)), CAST(2 AS Numeric(4, 0)))
GO
INSERT [dbo].[Audits] ([AuditID], [ScorecardID], [ADate], [Status], [UserID]) VALUES (CAST(33 AS Numeric(5, 0)), CAST(5 AS Numeric(4, 0)), CAST(N'2021-04-10T17:48:18.763' AS DateTime), CAST(1 AS Numeric(1, 0)), CAST(2 AS Numeric(4, 0)))
GO
SET IDENTITY_INSERT [dbo].[CompanyMaster] ON 
GO
INSERT [dbo].[CompanyMaster] ([CompanyID], [CompanyName], [Address], [ContactNo], [url], [Status]) VALUES (CAST(1 AS Numeric(5, 0)), N'Relisun', N'Hyderabad', N'Admin', N'wwwkjscard.com', CAST(1 AS Numeric(1, 0)))
GO
INSERT [dbo].[CompanyMaster] ([CompanyID], [CompanyName], [Address], [ContactNo], [url], [Status]) VALUES (CAST(2 AS Numeric(5, 0)), N'Bocsh', N'Hyderabad', N'Admin', N'wwwkjscard2.com', CAST(1 AS Numeric(1, 0)))
GO
INSERT [dbo].[CompanyMaster] ([CompanyID], [CompanyName], [Address], [ContactNo], [url], [Status]) VALUES (CAST(3 AS Numeric(5, 0)), N'Partch', N'Hyderabad', N'Admin', NULL, CAST(1 AS Numeric(1, 0)))
GO
INSERT [dbo].[CompanyMaster] ([CompanyID], [CompanyName], [Address], [ContactNo], [url], [Status]) VALUES (CAST(4 AS Numeric(5, 0)), N'Dos and Donts', N'Hyderabad, 74', N'9040005', N'www.hydrpot.com', CAST(0 AS Numeric(1, 0)))
GO
INSERT [dbo].[CompanyMaster] ([CompanyID], [CompanyName], [Address], [ContactNo], [url], [Status]) VALUES (CAST(5 AS Numeric(5, 0)), N'Sample Company ', N'Hyderabad, 74', N'prototype', N'94000556', CAST(0 AS Numeric(1, 0)))
GO
SET IDENTITY_INSERT [dbo].[CompanyMaster] OFF
GO
SET IDENTITY_INSERT [dbo].[Countries] ON 
GO
INSERT [dbo].[Countries] ([Cint], [Country], [Code]) VALUES (246, N'India', N'IN')
GO
INSERT [dbo].[Countries] ([Cint], [Country], [Code]) VALUES (247, N'United States', N'US')
GO
INSERT [dbo].[Countries] ([Cint], [Country], [Code]) VALUES (248, N'England', N'UK')
GO
INSERT [dbo].[Countries] ([Cint], [Country], [Code]) VALUES (249, N'Canada', N'CA')
GO
SET IDENTITY_INSERT [dbo].[Countries] OFF
GO
SET IDENTITY_INSERT [dbo].[ParaMaster] ON 
GO
INSERT [dbo].[ParaMaster] ([ParamID], [ParamName], [ParamType], [IsDefault], [Status]) VALUES (CAST(1 AS Numeric(3, 0)), N'Agent', N'TextBox', 1, CAST(1 AS Numeric(1, 0)))
GO
INSERT [dbo].[ParaMaster] ([ParamID], [ParamName], [ParamType], [IsDefault], [Status]) VALUES (CAST(2 AS Numeric(3, 0)), N'Auditor', N'TextBox', 1, CAST(1 AS Numeric(1, 0)))
GO
INSERT [dbo].[ParaMaster] ([ParamID], [ParamName], [ParamType], [IsDefault], [Status]) VALUES (CAST(3 AS Numeric(3, 0)), N'Ticket ID', N'TextBox', 1, CAST(1 AS Numeric(1, 0)))
GO
INSERT [dbo].[ParaMaster] ([ParamID], [ParamName], [ParamType], [IsDefault], [Status]) VALUES (CAST(4 AS Numeric(3, 0)), N'Audit Date', N'Date', 1, CAST(1 AS Numeric(1, 0)))
GO
INSERT [dbo].[ParaMaster] ([ParamID], [ParamName], [ParamType], [IsDefault], [Status]) VALUES (CAST(5 AS Numeric(3, 0)), N'Ticket Date', N'Date', 1, CAST(1 AS Numeric(1, 0)))
GO
INSERT [dbo].[ParaMaster] ([ParamID], [ParamName], [ParamType], [IsDefault], [Status]) VALUES (CAST(27 AS Numeric(3, 0)), N'TEXTBOX', N'TextBox', 0, CAST(1 AS Numeric(1, 0)))
GO
INSERT [dbo].[ParaMaster] ([ParamID], [ParamName], [ParamType], [IsDefault], [Status]) VALUES (CAST(28 AS Numeric(3, 0)), N'DATE', N'Date', 0, CAST(1 AS Numeric(1, 0)))
GO
INSERT [dbo].[ParaMaster] ([ParamID], [ParamName], [ParamType], [IsDefault], [Status]) VALUES (CAST(29 AS Numeric(3, 0)), N'LIST', N'List', 0, CAST(1 AS Numeric(1, 0)))
GO
INSERT [dbo].[ParaMaster] ([ParamID], [ParamName], [ParamType], [IsDefault], [Status]) VALUES (CAST(31 AS Numeric(3, 0)), N'LIST-SCALING', N'SList', 0, CAST(1 AS Numeric(1, 0)))
GO
INSERT [dbo].[ParaMaster] ([ParamID], [ParamName], [ParamType], [IsDefault], [Status]) VALUES (CAST(32 AS Numeric(3, 0)), N'Customer Name', N'TextBox', 1, CAST(1 AS Numeric(1, 0)))
GO
INSERT [dbo].[ParaMaster] ([ParamID], [ParamName], [ParamType], [IsDefault], [Status]) VALUES (CAST(33 AS Numeric(3, 0)), N'Rating', N'TextBox', 1, CAST(1 AS Numeric(1, 0)))
GO
INSERT [dbo].[ParaMaster] ([ParamID], [ParamName], [ParamType], [IsDefault], [Status]) VALUES (CAST(34 AS Numeric(3, 0)), N'AuditScore', N'TextBox', 1, CAST(1 AS Numeric(1, 0)))
GO
SET IDENTITY_INSERT [dbo].[ParaMaster] OFF
GO
INSERT [dbo].[RoleMaster] ([RoleID], [RoleName]) VALUES (CAST(1 AS Numeric(2, 0)), N'Admin')
GO
INSERT [dbo].[RoleMaster] ([RoleID], [RoleName]) VALUES (CAST(2 AS Numeric(2, 0)), N'Auditor')
GO
INSERT [dbo].[RoleMaster] ([RoleID], [RoleName]) VALUES (CAST(3 AS Numeric(2, 0)), N'QA')
GO
INSERT [dbo].[RoleMaster] ([RoleID], [RoleName]) VALUES (CAST(4 AS Numeric(2, 0)), N'Auditee')
GO
INSERT [dbo].[RoleMaster] ([RoleID], [RoleName]) VALUES (CAST(5 AS Numeric(2, 0)), N'Support')
GO
INSERT [dbo].[RoleMaster] ([RoleID], [RoleName]) VALUES (CAST(6 AS Numeric(2, 0)), N'CAdmin')
GO
INSERT [dbo].[RoleMaster] ([RoleID], [RoleName]) VALUES (CAST(7 AS Numeric(2, 0)), N'Team Lead')
GO
INSERT [dbo].[RoleMaster] ([RoleID], [RoleName]) VALUES (CAST(8 AS Numeric(2, 0)), N'Agent')
GO
INSERT [dbo].[ScorecardMaster] ([ScorecardID], [ScorecardName], [Status], [CompanyID]) VALUES (CAST(2 AS Numeric(4, 0)), N'My Scorecard01', CAST(1 AS Numeric(1, 0)), CAST(2 AS Numeric(5, 0)))
GO
INSERT [dbo].[ScorecardMaster] ([ScorecardID], [ScorecardName], [Status], [CompanyID]) VALUES (CAST(3 AS Numeric(4, 0)), N'My Scorecard02', CAST(0 AS Numeric(1, 0)), CAST(2 AS Numeric(5, 0)))
GO
INSERT [dbo].[ScorecardMaster] ([ScorecardID], [ScorecardName], [Status], [CompanyID]) VALUES (CAST(4 AS Numeric(4, 0)), N'My Scorecard03', CAST(1 AS Numeric(1, 0)), CAST(2 AS Numeric(5, 0)))
GO
INSERT [dbo].[ScorecardMaster] ([ScorecardID], [ScorecardName], [Status], [CompanyID]) VALUES (CAST(5 AS Numeric(4, 0)), N'My Scorecard04', CAST(1 AS Numeric(1, 0)), CAST(2 AS Numeric(5, 0)))
GO
INSERT [dbo].[ScorecardMaster] ([ScorecardID], [ScorecardName], [Status], [CompanyID]) VALUES (CAST(6 AS Numeric(4, 0)), N'SampleCard007', CAST(1 AS Numeric(1, 0)), CAST(2 AS Numeric(5, 0)))
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(1 AS Numeric(5, 0)), CAST(6 AS Numeric(3, 0)), N'0', N'0')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(2 AS Numeric(5, 0)), CAST(9 AS Numeric(3, 0)), N'1', N'100')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(3 AS Numeric(5, 0)), CAST(9 AS Numeric(3, 0)), N'2', N'75.00')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(4 AS Numeric(5, 0)), CAST(9 AS Numeric(3, 0)), N'3', N'50.00')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(5 AS Numeric(5, 0)), CAST(9 AS Numeric(3, 0)), N'4', N'25.00')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(6 AS Numeric(5, 0)), CAST(9 AS Numeric(3, 0)), N'5', N'0')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(7 AS Numeric(5, 0)), CAST(10 AS Numeric(3, 0)), N'1', N'100')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(8 AS Numeric(5, 0)), CAST(10 AS Numeric(3, 0)), N'2', N'80.00')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(9 AS Numeric(5, 0)), CAST(10 AS Numeric(3, 0)), N'3', N'60.00')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(10 AS Numeric(5, 0)), CAST(10 AS Numeric(3, 0)), N'4', N'40.00')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(11 AS Numeric(5, 0)), CAST(10 AS Numeric(3, 0)), N'5', N'20.00')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(12 AS Numeric(5, 0)), CAST(10 AS Numeric(3, 0)), N'6', N'0')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(13 AS Numeric(5, 0)), CAST(11 AS Numeric(3, 0)), N'1', N'100')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(14 AS Numeric(5, 0)), CAST(11 AS Numeric(3, 0)), N'2', N'83.33')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(15 AS Numeric(5, 0)), CAST(11 AS Numeric(3, 0)), N'3', N'66.66')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(16 AS Numeric(5, 0)), CAST(11 AS Numeric(3, 0)), N'4', N'50.00')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(17 AS Numeric(5, 0)), CAST(11 AS Numeric(3, 0)), N'5', N'33.33')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(18 AS Numeric(5, 0)), CAST(11 AS Numeric(3, 0)), N'6', N'16.66')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(19 AS Numeric(5, 0)), CAST(11 AS Numeric(3, 0)), N'7', N'0')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(20 AS Numeric(5, 0)), CAST(12 AS Numeric(3, 0)), N'1', N'100')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(21 AS Numeric(5, 0)), CAST(12 AS Numeric(3, 0)), N'2', N'85.71')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(22 AS Numeric(5, 0)), CAST(12 AS Numeric(3, 0)), N'3', N'71.42')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(23 AS Numeric(5, 0)), CAST(12 AS Numeric(3, 0)), N'4', N'57.14')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(24 AS Numeric(5, 0)), CAST(12 AS Numeric(3, 0)), N'5', N'42.85')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(25 AS Numeric(5, 0)), CAST(12 AS Numeric(3, 0)), N'6', N'28.57')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(26 AS Numeric(5, 0)), CAST(12 AS Numeric(3, 0)), N'7', N'14.28')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(27 AS Numeric(5, 0)), CAST(12 AS Numeric(3, 0)), N'8', N'0')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(28 AS Numeric(5, 0)), CAST(35 AS Numeric(3, 0)), N'1', N'100')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(29 AS Numeric(5, 0)), CAST(35 AS Numeric(3, 0)), N'2', N'80.00')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(30 AS Numeric(5, 0)), CAST(35 AS Numeric(3, 0)), N'3', N'60.00')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(31 AS Numeric(5, 0)), CAST(35 AS Numeric(3, 0)), N'4', N'40.00')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(32 AS Numeric(5, 0)), CAST(35 AS Numeric(3, 0)), N'5', N'20.00')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(33 AS Numeric(5, 0)), CAST(35 AS Numeric(3, 0)), N'6', N'0')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(34 AS Numeric(5, 0)), CAST(36 AS Numeric(3, 0)), N'1', N'100')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(35 AS Numeric(5, 0)), CAST(36 AS Numeric(3, 0)), N'2', N'83.33')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(36 AS Numeric(5, 0)), CAST(36 AS Numeric(3, 0)), N'3', N'66.66')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(37 AS Numeric(5, 0)), CAST(36 AS Numeric(3, 0)), N'4', N'50.00')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(38 AS Numeric(5, 0)), CAST(36 AS Numeric(3, 0)), N'5', N'33.33')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(39 AS Numeric(5, 0)), CAST(36 AS Numeric(3, 0)), N'6', N'16.66')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(40 AS Numeric(5, 0)), CAST(36 AS Numeric(3, 0)), N'7', N'0')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(41 AS Numeric(5, 0)), CAST(37 AS Numeric(3, 0)), N'Met', N'100')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(42 AS Numeric(5, 0)), CAST(37 AS Numeric(3, 0)), N'Not Met', N'0')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(43 AS Numeric(5, 0)), CAST(38 AS Numeric(3, 0)), N'Met', N'100')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(44 AS Numeric(5, 0)), CAST(38 AS Numeric(3, 0)), N'Not Met', N'0')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(45 AS Numeric(5, 0)), CAST(39 AS Numeric(3, 0)), N'Met', N'100')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(46 AS Numeric(5, 0)), CAST(39 AS Numeric(3, 0)), N'Not Met', N'0')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(47 AS Numeric(5, 0)), CAST(40 AS Numeric(3, 0)), N'Met', N'100')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(48 AS Numeric(5, 0)), CAST(40 AS Numeric(3, 0)), N'Not Met', N'0')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(49 AS Numeric(5, 0)), CAST(41 AS Numeric(3, 0)), N'Met', N'100')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(50 AS Numeric(5, 0)), CAST(41 AS Numeric(3, 0)), N'Not Met', N'0')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(51 AS Numeric(5, 0)), CAST(42 AS Numeric(3, 0)), N'1', N'100')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(52 AS Numeric(5, 0)), CAST(42 AS Numeric(3, 0)), N'2', N'75.00')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(53 AS Numeric(5, 0)), CAST(42 AS Numeric(3, 0)), N'3', N'50.00')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(54 AS Numeric(5, 0)), CAST(42 AS Numeric(3, 0)), N'4', N'25.00')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(55 AS Numeric(5, 0)), CAST(42 AS Numeric(3, 0)), N'5', N'0')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(56 AS Numeric(5, 0)), CAST(43 AS Numeric(3, 0)), N'1', N'100')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(57 AS Numeric(5, 0)), CAST(43 AS Numeric(3, 0)), N'2', N'83.33')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(58 AS Numeric(5, 0)), CAST(43 AS Numeric(3, 0)), N'3', N'66.66')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(59 AS Numeric(5, 0)), CAST(43 AS Numeric(3, 0)), N'4', N'50.00')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(60 AS Numeric(5, 0)), CAST(43 AS Numeric(3, 0)), N'5', N'33.33')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(61 AS Numeric(5, 0)), CAST(43 AS Numeric(3, 0)), N'6', N'16.66')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(62 AS Numeric(5, 0)), CAST(43 AS Numeric(3, 0)), N'7', N'0')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(63 AS Numeric(5, 0)), CAST(53 AS Numeric(3, 0)), N'1', N'100')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(64 AS Numeric(5, 0)), CAST(53 AS Numeric(3, 0)), N'2', N'75.00')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(65 AS Numeric(5, 0)), CAST(53 AS Numeric(3, 0)), N'3', N'50.00')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(66 AS Numeric(5, 0)), CAST(53 AS Numeric(3, 0)), N'4', N'25.00')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(67 AS Numeric(5, 0)), CAST(53 AS Numeric(3, 0)), N'5', N'0')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(68 AS Numeric(5, 0)), CAST(54 AS Numeric(3, 0)), N'Met', N'100')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(69 AS Numeric(5, 0)), CAST(54 AS Numeric(3, 0)), N'Not Met', N'0')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(70 AS Numeric(5, 0)), CAST(55 AS Numeric(3, 0)), N'Met', N'100')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(71 AS Numeric(5, 0)), CAST(55 AS Numeric(3, 0)), N'Not Met', N'0')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(72 AS Numeric(5, 0)), CAST(56 AS Numeric(3, 0)), N'Met', N'100')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(73 AS Numeric(5, 0)), CAST(56 AS Numeric(3, 0)), N'Not Met', N'0')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(74 AS Numeric(5, 0)), CAST(57 AS Numeric(3, 0)), N'Met', N'100')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(75 AS Numeric(5, 0)), CAST(57 AS Numeric(3, 0)), N'Not Met', N'0')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(76 AS Numeric(5, 0)), CAST(58 AS Numeric(3, 0)), N'1', N'0')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(77 AS Numeric(5, 0)), CAST(58 AS Numeric(3, 0)), N'2', N'20.00')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(78 AS Numeric(5, 0)), CAST(58 AS Numeric(3, 0)), N'3', N'40.00')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(79 AS Numeric(5, 0)), CAST(58 AS Numeric(3, 0)), N'4', N'60.00')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(80 AS Numeric(5, 0)), CAST(58 AS Numeric(3, 0)), N'5', N'80.00')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(81 AS Numeric(5, 0)), CAST(58 AS Numeric(3, 0)), N'6', N'100')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(82 AS Numeric(5, 0)), CAST(59 AS Numeric(3, 0)), N'1', N'0')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(83 AS Numeric(5, 0)), CAST(59 AS Numeric(3, 0)), N'2', N'25.00')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(84 AS Numeric(5, 0)), CAST(59 AS Numeric(3, 0)), N'3', N'50.00')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(85 AS Numeric(5, 0)), CAST(59 AS Numeric(3, 0)), N'4', N'75.00')
GO
INSERT [dbo].[scQLov] ([scQLOVID], [scQuestionID], [scQuestionValues], [scWeightage]) VALUES (CAST(86 AS Numeric(5, 0)), CAST(59 AS Numeric(3, 0)), N'5', N'100')
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(2 AS Numeric(3, 0)), CAST(1 AS Numeric(3, 0)), N'Agent', CAST(1 AS Numeric(2, 0)), CAST(2 AS Numeric(2, 0)), CAST(0 AS Numeric(2, 0)), 1, 0, CAST(2 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(3 AS Numeric(3, 0)), CAST(2 AS Numeric(3, 0)), N'Auditor', CAST(2 AS Numeric(2, 0)), CAST(2 AS Numeric(2, 0)), CAST(0 AS Numeric(2, 0)), 1, 0, CAST(2 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(4 AS Numeric(3, 0)), CAST(3 AS Numeric(3, 0)), N'Ticket ID', CAST(3 AS Numeric(2, 0)), CAST(2 AS Numeric(2, 0)), CAST(0 AS Numeric(2, 0)), 1, 0, CAST(2 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(5 AS Numeric(3, 0)), CAST(4 AS Numeric(3, 0)), N'Audit Date', CAST(4 AS Numeric(2, 0)), CAST(2 AS Numeric(2, 0)), CAST(0 AS Numeric(2, 0)), 1, 0, CAST(2 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(6 AS Numeric(3, 0)), CAST(5 AS Numeric(3, 0)), N'Ticket Date', CAST(5 AS Numeric(2, 0)), CAST(2 AS Numeric(2, 0)), CAST(0 AS Numeric(2, 0)), 1, 0, CAST(2 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(7 AS Numeric(3, 0)), CAST(33 AS Numeric(3, 0)), N'Rating', CAST(6 AS Numeric(2, 0)), CAST(2 AS Numeric(2, 0)), CAST(0 AS Numeric(2, 0)), 1, 0, CAST(2 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(8 AS Numeric(3, 0)), CAST(32 AS Numeric(3, 0)), N'Customer Name', CAST(7 AS Numeric(2, 0)), CAST(2 AS Numeric(2, 0)), CAST(0 AS Numeric(2, 0)), 1, 0, CAST(2 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(9 AS Numeric(3, 0)), CAST(31 AS Numeric(3, 0)), N'Quality', CAST(1 AS Numeric(2, 0)), CAST(3 AS Numeric(2, 0)), CAST(50 AS Numeric(2, 0)), 1, 1, CAST(2 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(10 AS Numeric(3, 0)), CAST(31 AS Numeric(3, 0)), N'Procedure aherence', CAST(2 AS Numeric(2, 0)), CAST(3 AS Numeric(2, 0)), CAST(50 AS Numeric(2, 0)), 1, 1, CAST(2 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(11 AS Numeric(3, 0)), CAST(31 AS Numeric(3, 0)), N'Check Point', CAST(1 AS Numeric(2, 0)), CAST(4 AS Numeric(2, 0)), CAST(50 AS Numeric(2, 0)), 1, 1, CAST(2 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(12 AS Numeric(3, 0)), CAST(31 AS Numeric(3, 0)), N'Review List', CAST(2 AS Numeric(2, 0)), CAST(4 AS Numeric(2, 0)), CAST(50 AS Numeric(2, 0)), 1, 1, CAST(2 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(13 AS Numeric(3, 0)), CAST(1 AS Numeric(3, 0)), N'Agent', CAST(1 AS Numeric(2, 0)), CAST(5 AS Numeric(2, 0)), CAST(0 AS Numeric(2, 0)), 1, 0, CAST(3 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(14 AS Numeric(3, 0)), CAST(2 AS Numeric(3, 0)), N'Auditor', CAST(2 AS Numeric(2, 0)), CAST(5 AS Numeric(2, 0)), CAST(0 AS Numeric(2, 0)), 1, 0, CAST(3 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(15 AS Numeric(3, 0)), CAST(3 AS Numeric(3, 0)), N'Ticket ID', CAST(3 AS Numeric(2, 0)), CAST(5 AS Numeric(2, 0)), CAST(0 AS Numeric(2, 0)), 1, 0, CAST(3 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(16 AS Numeric(3, 0)), CAST(4 AS Numeric(3, 0)), N'Audit Date', CAST(4 AS Numeric(2, 0)), CAST(5 AS Numeric(2, 0)), CAST(0 AS Numeric(2, 0)), 1, 0, CAST(3 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(17 AS Numeric(3, 0)), CAST(5 AS Numeric(3, 0)), N'Ticket Date', CAST(5 AS Numeric(2, 0)), CAST(5 AS Numeric(2, 0)), CAST(0 AS Numeric(2, 0)), 1, 0, CAST(3 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(18 AS Numeric(3, 0)), CAST(33 AS Numeric(3, 0)), N'Rating', CAST(6 AS Numeric(2, 0)), CAST(5 AS Numeric(2, 0)), CAST(0 AS Numeric(2, 0)), 1, 0, CAST(3 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(19 AS Numeric(3, 0)), CAST(32 AS Numeric(3, 0)), N'Customer Name', CAST(7 AS Numeric(2, 0)), CAST(5 AS Numeric(2, 0)), CAST(0 AS Numeric(2, 0)), 1, 0, CAST(3 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(20 AS Numeric(3, 0)), CAST(1 AS Numeric(3, 0)), N'Agent', CAST(1 AS Numeric(2, 0)), CAST(6 AS Numeric(2, 0)), CAST(0 AS Numeric(2, 0)), 1, 0, CAST(4 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(21 AS Numeric(3, 0)), CAST(2 AS Numeric(3, 0)), N'Auditor', CAST(2 AS Numeric(2, 0)), CAST(6 AS Numeric(2, 0)), CAST(0 AS Numeric(2, 0)), 1, 0, CAST(4 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(22 AS Numeric(3, 0)), CAST(3 AS Numeric(3, 0)), N'Ticket ID', CAST(3 AS Numeric(2, 0)), CAST(6 AS Numeric(2, 0)), CAST(0 AS Numeric(2, 0)), 1, 0, CAST(4 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(23 AS Numeric(3, 0)), CAST(4 AS Numeric(3, 0)), N'Audit Date', CAST(4 AS Numeric(2, 0)), CAST(6 AS Numeric(2, 0)), CAST(0 AS Numeric(2, 0)), 1, 0, CAST(4 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(24 AS Numeric(3, 0)), CAST(5 AS Numeric(3, 0)), N'Ticket Date', CAST(5 AS Numeric(2, 0)), CAST(6 AS Numeric(2, 0)), CAST(0 AS Numeric(2, 0)), 1, 0, CAST(4 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(25 AS Numeric(3, 0)), CAST(33 AS Numeric(3, 0)), N'Rating', CAST(6 AS Numeric(2, 0)), CAST(6 AS Numeric(2, 0)), CAST(0 AS Numeric(2, 0)), 1, 0, CAST(4 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(26 AS Numeric(3, 0)), CAST(32 AS Numeric(3, 0)), N'Customer Name', CAST(7 AS Numeric(2, 0)), CAST(6 AS Numeric(2, 0)), CAST(0 AS Numeric(2, 0)), 1, 0, CAST(4 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(27 AS Numeric(3, 0)), CAST(1 AS Numeric(3, 0)), N'Agent', CAST(1 AS Numeric(2, 0)), CAST(7 AS Numeric(2, 0)), CAST(0 AS Numeric(2, 0)), 1, 0, CAST(5 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(28 AS Numeric(3, 0)), CAST(2 AS Numeric(3, 0)), N'Auditor', CAST(2 AS Numeric(2, 0)), CAST(7 AS Numeric(2, 0)), CAST(0 AS Numeric(2, 0)), 1, 0, CAST(5 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(29 AS Numeric(3, 0)), CAST(3 AS Numeric(3, 0)), N'Ticket ID', CAST(3 AS Numeric(2, 0)), CAST(7 AS Numeric(2, 0)), CAST(0 AS Numeric(2, 0)), 1, 0, CAST(5 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(30 AS Numeric(3, 0)), CAST(4 AS Numeric(3, 0)), N'Audit Date', CAST(4 AS Numeric(2, 0)), CAST(7 AS Numeric(2, 0)), CAST(0 AS Numeric(2, 0)), 1, 0, CAST(5 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(31 AS Numeric(3, 0)), CAST(5 AS Numeric(3, 0)), N'Ticket Date', CAST(5 AS Numeric(2, 0)), CAST(7 AS Numeric(2, 0)), CAST(0 AS Numeric(2, 0)), 1, 0, CAST(5 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(32 AS Numeric(3, 0)), CAST(33 AS Numeric(3, 0)), N'Rating', CAST(6 AS Numeric(2, 0)), CAST(7 AS Numeric(2, 0)), CAST(0 AS Numeric(2, 0)), 1, 0, CAST(5 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(33 AS Numeric(3, 0)), CAST(32 AS Numeric(3, 0)), N'Customer Name', CAST(7 AS Numeric(2, 0)), CAST(7 AS Numeric(2, 0)), CAST(0 AS Numeric(2, 0)), 1, 0, CAST(5 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(34 AS Numeric(3, 0)), CAST(34 AS Numeric(3, 0)), N'Audit Score', CAST(8 AS Numeric(2, 0)), CAST(7 AS Numeric(2, 0)), CAST(0 AS Numeric(2, 0)), 1, 0, CAST(5 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(35 AS Numeric(3, 0)), CAST(31 AS Numeric(3, 0)), N'Quality', CAST(1 AS Numeric(2, 0)), CAST(8 AS Numeric(2, 0)), CAST(50 AS Numeric(2, 0)), 1, 1, CAST(5 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(36 AS Numeric(3, 0)), CAST(31 AS Numeric(3, 0)), N'Standards', CAST(2 AS Numeric(2, 0)), CAST(8 AS Numeric(2, 0)), CAST(50 AS Numeric(2, 0)), 1, 1, CAST(5 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(37 AS Numeric(3, 0)), CAST(29 AS Numeric(3, 0)), N'SLA', CAST(1 AS Numeric(2, 0)), CAST(9 AS Numeric(2, 0)), CAST(50 AS Numeric(2, 0)), 1, 1, CAST(5 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(38 AS Numeric(3, 0)), CAST(29 AS Numeric(3, 0)), N'Timelines', CAST(2 AS Numeric(2, 0)), CAST(9 AS Numeric(2, 0)), CAST(50 AS Numeric(2, 0)), 1, 1, CAST(5 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(39 AS Numeric(3, 0)), CAST(29 AS Numeric(3, 0)), N'Standards', CAST(1 AS Numeric(2, 0)), CAST(10 AS Numeric(2, 0)), CAST(45 AS Numeric(2, 0)), 1, 1, CAST(4 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(40 AS Numeric(3, 0)), CAST(29 AS Numeric(3, 0)), N'Reviews', CAST(2 AS Numeric(2, 0)), CAST(10 AS Numeric(2, 0)), CAST(45 AS Numeric(2, 0)), 1, 1, CAST(4 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(41 AS Numeric(3, 0)), CAST(29 AS Numeric(3, 0)), N'SLA', CAST(3 AS Numeric(2, 0)), CAST(10 AS Numeric(2, 0)), CAST(10 AS Numeric(2, 0)), 1, 1, CAST(4 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(42 AS Numeric(3, 0)), CAST(31 AS Numeric(3, 0)), N'Factor', CAST(1 AS Numeric(2, 0)), CAST(11 AS Numeric(2, 0)), CAST(60 AS Numeric(2, 0)), 1, 1, CAST(4 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(43 AS Numeric(3, 0)), CAST(31 AS Numeric(3, 0)), N'Review Standards', CAST(2 AS Numeric(2, 0)), CAST(11 AS Numeric(2, 0)), CAST(40 AS Numeric(2, 0)), 1, 1, CAST(4 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(44 AS Numeric(3, 0)), CAST(34 AS Numeric(3, 0)), N'Audit Score', CAST(8 AS Numeric(2, 0)), CAST(6 AS Numeric(2, 0)), CAST(0 AS Numeric(2, 0)), 0, 0, CAST(4 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(45 AS Numeric(3, 0)), CAST(1 AS Numeric(3, 0)), N'Agent', CAST(1 AS Numeric(2, 0)), CAST(12 AS Numeric(2, 0)), CAST(0 AS Numeric(2, 0)), 1, 0, CAST(6 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(46 AS Numeric(3, 0)), CAST(2 AS Numeric(3, 0)), N'Auditor', CAST(2 AS Numeric(2, 0)), CAST(12 AS Numeric(2, 0)), CAST(0 AS Numeric(2, 0)), 1, 0, CAST(6 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(47 AS Numeric(3, 0)), CAST(3 AS Numeric(3, 0)), N'Ticket ID', CAST(3 AS Numeric(2, 0)), CAST(12 AS Numeric(2, 0)), CAST(0 AS Numeric(2, 0)), 1, 0, CAST(6 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(48 AS Numeric(3, 0)), CAST(4 AS Numeric(3, 0)), N'Audit Date', CAST(4 AS Numeric(2, 0)), CAST(12 AS Numeric(2, 0)), CAST(0 AS Numeric(2, 0)), 1, 0, CAST(6 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(49 AS Numeric(3, 0)), CAST(5 AS Numeric(3, 0)), N'Ticket Date', CAST(5 AS Numeric(2, 0)), CAST(12 AS Numeric(2, 0)), CAST(0 AS Numeric(2, 0)), 1, 0, CAST(6 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(50 AS Numeric(3, 0)), CAST(33 AS Numeric(3, 0)), N'Rating', CAST(6 AS Numeric(2, 0)), CAST(12 AS Numeric(2, 0)), CAST(0 AS Numeric(2, 0)), 1, 0, CAST(6 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(51 AS Numeric(3, 0)), CAST(32 AS Numeric(3, 0)), N'Customer Name', CAST(7 AS Numeric(2, 0)), CAST(12 AS Numeric(2, 0)), CAST(0 AS Numeric(2, 0)), 1, 0, CAST(6 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(52 AS Numeric(3, 0)), CAST(34 AS Numeric(3, 0)), N'Audit Score', CAST(8 AS Numeric(2, 0)), CAST(12 AS Numeric(2, 0)), CAST(0 AS Numeric(2, 0)), 1, 0, CAST(6 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(53 AS Numeric(3, 0)), CAST(31 AS Numeric(3, 0)), N'Quality', CAST(1 AS Numeric(2, 0)), CAST(13 AS Numeric(2, 0)), CAST(60 AS Numeric(2, 0)), 1, 1, CAST(6 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(54 AS Numeric(3, 0)), CAST(29 AS Numeric(3, 0)), N'SLA', CAST(2 AS Numeric(2, 0)), CAST(13 AS Numeric(2, 0)), CAST(39 AS Numeric(2, 0)), 1, 1, CAST(6 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(55 AS Numeric(3, 0)), CAST(29 AS Numeric(3, 0)), N'Factor', CAST(3 AS Numeric(2, 0)), CAST(13 AS Numeric(2, 0)), CAST(1 AS Numeric(2, 0)), 1, 0, CAST(6 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(56 AS Numeric(3, 0)), CAST(29 AS Numeric(3, 0)), N'Process', CAST(1 AS Numeric(2, 0)), CAST(14 AS Numeric(2, 0)), CAST(50 AS Numeric(2, 0)), 1, 1, CAST(6 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(57 AS Numeric(3, 0)), CAST(29 AS Numeric(3, 0)), N'Standards', CAST(2 AS Numeric(2, 0)), CAST(14 AS Numeric(2, 0)), CAST(50 AS Numeric(2, 0)), 1, 1, CAST(6 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(58 AS Numeric(3, 0)), CAST(31 AS Numeric(3, 0)), N'Reverse Factor', CAST(1 AS Numeric(2, 0)), CAST(15 AS Numeric(2, 0)), CAST(50 AS Numeric(2, 0)), 1, 1, CAST(3 AS Numeric(4, 0)))
GO
INSERT [dbo].[scQuestions] ([scQuestionID], [ParamID], [ParamTitle], [Seq], [scSectionID], [QWght], [isMandatory], [IsCommentReq], [ScorecardID]) VALUES (CAST(59 AS Numeric(3, 0)), CAST(31 AS Numeric(3, 0)), N'Reverse Factor04', CAST(2 AS Numeric(2, 0)), CAST(15 AS Numeric(2, 0)), CAST(50 AS Numeric(2, 0)), 1, 1, CAST(3 AS Numeric(4, 0)))
GO
INSERT [dbo].[scSections] ([scSectionID], [SectionName], [SectionWght], [IsNewPage], [ScorecardID], [Seq]) VALUES (CAST(2 AS Numeric(2, 0)), N'General', CAST(0 AS Numeric(3, 0)), 0, CAST(2 AS Numeric(4, 0)), NULL)
GO
INSERT [dbo].[scSections] ([scSectionID], [SectionName], [SectionWght], [IsNewPage], [ScorecardID], [Seq]) VALUES (CAST(3 AS Numeric(2, 0)), N'Process', CAST(50 AS Numeric(3, 0)), 0, CAST(2 AS Numeric(4, 0)), NULL)
GO
INSERT [dbo].[scSections] ([scSectionID], [SectionName], [SectionWght], [IsNewPage], [ScorecardID], [Seq]) VALUES (CAST(4 AS Numeric(2, 0)), N'Feedback', CAST(50 AS Numeric(3, 0)), 0, CAST(2 AS Numeric(4, 0)), NULL)
GO
INSERT [dbo].[scSections] ([scSectionID], [SectionName], [SectionWght], [IsNewPage], [ScorecardID], [Seq]) VALUES (CAST(5 AS Numeric(2, 0)), N'General', CAST(0 AS Numeric(3, 0)), 0, CAST(3 AS Numeric(4, 0)), NULL)
GO
INSERT [dbo].[scSections] ([scSectionID], [SectionName], [SectionWght], [IsNewPage], [ScorecardID], [Seq]) VALUES (CAST(6 AS Numeric(2, 0)), N'General', CAST(0 AS Numeric(3, 0)), 0, CAST(4 AS Numeric(4, 0)), NULL)
GO
INSERT [dbo].[scSections] ([scSectionID], [SectionName], [SectionWght], [IsNewPage], [ScorecardID], [Seq]) VALUES (CAST(7 AS Numeric(2, 0)), N'General', CAST(0 AS Numeric(3, 0)), 0, CAST(5 AS Numeric(4, 0)), NULL)
GO
INSERT [dbo].[scSections] ([scSectionID], [SectionName], [SectionWght], [IsNewPage], [ScorecardID], [Seq]) VALUES (CAST(8 AS Numeric(2, 0)), N'Process', CAST(50 AS Numeric(3, 0)), 0, CAST(5 AS Numeric(4, 0)), NULL)
GO
INSERT [dbo].[scSections] ([scSectionID], [SectionName], [SectionWght], [IsNewPage], [ScorecardID], [Seq]) VALUES (CAST(9 AS Numeric(2, 0)), N'Feedback', CAST(50 AS Numeric(3, 0)), 0, CAST(5 AS Numeric(4, 0)), NULL)
GO
INSERT [dbo].[scSections] ([scSectionID], [SectionName], [SectionWght], [IsNewPage], [ScorecardID], [Seq]) VALUES (CAST(10 AS Numeric(2, 0)), N'Quality', CAST(60 AS Numeric(3, 0)), 0, CAST(4 AS Numeric(4, 0)), NULL)
GO
INSERT [dbo].[scSections] ([scSectionID], [SectionName], [SectionWght], [IsNewPage], [ScorecardID], [Seq]) VALUES (CAST(11 AS Numeric(2, 0)), N'Process', CAST(40 AS Numeric(3, 0)), 0, CAST(4 AS Numeric(4, 0)), NULL)
GO
INSERT [dbo].[scSections] ([scSectionID], [SectionName], [SectionWght], [IsNewPage], [ScorecardID], [Seq]) VALUES (CAST(12 AS Numeric(2, 0)), N'General', CAST(0 AS Numeric(3, 0)), 0, CAST(6 AS Numeric(4, 0)), NULL)
GO
INSERT [dbo].[scSections] ([scSectionID], [SectionName], [SectionWght], [IsNewPage], [ScorecardID], [Seq]) VALUES (CAST(13 AS Numeric(2, 0)), N'Section1', CAST(75 AS Numeric(3, 0)), 0, CAST(6 AS Numeric(4, 0)), NULL)
GO
INSERT [dbo].[scSections] ([scSectionID], [SectionName], [SectionWght], [IsNewPage], [ScorecardID], [Seq]) VALUES (CAST(14 AS Numeric(2, 0)), N'Section2', CAST(25 AS Numeric(3, 0)), 0, CAST(6 AS Numeric(4, 0)), NULL)
GO
INSERT [dbo].[scSections] ([scSectionID], [SectionName], [SectionWght], [IsNewPage], [ScorecardID], [Seq]) VALUES (CAST(15 AS Numeric(2, 0)), N'Section 001', CAST(40 AS Numeric(3, 0)), 0, CAST(3 AS Numeric(4, 0)), NULL)
GO
SET IDENTITY_INSERT [dbo].[Teams] ON 
GO
INSERT [dbo].[Teams] ([TeamID], [TeamName], [TeamLeadID]) VALUES (CAST(1 AS Numeric(5, 0)), N'Morning Shift', CAST(7 AS Numeric(4, 0)))
GO
INSERT [dbo].[Teams] ([TeamID], [TeamName], [TeamLeadID]) VALUES (CAST(2 AS Numeric(5, 0)), N'Night Shift', CAST(8 AS Numeric(4, 0)))
GO
INSERT [dbo].[Teams] ([TeamID], [TeamName], [TeamLeadID]) VALUES (CAST(3 AS Numeric(5, 0)), N'General  S', CAST(109 AS Numeric(4, 0)))
GO
INSERT [dbo].[Teams] ([TeamID], [TeamName], [TeamLeadID]) VALUES (CAST(4 AS Numeric(5, 0)), N'General  Shift', CAST(212 AS Numeric(4, 0)))
GO
INSERT [dbo].[Teams] ([TeamID], [TeamName], [TeamLeadID]) VALUES (CAST(103 AS Numeric(5, 0)), N'Special Shift', CAST(109 AS Numeric(4, 0)))
GO
INSERT [dbo].[Teams] ([TeamID], [TeamName], [TeamLeadID]) VALUES (CAST(104 AS Numeric(5, 0)), N'QShift', CAST(109 AS Numeric(4, 0)))
GO
INSERT [dbo].[Teams] ([TeamID], [TeamName], [TeamLeadID]) VALUES (CAST(105 AS Numeric(5, 0)), N'IISTeam', CAST(7 AS Numeric(4, 0)))
GO
SET IDENTITY_INSERT [dbo].[Teams] OFF
GO
SET IDENTITY_INSERT [dbo].[UserMaster] ON 
GO
INSERT [dbo].[UserMaster] ([UserID], [CompanyID], [RoleID], [UserName], [PCode], [DisplayName], [Status], [MgrID], [Email], [DOB], [Country], [Gender], [StartDate], [EndDate]) VALUES (CAST(1 AS Numeric(4, 0)), CAST(1 AS Numeric(5, 0)), CAST(1 AS Numeric(2, 0)), N'Admin', N'admin@123', N'Adminstrator', CAST(0 AS Numeric(1, 0)), NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[UserMaster] ([UserID], [CompanyID], [RoleID], [UserName], [PCode], [DisplayName], [Status], [MgrID], [Email], [DOB], [Country], [Gender], [StartDate], [EndDate]) VALUES (CAST(2 AS Numeric(4, 0)), CAST(2 AS Numeric(5, 0)), CAST(6 AS Numeric(2, 0)), N'BAdmin', N'admin@123', N'Bosch Admin', CAST(0 AS Numeric(1, 0)), NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[UserMaster] ([UserID], [CompanyID], [RoleID], [UserName], [PCode], [DisplayName], [Status], [MgrID], [Email], [DOB], [Country], [Gender], [StartDate], [EndDate]) VALUES (CAST(3 AS Numeric(4, 0)), CAST(2 AS Numeric(5, 0)), CAST(4 AS Numeric(2, 0)), N'Suresh', N'admin@123', N'Suresh BH', CAST(0 AS Numeric(1, 0)), CAST(7 AS Numeric(4, 0)), NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[UserMaster] ([UserID], [CompanyID], [RoleID], [UserName], [PCode], [DisplayName], [Status], [MgrID], [Email], [DOB], [Country], [Gender], [StartDate], [EndDate]) VALUES (CAST(4 AS Numeric(4, 0)), CAST(2 AS Numeric(5, 0)), CAST(4 AS Numeric(2, 0)), N'Ramesh', N'admin@123', N'Ramesh AK', CAST(0 AS Numeric(1, 0)), CAST(8 AS Numeric(4, 0)), NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[UserMaster] ([UserID], [CompanyID], [RoleID], [UserName], [PCode], [DisplayName], [Status], [MgrID], [Email], [DOB], [Country], [Gender], [StartDate], [EndDate]) VALUES (CAST(5 AS Numeric(4, 0)), CAST(3 AS Numeric(5, 0)), CAST(4 AS Numeric(2, 0)), N'Karthik', N'admin@123', N'Karthik D', CAST(0 AS Numeric(1, 0)), NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[UserMaster] ([UserID], [CompanyID], [RoleID], [UserName], [PCode], [DisplayName], [Status], [MgrID], [Email], [DOB], [Country], [Gender], [StartDate], [EndDate]) VALUES (CAST(6 AS Numeric(4, 0)), CAST(3 AS Numeric(5, 0)), CAST(6 AS Numeric(2, 0)), N'KAdmin', N'admin@123', N'Parch Admin', CAST(0 AS Numeric(1, 0)), NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[UserMaster] ([UserID], [CompanyID], [RoleID], [UserName], [PCode], [DisplayName], [Status], [MgrID], [Email], [DOB], [Country], [Gender], [StartDate], [EndDate]) VALUES (CAST(7 AS Numeric(4, 0)), CAST(2 AS Numeric(5, 0)), CAST(7 AS Numeric(2, 0)), N'Lead1', N'admin@123', N'Morning Lead', CAST(0 AS Numeric(1, 0)), NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[UserMaster] ([UserID], [CompanyID], [RoleID], [UserName], [PCode], [DisplayName], [Status], [MgrID], [Email], [DOB], [Country], [Gender], [StartDate], [EndDate]) VALUES (CAST(8 AS Numeric(4, 0)), CAST(2 AS Numeric(5, 0)), CAST(7 AS Numeric(2, 0)), N'Lead2', N'admin@123', N'Night Lead', CAST(0 AS Numeric(1, 0)), NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[UserMaster] ([UserID], [CompanyID], [RoleID], [UserName], [PCode], [DisplayName], [Status], [MgrID], [Email], [DOB], [Country], [Gender], [StartDate], [EndDate]) VALUES (CAST(16 AS Numeric(4, 0)), CAST(1 AS Numeric(5, 0)), CAST(1 AS Numeric(2, 0)), N'TestUser00', N'terst@123r', N'Test User 0001', CAST(0 AS Numeric(1, 0)), CAST(0 AS Numeric(4, 0)), N'test@g1134.com', NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[UserMaster] ([UserID], [CompanyID], [RoleID], [UserName], [PCode], [DisplayName], [Status], [MgrID], [Email], [DOB], [Country], [Gender], [StartDate], [EndDate]) VALUES (CAST(109 AS Numeric(4, 0)), CAST(2 AS Numeric(5, 0)), CAST(7 AS Numeric(2, 0)), N'TeamLead3', N'admin@123', N'Team Lead 3', CAST(0 AS Numeric(1, 0)), CAST(0 AS Numeric(4, 0)), N'teamlead@tsf.com', NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[UserMaster] ([UserID], [CompanyID], [RoleID], [UserName], [PCode], [DisplayName], [Status], [MgrID], [Email], [DOB], [Country], [Gender], [StartDate], [EndDate]) VALUES (CAST(209 AS Numeric(4, 0)), CAST(3 AS Numeric(5, 0)), CAST(1 AS Numeric(2, 0)), N'TestAd', N'zadmin@123', N'test ad ', CAST(0 AS Numeric(1, 0)), CAST(0 AS Numeric(4, 0)), N'testad@testdf.com', NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[UserMaster] ([UserID], [CompanyID], [RoleID], [UserName], [PCode], [DisplayName], [Status], [MgrID], [Email], [DOB], [Country], [Gender], [StartDate], [EndDate]) VALUES (CAST(210 AS Numeric(4, 0)), CAST(4 AS Numeric(5, 0)), CAST(6 AS Numeric(2, 0)), N'testcms', N'admin@123', N'Test Admin Do', CAST(0 AS Numeric(1, 0)), CAST(0 AS Numeric(4, 0)), N'testcms@tsdf.com', NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[UserMaster] ([UserID], [CompanyID], [RoleID], [UserName], [PCode], [DisplayName], [Status], [MgrID], [Email], [DOB], [Country], [Gender], [StartDate], [EndDate]) VALUES (CAST(211 AS Numeric(4, 0)), CAST(4 AS Numeric(5, 0)), CAST(6 AS Numeric(2, 0)), N'ddadmin', N'admin@123', N'DODONTAD', CAST(0 AS Numeric(1, 0)), CAST(0 AS Numeric(4, 0)), N'testdd@tsfd.com', NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[UserMaster] ([UserID], [CompanyID], [RoleID], [UserName], [PCode], [DisplayName], [Status], [MgrID], [Email], [DOB], [Country], [Gender], [StartDate], [EndDate]) VALUES (CAST(212 AS Numeric(4, 0)), CAST(4 AS Numeric(5, 0)), CAST(7 AS Numeric(2, 0)), N'ddtlead', N'admin@123', N'DoDOLead', CAST(0 AS Numeric(1, 0)), CAST(0 AS Numeric(4, 0)), N'ddtlead.fg.com', NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[UserMaster] ([UserID], [CompanyID], [RoleID], [UserName], [PCode], [DisplayName], [Status], [MgrID], [Email], [DOB], [Country], [Gender], [StartDate], [EndDate]) VALUES (CAST(213 AS Numeric(4, 0)), CAST(4 AS Numeric(5, 0)), CAST(4 AS Numeric(2, 0)), N'ddadutiee', N'admin@123', N'DD team MEM', CAST(0 AS Numeric(1, 0)), CAST(212 AS Numeric(4, 0)), N'ddteamm@fg.com', NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[UserMaster] ([UserID], [CompanyID], [RoleID], [UserName], [PCode], [DisplayName], [Status], [MgrID], [Email], [DOB], [Country], [Gender], [StartDate], [EndDate]) VALUES (CAST(214 AS Numeric(4, 0)), CAST(2 AS Numeric(5, 0)), CAST(8 AS Numeric(2, 0)), N'agent1', N'admin@123', N'Agent 1', CAST(0 AS Numeric(1, 0)), CAST(0 AS Numeric(4, 0)), N'agent1@fg.com', NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[UserMaster] ([UserID], [CompanyID], [RoleID], [UserName], [PCode], [DisplayName], [Status], [MgrID], [Email], [DOB], [Country], [Gender], [StartDate], [EndDate]) VALUES (CAST(215 AS Numeric(4, 0)), CAST(2 AS Numeric(5, 0)), CAST(8 AS Numeric(2, 0)), N'agent2', N'admin@123', N'Agent 2', CAST(0 AS Numeric(1, 0)), CAST(0 AS Numeric(4, 0)), N'agent12@fg.com', NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[UserMaster] ([UserID], [CompanyID], [RoleID], [UserName], [PCode], [DisplayName], [Status], [MgrID], [Email], [DOB], [Country], [Gender], [StartDate], [EndDate]) VALUES (CAST(313 AS Numeric(4, 0)), CAST(2 AS Numeric(5, 0)), CAST(8 AS Numeric(2, 0)), N'TestAppUse', N'admin@123', N'Test Agent', CAST(0 AS Numeric(1, 0)), CAST(0 AS Numeric(4, 0)), N'ttest@hgh.com', NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[UserMaster] ([UserID], [CompanyID], [RoleID], [UserName], [PCode], [DisplayName], [Status], [MgrID], [Email], [DOB], [Country], [Gender], [StartDate], [EndDate]) VALUES (CAST(314 AS Numeric(4, 0)), CAST(4 AS Numeric(5, 0)), CAST(5 AS Numeric(2, 0)), N'4aprtestus', N'admin@123', N'Test Apr User', CAST(0 AS Numeric(1, 0)), CAST(0 AS Numeric(4, 0)), N'4aptest@jgj.com', NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[UserMaster] ([UserID], [CompanyID], [RoleID], [UserName], [PCode], [DisplayName], [Status], [MgrID], [Email], [DOB], [Country], [Gender], [StartDate], [EndDate]) VALUES (CAST(317 AS Numeric(4, 0)), CAST(2 AS Numeric(5, 0)), CAST(5 AS Numeric(2, 0)), N'04AprtestB', N'admin@123', N'Test Apr001 User', CAST(0 AS Numeric(1, 0)), CAST(109 AS Numeric(4, 0)), N'4aptest@jghj.com', NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[UserMaster] ([UserID], [CompanyID], [RoleID], [UserName], [PCode], [DisplayName], [Status], [MgrID], [Email], [DOB], [Country], [Gender], [StartDate], [EndDate]) VALUES (CAST(318 AS Numeric(4, 0)), CAST(2 AS Numeric(5, 0)), CAST(3 AS Numeric(2, 0)), N'TestCompUS', N'admin@123', N'TestCompleteUser', CAST(0 AS Numeric(1, 0)), CAST(0 AS Numeric(4, 0)), N'testcomp@ths.com', CAST(N'1975-06-11' AS Date), N'India', N'Male', CAST(N'2021-04-06' AS Date), CAST(N'2021-08-31' AS Date))
GO
INSERT [dbo].[UserMaster] ([UserID], [CompanyID], [RoleID], [UserName], [PCode], [DisplayName], [Status], [MgrID], [Email], [DOB], [Country], [Gender], [StartDate], [EndDate]) VALUES (CAST(319 AS Numeric(4, 0)), CAST(2 AS Numeric(5, 0)), CAST(3 AS Numeric(2, 0)), N'CtryUserTe', N'admin@123', N'C User Name', CAST(0 AS Numeric(1, 0)), CAST(0 AS Numeric(4, 0)), N'country@gnala.com', CAST(N'1999-10-12' AS Date), N'India', N'Male', CAST(N'2021-04-08' AS Date), CAST(N'2022-03-31' AS Date))
GO
INSERT [dbo].[UserMaster] ([UserID], [CompanyID], [RoleID], [UserName], [PCode], [DisplayName], [Status], [MgrID], [Email], [DOB], [Country], [Gender], [StartDate], [EndDate]) VALUES (CAST(320 AS Numeric(4, 0)), CAST(2 AS Numeric(5, 0)), CAST(3 AS Numeric(2, 0)), N'MyFrgetstU', N'admin@123', N'Foroget', CAST(0 AS Numeric(1, 0)), CAST(0 AS Numeric(4, 0)), N'frgy@jkg.com', CAST(N'1975-06-09' AS Date), N'India', N'Male', CAST(N'2021-04-11' AS Date), CAST(N'2022-06-30' AS Date))
GO
SET IDENTITY_INSERT [dbo].[UserMaster] OFF
GO
ALTER TABLE [dbo].[Audits] ADD  CONSTRAINT [DF_Audits_Status]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [dbo].[CompanyMaster] ADD  CONSTRAINT [DF_CompanyMaster_Status]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [dbo].[ParaMaster] ADD  CONSTRAINT [DF_ParaMaster_Status]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [dbo].[ScorecardMaster] ADD  CONSTRAINT [DF_ScorecardMastet_Status]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [dbo].[scQuestions] ADD  CONSTRAINT [DF_scQuestions_isMandatory]  DEFAULT ((0)) FOR [isMandatory]
GO
ALTER TABLE [dbo].[scQuestions] ADD  CONSTRAINT [DF_scQuestions_IsCommentReq]  DEFAULT ((0)) FOR [IsCommentReq]
GO
ALTER TABLE [dbo].[scSections] ADD  CONSTRAINT [DF_scSections_IsNewPage]  DEFAULT ((0)) FOR [IsNewPage]
GO
ALTER TABLE [dbo].[AuditReponses]  WITH CHECK ADD  CONSTRAINT [FK_AuditReponses_Audits] FOREIGN KEY([AuditID])
REFERENCES [dbo].[Audits] ([AuditID])
GO
ALTER TABLE [dbo].[AuditReponses] CHECK CONSTRAINT [FK_AuditReponses_Audits]
GO
ALTER TABLE [dbo].[AuditReponses]  WITH CHECK ADD  CONSTRAINT [FK_AuditReponses_scQuestions] FOREIGN KEY([scQuestionID])
REFERENCES [dbo].[scQuestions] ([scQuestionID])
GO
ALTER TABLE [dbo].[AuditReponses] CHECK CONSTRAINT [FK_AuditReponses_scQuestions]
GO
ALTER TABLE [dbo].[Audits]  WITH CHECK ADD  CONSTRAINT [FK_Audits_ScorecardMaster] FOREIGN KEY([ScorecardID])
REFERENCES [dbo].[ScorecardMaster] ([ScorecardID])
GO
ALTER TABLE [dbo].[Audits] CHECK CONSTRAINT [FK_Audits_ScorecardMaster]
GO
ALTER TABLE [dbo].[ScorecardMaster]  WITH CHECK ADD  CONSTRAINT [FK_ScorecardMaster_CompanyMaster] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[CompanyMaster] ([CompanyID])
GO
ALTER TABLE [dbo].[ScorecardMaster] CHECK CONSTRAINT [FK_ScorecardMaster_CompanyMaster]
GO
ALTER TABLE [dbo].[scQLov]  WITH CHECK ADD  CONSTRAINT [FK_scQLov_scQuestions] FOREIGN KEY([scQuestionID])
REFERENCES [dbo].[scQuestions] ([scQuestionID])
GO
ALTER TABLE [dbo].[scQLov] CHECK CONSTRAINT [FK_scQLov_scQuestions]
GO
ALTER TABLE [dbo].[scQuestions]  WITH CHECK ADD  CONSTRAINT [FK_scQuestions_ParaMaster] FOREIGN KEY([ParamID])
REFERENCES [dbo].[ParaMaster] ([ParamID])
GO
ALTER TABLE [dbo].[scQuestions] CHECK CONSTRAINT [FK_scQuestions_ParaMaster]
GO
ALTER TABLE [dbo].[scQuestions]  WITH CHECK ADD  CONSTRAINT [FK_scQuestions_scSections] FOREIGN KEY([scSectionID])
REFERENCES [dbo].[scSections] ([scSectionID])
GO
ALTER TABLE [dbo].[scQuestions] CHECK CONSTRAINT [FK_scQuestions_scSections]
GO
ALTER TABLE [dbo].[scSections]  WITH CHECK ADD  CONSTRAINT [FK_scSections_ScorecardMaster] FOREIGN KEY([ScorecardID])
REFERENCES [dbo].[ScorecardMaster] ([ScorecardID])
GO
ALTER TABLE [dbo].[scSections] CHECK CONSTRAINT [FK_scSections_ScorecardMaster]
GO
ALTER TABLE [dbo].[UserLog]  WITH CHECK ADD  CONSTRAINT [FK_UserLog_UserMaster] FOREIGN KEY([UserId])
REFERENCES [dbo].[UserMaster] ([UserID])
GO
ALTER TABLE [dbo].[UserLog] CHECK CONSTRAINT [FK_UserLog_UserMaster]
GO
ALTER TABLE [dbo].[UserMaster]  WITH CHECK ADD  CONSTRAINT [FK_UserMaster_CompanyMaster] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[CompanyMaster] ([CompanyID])
GO
ALTER TABLE [dbo].[UserMaster] CHECK CONSTRAINT [FK_UserMaster_CompanyMaster]
GO
ALTER TABLE [dbo].[UserMaster]  WITH CHECK ADD  CONSTRAINT [FK_UserMaster_RoleMaster] FOREIGN KEY([RoleID])
REFERENCES [dbo].[RoleMaster] ([RoleID])
GO
ALTER TABLE [dbo].[UserMaster] CHECK CONSTRAINT [FK_UserMaster_RoleMaster]
GO
/****** Object:  StoredProcedure [dbo].[AddNewDepartment]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[AddNewDepartment]  
(  
   @DeptName varchar (50), 
   @Address varchar (50),
   @url varchar (10),
   @ContactNo varchar (10)
)  
as  
begin  
   Insert into CompanyMaster values(@DeptName,@Address,@url, @ContactNo,0 )  
End  
GO
/****** Object:  StoredProcedure [dbo].[AddNewTeam]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[AddNewTeam]  
(  
   @TeamName varchar (20),
   @TeamLeadId int
)  
as  
begin  


INSERT INTO [dbo].[Teams]
           ([TeamName]
           ,[TeamLeadID])
     VALUES
           (@TeamName
           ,@TeamLeadId)
  

End  
GO
/****** Object:  StoredProcedure [dbo].[AddNewUser]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[AddNewUser]  
(  
   @UserName varchar (10),
   @DisplayName varchar (25),
   @Passward varchar (10),
   @CompanyId int,
   @RoleId int,
   @Email varchar (56),
   @MgrId int,
   @Dob date,
   @Country nvarchar(20),
   @Gender nvarchar(10),
   @StartDate date,
   @EndDate date

)  
as  
begin  
   
   INSERT INTO [dbo].[UserMaster]
           ([CompanyID]
           ,[RoleID]
           ,[UserName]
           ,[PCode]
           ,[DisplayName]
           ,[Status]
           ,[MgrID]
           ,[Email],
		   [DOB],
		   [Country],
		   [Gender],
		   [StartDate],
		   [EndDate])
     VALUES
           (@CompanyId
           ,@RoleId
           ,@UserName
           ,@Passward
           ,@DisplayName
           ,0
           ,@MgrID
		   ,@Email,
		   @Dob,
		   @Country,
		   @Gender,
		   @StartDate,
		   @EndDate)


End  
GO
/****** Object:  StoredProcedure [dbo].[DeleteDepartmentById]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create procedure [dbo].[DeleteDepartmentById]  
(  
   @DeptId int  
)  
as  
begin  
   Delete from CompanyMaster where CompanyId=@DeptId  
End  


/****** Object:  StoredProcedure [dbo].[GetDepartment]    Script Date: 3/26/2021 11:15:13 AM ******/
SET ANSI_NULLS ON
GO
/****** Object:  StoredProcedure [dbo].[GetAuditList]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[GetAuditList]
(@CompanyID int,
@ScoreCardId int)
AS
BEGIN
select AuditID,ADate,ad.ScorecardID,um.DisplayName as UserID from Audits ad
inner join ScorecardMaster sc on ad.ScorecardID=sc.ScorecardID
inner join UserMaster um on ad.UserID=um.UserID
where sc.CompanyID = @CompanyID and sc.ScorecardID=@ScorecardID
END
GO
/****** Object:  StoredProcedure [dbo].[GetAuditSectionList]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[GetAuditSectionList]
(@AuditId int)
AS
BEGIN
select AuditId,SecSectionId as SectionId,SecScore,sec.SectionName from 
AuditResponseCalculations ars
right outer join scSections sec on ars.SecSectionId=sec.scSectionID
where AuditId=@AuditId
union
select ad.AuditID,sec.scSectionID as SectionId,0 as SecScore,sec.SectionName from 
scSections sec,Audits ad
where sec.ScorecardID = ad.ScorecardID and ad.AuditID=@AuditId and sec.SectionName='General'

END
GO
/****** Object:  StoredProcedure [dbo].[GetAuditSectionQstList]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[GetAuditSectionQstList]
(@SectionId int,
@AuditId as int)
AS
BEGIN
select distinct ar.scQuestionID,sq.ParamTitle,sq.ParamID, 
ar.Response,isnull(ar.Score,'') as Score,ar.comments from AuditReponses ar
join scQuestions sq on sq.scQuestionID= ar.scQuestionID and sq.scSectionID=@SectionId
and ar.AuditID=@AuditId
END
GO
/****** Object:  StoredProcedure [dbo].[GetCompaniesList]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[GetCompaniesList]
AS
BEGIN

select * from [dbo].[CompanyMaster];
END
GO
/****** Object:  StoredProcedure [dbo].[GetCompScoreCardList]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[GetCompScoreCardList]
(@CompanyId int)
AS
BEGIN
 
select scm.ScorecardID,scm.ScorecardName,
Case 
	When scm.Status = 0 then 'Draft'
	When scm.Status =1 then 'Active'
	Else 'DeActive'
End as Status,
(select count(AuditId) from Audits a where a.ScorecardID=scm.ScorecardID) as Cnt from  
ScorecardMaster as scm where scm.CompanyID = @CompanyId 

 
END 
GO
/****** Object:  StoredProcedure [dbo].[GetDepartment]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[GetDepartment]    
as    
begin    
   select CompanyID ,CompanyName ,Address,url,contactno  from CompanyMaster  
End   
GO
/****** Object:  StoredProcedure [dbo].[Getdepartments]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[Getdepartments]    
as    
begin    
--select 0 as RoleId,'Select Role' as RoleName from Roles 
--union
 select CompanyID ,CompanyName ,Address,url,contactno  from CompanyMaster  
End   
GO
/****** Object:  StoredProcedure [dbo].[GetLeads]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[GetLeads]    
as    
begin    
--select 0 as RoleId,'Select Role' as RoleName from Roles 
--union
   select UserId,DisplayName,CompanyID from UserMaster where RoleID = 7  
End   
GO
/****** Object:  StoredProcedure [dbo].[GetParasmData]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[GetParasmData]
AS
BEGIN

select ParamID ,ParamName,ParamType from ParaMaster(nolock) where isdefault=0
END
GO
/****** Object:  StoredProcedure [dbo].[GetRoles]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[GetRoles]    
as    
begin    
--select 0 as RoleId,'Select Role' as RoleName from Roles 
--union
   select RoleId,RoleName from RoleMaster  
End   
GO
/****** Object:  StoredProcedure [dbo].[GetScoreCardList]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[GetScoreCardList]
(@CompanyID int,
@userId int,
@status int)
AS
BEGIN


select distinct sm.scorecardname,sm.ScorecardID from ScorecardMaster as sm
left join audits as Au on au.ScorecardID=sm.ScorecardID 
where companyid=@CompanyID and sm.Status = @status
--except
--select sm.scorecardname,sm.ScorecardID from ScorecardMaster as sm
--left join audits as Au on au.ScorecardID=sm.ScorecardID 
--where Au.UserID=@userId



END
GO
/****** Object:  StoredProcedure [dbo].[GetScoreCards]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [dbo].[GetScoreCards]
(@CompanyID int
)
AS
BEGIN


select distinct sm.scorecardname,sm.ScorecardID from ScorecardMaster as sm
inner join audits as Au on au.ScorecardID=sm.ScorecardID 
where companyid=@CompanyID 

END
GO
/****** Object:  StoredProcedure [dbo].[GetSectionData]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[GetSectionData]
(
@scoreCardName Varchar(21),
@CompanyID int)
AS
Begin

 select SM.ScorecardID,SM.ScorecardName,SS.scSectionID,SS.SectionName,SS.SectionWght,SS.IsNewPage,SS.Seq from ScorecardMaster(nolock) SM
 Inner join scSections(nolock) SS on SM.ScorecardID=SS.ScorecardID
 where SM.ScorecardName=@scoreCardName and CompanyID = @CompanyID

END
GO
/****** Object:  StoredProcedure [dbo].[GetSectionNameWithScorecard]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[GetSectionNameWithScorecard]    
(    
@sectionName Varchar(21) ,  
@ScorecardName Varchar(21),
@CompanyID int)    
AS    
Begin    
declare @Sectionid int;  
declare @ScorecardID int ; 
select @ScorecardID=ScorecardID from ScorecardMaster(nolock)  where ScorecardName=@ScorecardName and CompanyID= @CompanyID

 select* from [dbo].[scSections] where SectionName = @sectionName and ScorecardID = @ScorecardID  
    
END 
GO
/****** Object:  StoredProcedure [dbo].[GetTeams]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[GetTeams]  

as  
begin  

select TM.TeamLeadID, TM.TeamName,UM.DisplayName,um.CompanyID from Teams TM,UserMaster UM
where  TM.TeamLeadID=um.UserID 
End  
GO
/****** Object:  StoredProcedure [dbo].[GetUserAuditResponseDetails]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[GetUserAuditResponseDetails]     
(     
@UserID int ,   
@ScorecardID int)     
AS     
Begin     
select ss.SectionName,sq.ParamTitle,ar.Response,ar.Score,ar.comments,ar.AuditResponeID,* from [dbo].[Audits] as au
inner join [dbo].[AuditResponseCalculations] as arc on au.AuditID= arc.AuditID
inner join [dbo].[AuditReponses] as ar on au.AuditID = ar.AuditID
inner join [dbo].[scQuestions] as sq on ar.scQuestionID = sq.scQuestionID
inner join [dbo].[scSections] as ss on sq.scSectionID = ss.scSectionID
where au.UserID = @UserID  and au.ScorecardID = @ScorecardID order by au.AuditID 
     
END 
GO
/****** Object:  StoredProcedure [dbo].[GetUserRespondedScoreCardList]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[GetUserRespondedScoreCardList]
(@userId int)
AS
BEGIN
 
select distinct scm.ScorecardID,scm.ScorecardName from [dbo].[Audits] as au  
left join ScorecardMaster as scm on au.ScorecardID = scm.ScorecardID
where au.userid = @userId 
 
END 
GO
/****** Object:  StoredProcedure [dbo].[GetUsers]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[GetUsers]  
(@compid int=null)
as    
begin    
   select U.[UserId]
      ,U.[UserName]
      ,U.PCode as Password,
	  U.CompanyId,
	  U.RoleId,
      D.CompanyName
      ,R.RoleName
      ,U.[Email] from UserMaster U
	  Inner join CompanyMaster D on D.CompanyId=U.CompanyId
	  Inner join RoleMaster R on R.RoleId=U.RoleId 
End   
GO
/****** Object:  StoredProcedure [dbo].[InsertIntoParams]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[InsertIntoParams]
(
@ScoreCardId int ,
@SectionId Int ,
@paramId int,
@paramName Varchar(300),
@ParamWeight int,
@isCurrentReq bit,
@isMandatory bit,
@paramlist Varchar(500) =Null
)
AS
BEGIN
DECLARE @Questionid AS TABLE(QuestionId INT);
DECLARE @xmlStr XML
DECLARE @QSECWght as int;
DECLARE @SecNM as nvarchar(25);


SELECT @SecNM=SectionName FROM scSections WHERE scSectionID=@SectionId
SELECT @QSECWght=ISNULL(SUM(QWght),0) FROM scQuestions WHERE scSectionID=@SectionId AND ScorecardID=@ScoreCardId
IF @QSECWght=null
SELECT @QSECWght=0

IF @ParamWeight + @QSECWght <= 100 or @SecNM = 'General'
BEGIN
BEGIN TRANSACTION
print 'In Condition match'
		--SELECT @xmlStr = Cast( replace(@PrenoteIds,'','''''') as )
		--Select @xmlStr
		SELECT @xmlStr = Cast('<A>'+ replace(@paramlist,',','</A><A>')+ '</A>' As XML)
		SELECT t.value('.', 'Varchar(12)') as Id into #temp
		FROM @xmlStr.nodes('/A') As x(t)
		Declare @topQuestionId int;
		select @topQuestionId=1
		select top 1 @topQuestionId=scQuestionID from scQuestions(nolock) Order by scQuestionID desc
		declare @Qseq int ;
		select @Qseq=0;
print 'sequenc value' 
print @Qseq
		select top 1 @Qseq =ISNULL(seq,0)from scQuestions(nolock) where scSectionID =@SectionId order by seq desc
print 'before question insert' 
print @Qseq
		Insert into [dbo].[scQuestions](scQuestionID,ParamID,ParamTitle,Seq,scSectionID,QWght,isMandatory,IsCommentReq,ScorecardID) --Output Inserted.scQuestionID into @Questionid
		Values(@topQuestionId+1,@paramId, @paramName,Isnull(@Qseq,0)+1,@SectionId,@ParamWeight,@isMandatory,@isCurrentReq,@ScoreCardId)
print 'inserted to questions'	
	Declare @topQuestionId1 int;
		select top 1 @topQuestionId1=scQuestionID from scQuestions(nolock) Order by scQuestionID desc
		--declare @QLovId int ;
		--select top 1 @QLovId=scQLOVID from scQLov(nolock) order by scQLOVID desc
		Declare @Id Varchar(12)
		While (Select Count(*) From #temp) > 0
		BEGIN
		Select Top 1 @Id = Id From #Temp
 
		-- Values(@QLovId+1,(select QuestionId from @Questionid),'')
 
        print 'lov values inside'
		Insert into [dbo].[scQLov](scQLOVID,scQuestionID,scQuestionValues,scWeightage)
		select (select top 1 scQLOVID+1 from scQLov(nolock) order by scQLOVID desc) ,@topQuestionId1,(Select value from(
		SELECT Row_number() over (order by(select 0)) as Rn,* FROM STRING_SPLIT(@Id, '|' )
		) b where rn=1),(Select value from(
		SELECT Row_number() over (order by(select 0)) as Rn,* FROM STRING_SPLIT(@Id , '|' )
		) b where rn=2)
		Delete #Temp Where Id = @Id
		END
 COMMIT TRANSACTION
END
ELSE
BEGIN
print 'failed condition matched'
	select top 1 @topQuestionId=scQuestionID from scQuestions(nolock) Order by scQuestionID desc
	Insert into [dbo].[scQuestions](scQuestionID,ParamID,ParamTitle,Seq,scSectionID,QWght,isMandatory,IsCommentReq,ScorecardID) --Output Inserted.scQuestionID into @Questionid
		Values(@topQuestionId,@paramId, @paramName,Isnull(@Qseq,0)+1,@SectionId,@ParamWeight,@isMandatory,@isCurrentReq,@ScoreCardId)


END 
 
 
 
END
GO
/****** Object:  StoredProcedure [dbo].[InsertIntoSections]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[InsertIntoSections]  
(  
@sectionName varchar(51),  
@SectionWght int,  
@ScorecardName varchar(21),
@CompanyID int
)  
AS  
BEGIN   
declare @Sectionid int;  
declare @ScorecardID int;  
declare @Seccnt int;
declare @SCSecsWght as int;
declare @beforesecscore int;
select @Sectionid=1
select @ScoreCardid=ScorecardID from ScorecardMaster(nolock)  where ScorecardName=@ScorecardName and CompanyID=@CompanyID 
select top 1 @Sectionid=scSectionID from scSections(nolock) Order by scSectionID desc   
select @beforesecscore=0;
IF (@sectionName != 'General')
	Begin
	select  @Seccnt=count(*) from scSections(nolock) where ScorecardID=@ScoreCardid
	select @beforesecscore=sum(Qwght) from scQuestions where scSectionID=(select  top 1 scSectionID from scSections where ScorecardID=@ScorecardID order by scSectionID desc)
	select @SCSecsWght=sum(SectionWght) from scSections where ScorecardID=@ScorecardID
	End
	
IF ( @SCSecsWght + @SectionWght <= 100 OR @sectionName = 'General')
Begin
	IF (@beforesecscore = 100 OR @sectionName = 'General' Or @Seccnt = 1) 
		BEGIN
		Insert into scSections(scSectionID,SectionName,SectionWght,IsNewPage,ScorecardID,Seq)  
		select @Sectionid+1 ,@sectionName,@SectionWght,0,@ScorecardID,(select top 1 seq from scSections(nolock) where ScorecardID=@ScorecardID order by seq desc )+1  
		END
	ELSE
		BEGIN
		Insert into scSections(scSectionID,SectionName,SectionWght,IsNewPage,ScorecardID,Seq)  
		select @Sectionid ,@sectionName,@SectionWght,0,@ScorecardID,(select top 1 seq from scSections(nolock) where ScorecardID=@ScorecardID order by seq desc )+1  
		END
End
Else
	BEGIN
	Insert into scSections(scSectionID,SectionName,SectionWght,IsNewPage,ScorecardID,Seq)  
	select @Sectionid ,@sectionName,@SectionWght,0,@ScorecardID,(select top 1 seq from scSections(nolock) where ScorecardID=@ScorecardID order by seq desc )+1  
	END

--select SCOPE_IDENTITY()  
  
END

GO
/****** Object:  StoredProcedure [dbo].[SaveDraftAuditDetails]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[SaveDraftAuditDetails]      
(@CompanyId int,
@ScorecardID int,
@Responce nvarchar(max),
@Comments nvarchar(max),
@QScore nvarchar(max)=null,
@Type nvarchar(50),
@UserId int,
@SectionIds nvarchar(max)
)      
AS      
BEGIN 
DECLARE @id int;
DECLARE @arid int;
DECLARE @auditID int;
DECLARE @auditscore decimal(5,2);
SET @id = 0;
SET @arid = 0
SELECT top(1) @id=AuditID FROM Audits ORDER BY AuditID DESC;
SELECT @id
INSERT INTO Audits ([AuditID],[ScorecardID],[ADate],[Status],[UserID]) Values(@id+1,@ScorecardID,getdate(),@Type,@UserId);
set @auditID=@id+1;

 

CREATE TABLE #temp (Target_Coulmn  nvarchar(max))
                ----Split with comma and Insert into #temp table
INSERT INTO  #temp SELECT CAST(Items AS  nvarchar(max)) FROM  dbo.Split(@Responce, ',') ;
--INSERT INTO  #temp SELECT value FROM  dbo.Split(@Responce, ',') ;
update #temp set Target_Coulmn = replace(replace(DBO.FN_REPLACE_FIRST(Target_Coulmn,'-','#'),'-',' '),'#','-')
where (LEN(Target_Coulmn) - LEN(REPLACE(Target_Coulmn, '-', ''))) > 2
--select * from #temp
 

 

INSERT INTO AuditReponses ([AuditID],[scQuestionID],[Response],[Score]) 
Select @auditID,REVERSE(PARSENAME(REPLACE(REVERSE(Target_Coulmn), '-', '.'), 1)),
REVERSE(PARSENAME(REPLACE(REVERSE(Target_Coulmn), '-', '.'), 2)),
REPLACE(REVERSE(PARSENAME(REPLACE(REVERSE(REPLACE(Target_Coulmn,'.','|')), '-', '.'), 3)),'|','.') FROM #temp;

--Select @auditID,REVERSE(PARSENAME(REPLACE(REVERSE(Target_Coulmn), '-', '.'), 1)),REVERSE(PARSENAME(REPLACE(REVERSE(Target_Coulmn), '-', '.'), 2)),REPLACE(REVERSE(PARSENAME(REPLACE(REVERSE(REPLACE(Target_Coulmn,'.','|')), '-', '.'), 3)),'|','.') FROM #temp;
 

CREATE TABLE #temp1 (Target_Coulmn  nvarchar(max))
                ----Split with comma and Insert into #temp table
INSERT INTO  #temp1 SELECT CAST(Items AS  nvarchar(max)) FROM  dbo.Split(@Comments, ',') ;
--INSERT INTO  #temp1 SELECT value1 FROM  dbo.Split(@Comments, ',') ;

 

CREATE TABLE #temp2 (Target_Coulmn1  nvarchar(max),Target_Coulmn2  nvarchar(max));
INSERT INTO  #temp2 SELECT REVERSE(PARSENAME(REPLACE(REVERSE(Target_Coulmn), '-', '.'), 1)),
REVERSE(PARSENAME(REPLACE(REVERSE(Target_Coulmn), '-', '.'), 2)) FROM  #temp1 ;

 

Merge AuditReponses as target
using #temp2  as source
on
target.AuditID=@auditID and target.scQuestionID=source.Target_Coulmn1
When matched 
Then
update 
set target.Comments=source.Target_Coulmn2
When not matched by Target Then
INSERT ([AuditID],[scQuestionID],[Comments]) Values(@auditID,Target_Coulmn1,Target_Coulmn2);
DROP TABLE #temp;
DROP TABLE #temp1;
DROP TABLE #temp2;

 

CREATE TABLE #temp3 (Target_Coulmn3  nvarchar(max))
                ----Split with comma and Insert into #temp table
INSERT INTO  #temp3 SELECT CAST(Items AS  nvarchar(max)) FROM  dbo.Split(@SectionIds, ',') ;

select * from #temp3
Select @auditID,REVERSE(PARSENAME(REPLACE(REVERSE(Target_Coulmn3), '-', '.'), 1)),
replace(REVERSE(PARSENAME(REPLACE(REVERSE(replace(Target_Coulmn3,'.','|')), '-', '.'), 2)),'|','.') FROM #temp3;;

INSERT INTO [dbo].[AuditResponseCalculations] ([AuditId],[SecSectionId],[SecScore]) 
Select @auditID,REVERSE(PARSENAME(REPLACE(REVERSE(Target_Coulmn3), '-', '.'), 1)),
replace(REVERSE(PARSENAME(REPLACE(REVERSE(replace(Target_Coulmn3,'.','|')), '-', '.'), 2)),'|','.') FROM #temp3;;

DROP TABLE #temp3;

select @auditscore = sum(CAST(SecScore AS decimal(5,2))) from [AuditResponseCalculations] where [AuditId]=@auditID

update AuditReponses set Score = @auditscore where AuditID=@auditID and
scQuestionID = (select scQuestionID from scQuestions where ParamID=34 and ScorecardID=@ScorecardID)

END  

 

GO
/****** Object:  StoredProcedure [dbo].[sp_GetAppUser]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GetAppUser] 
(
@CompanyId int)
AS          
  BEGIN          
            
   Select * from [dbo].[UserInfo] where CompanyID=@CompanyId
      
  END 
GO
/****** Object:  StoredProcedure [dbo].[sp_GetCountries]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GetCountries]          
AS          
  BEGIN          
            
   SELECT Country FROM [dbo].[Countries]
      
  END 
GO
/****** Object:  StoredProcedure [dbo].[sp_GetDaynamicdata]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[sp_GetDaynamicdata]  
(
@ScorecardName varchar(20)
)
AS          
  BEGIN
  SELECT * FROM [dbo].[ScorecardMaster] (nolock) scm 
   inner join scSections (nolock) ss on scm.ScorecardID=ss.ScorecardID
   inner join scQuestions (nolock) sq on sq.scSectionID=ss.scSectionID
   inner join scQLov (nolock)  sql1 on sql1.scQuestionID=sq.scQuestionID
   inner join ParaMaster (nolock) pm on pm.ParamID=sq.ParamID
   where scm.ScorecardName=@ScorecardName 
  END 
GO
/****** Object:  StoredProcedure [dbo].[sp_GetDriveforSolution]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[sp_GetDriveforSolution]          
AS          
  BEGIN          
           
   SELECT ParamTitle,ParamID,scSectionID FROM [dbo].[scQuestions] where scSectionID=4   
      
  END 

  --exec sp_GetDriveforSolution
GO
/****** Object:  StoredProcedure [dbo].[sp_GetResolution]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[sp_GetResolution]          
AS          
  BEGIN          
           
   SELECT ParamTitle,ParamID,scSectionID FROM [dbo].[scQuestions] where scSectionID=3     
      
  END 

   --exec sp_GetResolution
GO
/****** Object:  StoredProcedure [dbo].[sp_GetSoftSkills]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 Create PROCEDURE [dbo].[sp_GetSoftSkills]          
AS          
  BEGIN          
           
   SELECT ParamTitle,ParamID,scSectionID FROM [dbo].[scQuestions] where scSectionID=5    
      
  END 

   --exec sp_GetSoftSkills
GO
/****** Object:  StoredProcedure [dbo].[sp_GetUser]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[sp_GetUser] 
(
@UserName Varchar(10), @PCode Varchar(10))
AS          
  BEGIN          
            
   SELECT *  FROM [dbo].[UserInfo] where UserName =  @UserName and PCode=@PCode  
      
  END 


GO
/****** Object:  StoredProcedure [dbo].[sp_UpdateScorecard]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_UpdateScorecard]   
(
@ScoreCardNM nvarchar(25),
@CompanyId int)

AS          
  BEGIN          
  declare @scwghtcnt int;
  declare @ScoreCardID int;
  declare @totscwt int;
  declare @gensecid int;

  CREATE TABLE #ScWgt ( SecID INT, Wtg INT );

   select @ScoreCardID=ScorecardID from  ScorecardMaster where ScorecardName=@ScoreCardNM and CompanyID=@CompanyId
   select @gensecid= scSectionID from scSections where ScorecardID=@ScoreCardID and SectionName='General' 
  
  select @totscwt=isnull(sum(SectionWght),0) from scSections where ScorecardID=@ScoreCardID
   
   insert into #ScWgt
   select scSectionID, sum(QWght) from scQuestions where ScorecardID=@ScoreCardID and  scSectionID <> @gensecid
   group by scSectionID
  
   
   select @scwghtcnt=isnull(count(SecID),0) from #ScWgt where Wtg < 100

   if @scwghtcnt = 0 and @totscwt = 100
   update ScorecardMaster set Status=1 where ScorecardID=@ScoreCardID
   else
   update ScorecardMaster set Status=200 where ScorecardID='8577yu'
  
  drop table #ScWgt
  
  END 
GO
/****** Object:  StoredProcedure [dbo].[sp_UpdateScorecardStatus]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_UpdateScorecardStatus]   
(
@ScoreCardNM nvarchar(25),
@CompanyId int,
@status int)
AS          
  BEGIN   
  declare @Scid int;
  declare @AuditCnt int;
  select @AuditCnt=0;
 
  select @Scid=ScorecardID from  ScorecardMaster where ScorecardName=@ScoreCardNM and CompanyID=@CompanyId
   select @AuditCnt=count(*) from Audits where ScorecardID=@Scid and Status=0
   if @AuditCnt = 0 
	update ScorecardMaster set Status=@status where ScorecardID=@Scid
   else 
    update ScorecardMaster set Status='100' where ScorecardID=@Scid
  END
GO
/****** Object:  StoredProcedure [dbo].[UpdateDepartment]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[UpdateDepartment]  
(  
   @CompanyId int,  
   @CompanyName varchar (50),
   @Address varchar (250),
   @url varchar (50),
   @ContactNo varchar (10)
)  
as  
begin  
   Update CompanyMaster  
   set CompanyName=@CompanyName, 
   Address=@Address ,url= @url , ContactNo = @ContactNo
   where CompanyId=@CompanyId  
End  
GO
/****** Object:  StoredProcedure [dbo].[UpdateTeams]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UpdateTeams]  
(  
  @Teamid int,
  @TeamName varchar(20),
  @TeamLeadId int
)  
as  
begin  

UPDATE [dbo].[Teams]
   SET [TeamName] = @TeamName
      ,[TeamLeadID] = @TeamLeadId
 WHERE TeamId= @TeamId

End  
GO
/****** Object:  StoredProcedure [dbo].[Usp_DeleteintoParams]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [dbo].[Usp_DeleteintoParams]
(
@QuestionId Int
)
AS
BEGIN

delete from scQLov where scQuestionID =@QuestionId
delete from  scQuestions where scQuestionID =@QuestionId
END 
GO
/****** Object:  StoredProcedure [dbo].[Usp_DeleteIntoSectionData]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create  Procedure [dbo].[Usp_DeleteIntoSectionData]
(@sectionId int)
AS
BEGIN
  delete from  scQLov where scQuestionID in (select scQuestionID from  scQuestions where scSectionID=@SectionId)
  delete from  scQuestions where scSectionID=@SectionId
  delete  from  scSections where scSectionID=@SectionId

END
GO
/****** Object:  StoredProcedure [dbo].[usp_GetAgentUsers]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[usp_GetAgentUsers]  
(@compid int=null)
as    
begin    
   select U.[UserId],U.DisplayName,
         R.RoleName,U.CompanyID
       from UserMaster U
	  Inner join CompanyMaster D on D.CompanyId=U.CompanyId
	  Inner join RoleMaster R on R.RoleId=U.RoleId 
	  where U.RoleID != 2
End   
GO
/****** Object:  StoredProcedure [dbo].[USP_GetParamDataGrid]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[USP_GetParamDataGrid]
(@ScorecardName Varchar(50),@sectionname Varchar(50))
AS
BEGIN

declare @ScorecardID int;
select @ScorecardID=ScorecardID from ScorecardMaster(nolock)  where ScorecardName=@ScorecardName  

select ParamName,ParamTitle,QWght,isMandatory,IsCommentReq,scQuestionID,SS.ScorecardID,ss.scSectionID,SQS.ParamID
from [dbo].[scSections](nolock) SS
  Inner join [dbo].[scQuestions](nolock) SQS on SS.ScorecardID=SQS.ScorecardID and ss.scSectionID=SQS.scSectionID
  Inner join  [dbo].[ParaMaster] (nolock) PM on SQS.ParamID=PM.ParamID
  where SS.SectionName=@sectionname and ss.ScorecardID=@ScorecardID

END

--exec USP_GetParamDataGrid 'New Sample Card','Section 1'



GO
/****** Object:  StoredProcedure [dbo].[Usp_GetSectionQDetails]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[Usp_GetSectionQDetails]      
(@ScoreCardName Varchar(26),
@CompanyID int
)      
AS      
BEGIN      
      
select SM.ScorecardID ,SM.ScorecardName,SS.scSectionID,SS.SectionName,SS.SectionWght,SS.Seq as SectionSeq,SQ.ParamID,SQ.ParamTitle,SQ.Seq AS QSeq,SQ.QWght,    
SQ.isMandatory,SQ.IsCommentReq,SCL.scQLOVID,SCL.scQuestionValues,SCL.scWeightage,PM.IsDefault,SQ.scQuestionID,PM.ParamType    
 from [dbo].[ScorecardMaster](nolock) SM      
Inner Join scSections(nolock) SS on SM.ScorecardID=SS.ScorecardID      
Inner join scQuestions(nolock) SQ on SS.scSectionID= SQ.scSectionID and SS.ScorecardID=SQ.ScorecardID      
LEFT join scQLov(nolock) SCL on SQ.scQuestionID =SCL.scQuestionID and SCL.scQLOVID is not null      
Inner join [dbo].[ParaMaster](nolock) PM on SQ.ParamID= PM.ParamID      
where SM.ScorecardName=@ScoreCardName and SM.CompanyID = @CompanyID     

 


--select SM.ScorecardID,SM.ScorecardName,(select SS.scSectionID,SS.SectionName,SS.SectionWght,SS.Seq as SectionSeq
--,(select SQ.ParamID,SQ.ParamTitle,SQ.Seq AS QSeq,SQ.QWght,    
--SQ.isMandatory,SQ.IsCommentReq,SQ.scQuestionID,PM.ParamType,PM.IsDefault 
--,(select SCL.scQLOVID,SCL.scQuestionValues
--From  scQLov(nolock) SCL Where SQ.scQuestionID =SCL.scQuestionID and SCL.scQLOVID is not null   for json path) as Qvalues
--From  scQuestions(nolock) SQ
--Inner join [dbo].[ParaMaster](nolock) PM on SQ.ParamID= PM.ParamID WHERE SS.scSectionID= SQ.scSectionID and SS.ScorecardID=SM.ScorecardID   for json path) as Questions 
--From  scSections(nolock) SS where SM.ScorecardID=SS.ScorecardID for json path ) as SectionName
--from [dbo].[ScorecardMaster](nolock) SM where SM.ScorecardName=@ScoreCardName   

 

END  

 

-- exec Usp_GetSectionQDetails 'Sample Scorecard'
GO
/****** Object:  StoredProcedure [dbo].[usp_InsertIntoCompany]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[usp_InsertIntoCompany]
(@CompanyName Varchar(40),@Address Varchar(100), @ContactNo Varchar(10),@url Varchar(70))
AS
BEGIN

declare @Companyid int;


Select @Companyid=1 

print @Companyid

select top 1 @Companyid=CompanyID from CompanyMaster(nolock) Order by CompanyID desc 
Insert into CompanyMaster(CompanyID,CompanyName, Status, Address,ContactNo, url)
select @Companyid+1 ,@CompanyName,0,@Address,@ContactNo,@url

END 
GO
/****** Object:  StoredProcedure [dbo].[usp_InsertIntoScoreCardMaster]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_InsertIntoScoreCardMaster]
(@ScoreCardname Varchar(25),@CompanyID int)
AS
BEGIN

declare @ScoreCardid int;
declare @scardid int;
declare @Sectionid int;

Select @ScoreCardid=1 

print @ScoreCardid

select top 1 @ScoreCardid=ScorecardID from ScorecardMaster(nolock) Order by ScorecardID desc 
Insert into ScorecardMaster(ScorecardID,ScorecardName, Status, CompanyID)
select @ScoreCardid+1 ,@ScoreCardname,0,@CompanyID

EXEC dbo.InsertIntoSections  'General',0,@ScoreCardname,@CompanyID

print @ScoreCardid

select  @Sectionid=scSectionID,@scardid=ScorecardID from dbo.scSections(nolock) where SectionName='General' and ScorecardID=@ScoreCardid+1

Exec dbo.InsertIntoParams @scardid ,@Sectionid,1,'Agent',0,False,True
Exec dbo.InsertIntoParams @scardid,@Sectionid,2,'Auditor',0,False,True
Exec dbo.InsertIntoParams @scardid,@Sectionid,3,'Ticket ID',0,False,True
Exec dbo.InsertIntoParams @scardid,@Sectionid,4,'Audit Date',0,False,True
Exec dbo.InsertIntoParams @scardid,@Sectionid,5,'Ticket Date',0,False,True
Exec dbo.InsertIntoParams @scardid,@Sectionid,33,'Rating',0,False,True
Exec dbo.InsertIntoParams @scardid,@Sectionid,32,'Customer Name',0,False,True
Exec dbo.InsertIntoParams @scardid,@Sectionid,34,'Audit Score',0,False,True


END 
GO
/****** Object:  StoredProcedure [dbo].[usp_rpt_meanaverageReportbyScoreCardId]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Exec dbo.usp_meanaverageReportbyScoreCardId 2
CREATE procedure [dbo].[usp_rpt_meanaverageReportbyScoreCardId]
(
	 @ScorecardId Int
)

AS
BEGIN
--Drop table #AuditReportData

	IF OBJECT_ID('tempdb..#AuditReportData') IS NOT NULL
	Begin
	  DROP TABLE #AuditReportData
	END

	IF OBJECT_ID('tempdb..#AuditScore') IS NOT NULL
	Begin
	  DROP TABLE #AuditScore
	END

	IF OBJECT_ID('tempdb..#AuditReport') IS NOT NULL
	Begin
	  DROP TABLE #AuditReport
	END


	Create Table #AuditReportData (AuditID numeric, ADate Date, AuditStatus Nvarchar(255),UserName Nvarchar(255) , 
					ParamTitle Nvarchar(255), Response Nvarchar(255), TeamName Nvarchar(255),TeamLead Nvarchar(255))


	Insert into #AuditReportData
	Select Ad.AuditID, Ad.ADate, 
		Case Ad.Status 
			When 0 Then 'Rejected'
			When 1 Then 'Accepted'	
			When 2 Then 'Challenged'
			When 3 Then 'Cancelled'
			End
	, UM.DisplayName, SQ.ParamTitle, Ar.Response, tm.TeamName,  tmgr.UserName 
	from Audits Ad
	Inner Join AuditReponses Ar on Ad.AuditID = ar.AuditID
	Inner join scQuestions SQ on Ar.scQuestionID = SQ.scQuestionID
	Inner join UserMaster UM on Ad.UserID = UM.UserID
	Left Join Teams Tm on UM.MgrID  = TM.TeamLeadID
	Inner Join UserMaster Tmgr On Tm.TeamLeadID = tmgr.UserID
	Where Ad.ScorecardID = @ScorecardId 

	--Insert into #AuditScore
	Select Ad.AuditID, Round(AVG(COnvert(numeric, Ar.Score)),2) as [Audit Score] Into #AuditScore
	from Audits Ad
	Inner Join AuditReponses Ar on Ad.AuditID = ar.AuditID
	Where Ad.ScorecardID = @ScorecardId 
	Group By Ad.AuditID

	Select Ad.AuditID, Round(AVG(COnvert(numeric, ISNULL(Ar.Score,0))),2) as [Parameter Average Score] Into #ParameterScore
	
	from Audits Ad
	Inner Join AuditReponses Ar on Ad.AuditID = ar.AuditID
	Where Ad.ScorecardID = @ScorecardId 
	Group By Ad.AuditID



	SELECT 
		[AuditID], [Agent] as [Agent Name], [Auditor] as [Audited By],[Audit Date],[Rating] as [Customer Rating],
		AuditStatus as [Status], TeamName as Team,TeamLead as [Team Lead] 
	Into #AuditReport
	from (SELECT AuditID,AuditStatus, UserName,TeamName, TeamLead,ParamTitle, Response 
	FROM [dbo].#AuditReportData
	)x pivot (max(Response) for ParamTitle in ([Agent],[Audit Date],[Auditor],[Rating])) p

	Select 
			AR.[AuditID] As AuditId,  [Agent Name] as AgentName, [Audited By] as AuditedBy,[Audit Date] as AuditDate, [Customer Rating] as CustomerRating,
			Cast(CONVERT(DECIMAL(10,2),[Audit Score]) as nvarchar) as AuditScore,
			Cast(CONVERT(DECIMAL(10,2),[Parameter Average Score]) as nvarchar) as ParameterAverageScore,
			[Status],  Team, [Team Lead] as TeamLead
	From #AuditReport AR 
	Inner Join #AuditScore Sr on AR.[AuditID] = sr.AuditID
	inner Join #ParameterScore PSr on AR.[AuditID] = Psr.AuditID
END
GO
/****** Object:  StoredProcedure [dbo].[usp_rpt_ParamaverageReportbyScoreCardId]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- Exec dbo.usp_meanaverageReportbyScoreCardId 2
CREATE procedure [dbo].[usp_rpt_ParamaverageReportbyScoreCardId]
(
	 @ScorecardId Int
)

AS
BEGIN
--Drop table #AuditReportData

	IF OBJECT_ID('tempdb..#AuditReportParamPassData') IS NOT NULL
	Begin
	  DROP TABLE #AuditReportParamPassData
	END
	IF OBJECT_ID('tempdb..#AuditReportParamFailData') IS NOT NULL
	Begin
	  DROP TABLE #AuditReportParamFailData
	END

	IF OBJECT_ID('tempdb..#AuditReportParamData') IS NOT NULL
	Begin
	  DROP TABLE #AuditReportParamData
	END


	Create Table #AuditReportParamPassData (UserId int, Title nvarchar(100), Cnt int)

	Create Table #AuditReportParamFailData (UserId int, Title nvarchar(100), Cnt int)

	Insert into #AuditReportParamPassData
	select AD.UserID,SQ.ParamTitle, count(*) as Cnt 
	from Audits AD
	inner join AuditReponses AR on AR.AuditID = AD.AuditID
	inner join scQuestions SQ on AR.scQuestionID= SQ.scQuestionID 
	where SQ.ParamID > 5 and SQ.ParamID != 33 and SQ.ParamID != 32 and AR.Score=100 and SQ.ScorecardID=@ScorecardId
	group by AD.UserID,SQ.ParamTitle

	--select * from #AuditReportParamPassData

	Insert into #AuditReportParamFailData
	select AD.UserID,SQ.ParamTitle, count(*) as Cnt 
	from Audits AD
	inner join AuditReponses AR on AR.AuditID = AD.AuditID
	inner join scQuestions SQ on AR.scQuestionID= SQ.scQuestionID 
	where SQ.ParamID > 5 and SQ.ParamID != 33 and SQ.ParamID != 32 and AR.Score !=100 and SQ.ScorecardID=@ScorecardId
	group by AD.UserID,SQ.ParamTitle

	--select * from #AuditReportParamFailData
	
	Create Table #AuditReportParamData (UserId int, Title nvarchar(100), pCnt int,fCnt int)

	Insert into #AuditReportParamData 
	Select UserId,Title,cnt,0 from 
	#AuditReportParamPassData

	--select * from #AuditReportParamData

	update #AuditReportParamData set #AuditReportParamData.fCnt=#AuditReportParamFailData.Cnt
	from #AuditReportParamData inner join #AuditReportParamFailData on
	#AuditReportParamFailData.Title = #AuditReportParamData.Title and 
	#AuditReportParamFailData.UserId = #AuditReportParamData.UserId

	--select * from #AuditReportParamData

	insert into #AuditReportParamData 
	Select UserId,Title,0,cnt from #AuditReportParamFailData
	where #AuditReportParamFailData.Title not in (Select Title from #AuditReportParamData)


	Select UM.DisplayName, Title, pCnt, fCnt, pCnt+fCnt,
	case 
	when pCnt > 0 then (pCnt /(pCnt+fCnt)) * 100
	when pCnt = 0 then 0 end as PCntg, 
	case 
	when fCnt > 0 then 	(fCnt/(pCnt+fCnt)) * 100
	when fCnt = 0 then 0 end as fPCntg,  UM.MgrID from #AuditReportParamData RPTD Inner Join
	UserMaster UM ON RPTD.UserId=UM.UserID order by UM.DisplayName, Title
	

END
GO
/****** Object:  StoredProcedure [dbo].[usp_rpt_SummaryMASReportbyScoreCardId]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_rpt_SummaryMASReportbyScoreCardId]
(
	 @ScorecardId Int
)
AS
BEGIN

declare @temp table
(
    AuditId int,
    AgentName varchar(25),
    AuditedBy varchar(25),
    AuditDate varchar(15),
    CustomerRating numeric(5,2),
    AuditScore numeric(5,2),
    ParameterAverageScore numeric(5,2),
    Status varchar(15),
	Team varchar(25),
	TeamLead varchar(25)
);
INSERT @temp  EXEC [dbo].[usp_rpt_meanaverageReportbyScoreCardId] @ScorecardID = @ScorecardId; 
select count(AuditId) as AuditCnt,CONVERT(DECIMAL(10,2),Sum(AuditScore)/Count(AuditId)) as AuditAvg, 
CONVERT(DECIMAL(10,2), sum(ParameterAverageScore)/Count(AuditId)) 
as AuditPAvg  from @temp;

END
GO
/****** Object:  StoredProcedure [dbo].[Usp_UpdateintoParams]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
create Procedure [dbo].[Usp_UpdateintoParams]
(
@QuestionId Int,
@Title  Varchar(200)
)
AS
BEGIN
Update scQuestions set ParamTitle=@Title where scQuestionID =@QuestionId
END
 
GO
/****** Object:  StoredProcedure [dbo].[Usp_UpdateIntoSectionData]    Script Date: 4/12/2021 5:39:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[Usp_UpdateIntoSectionData]
(@SectionId int ,
@sectionName Varchar(50),
@sectionWeigh int
)
AS
Begin 
  Update scSections set SectionName=@sectionName,SectionWght=@sectionWeigh where scSectionID=@SectionId
END 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Audits"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 221
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "AuditReponses"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 136
               Right = 420
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ScorecardMaster"
            Begin Extent = 
               Top = 0
               Left = 537
               Bottom = 130
               Right = 710
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ParaMaster"
            Begin Extent = 
               Top = 0
               Left = 842
               Bottom = 130
               Right = 1012
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "scQuestions"
            Begin Extent = 
               Top = 138
               Left = 478
               Bottom = 268
               Right = 649
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Ali' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'UserAuditsVw'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'as = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'UserAuditsVw'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'UserAuditsVw'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[42] 4[20] 2[12] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "CompanyMaster"
            Begin Extent = 
               Top = 139
               Left = 733
               Bottom = 269
               Right = 906
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "UserMaster"
            Begin Extent = 
               Top = 0
               Left = 188
               Bottom = 214
               Right = 374
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "RoleMaster"
            Begin Extent = 
               Top = 33
               Left = 709
               Bottom = 129
               Right = 879
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 11
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'UserInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'UserInfo'
GO
USE [master]
GO
ALTER DATABASE [Scard2.0] SET  READ_WRITE 
GO
