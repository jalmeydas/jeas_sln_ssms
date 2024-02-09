CREATE FUNCTION [dbo].[ST_PROPER]
(
@in as varchar(255) 
)
returns varchar(255)
as
BEGIN
	declare @in_pos tinyint,
			@inter varchar(255),
			@inter_pos tinyint

	select	@in_pos = 0,
			@in = lower(@in)
	select	@inter = @in
	select	@inter_pos = patindex('%\[0-9A-Za-z\]%', @inter)

	while @inter_pos > 0
	begin
		select	@in_pos = @in_pos + @inter_pos
		select	@in = stuff(@in, @in_pos, 1, upper(substring(@in, @in_pos, 1))),
				@inter = substring(@inter, @inter_pos + 1, datalength(@inter) - @inter_pos)
		select	@inter_pos = patindex('%\[^0-9A-Za-z\]%', @inter)
		if @inter_pos > 0
		begin
			select @in_pos = @in_pos + @inter_pos
			select @inter = substring(@inter, @inter_pos + 1, datalength(@inter) - @inter_pos)
			select @inter_pos = patindex('%\[0-9A-Za-z\]%', @inter)
		end
	end

	return @in
END
