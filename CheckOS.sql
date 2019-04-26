:setvar LinuxOS "Linux"
:setvar WindowsOS "Windows"
:setvar SubSysTSQL "TSQL"
:setvar SubSysCmdExec "CmdExec"

DECLARE @DetectedOS nvarchar(7);

-- sys.dm_os_host_info is relatively new (SQL 2017+ despite what BOL says; not from 2008). If it's there, query it (result being 'Linux' or 'Windows'). If not there, it's Windows.
IF EXISTS (SELECT 1 FROM sys.system_objects WHERE [name] = N'dm_os_host_info' AND [schema_id] = SCHEMA_ID(N'sys'))
  SELECT @DetectedOS = [host_platform] FROM sys.dm_os_host_info;
ELSE 
  SELECT @DetectedOS = N'$(WindowsOS)';
GO

		/* No CmdExec subsystem for Linux. */
		IF @DetectedOS = N'$(LinuxOS)'
			EXEC msdb.dbo.sp_update_jobstep @job_id=@jobId, @step_id = 1, @subsystem = N'$(SubSysTSQL)';
		ELSE
			EXEC msdb.dbo.sp_update_jobstep @job_id=@jobId, @step_id = 1, @subsystem = N'$(SubSysCmdExec)';
      
		/* No CmdExec subsystem for Linux. */
		IF @DetectedOS = N'$(LinuxOS)'
		BEGIN
