function ProfileResize()
{
	function windowResize()
	{
		var correction = 10;
		document.getElementById("bdaeFrameContainer").style.height = 
			(document.documentElement.clientHeight - 
			document.getElementsByClassName("apexp")[0].offsetHeight - correction) + "px";
	}
	
	function startResize(resizeFunction)
	{
		var resizeTimeoutCode = null;
		window.top.onresize = function()
		{
			if (resizeTimeoutCode != null)
			{
				clearTimeout(resizeTimeoutCode);
			}
			resizeTimeoutCode = setTimeout(resizeFunction, 500);
		}
	}
	
	var isEmbedded = false;
	try
	{
		isEmbedded = (window.top != window);
	}
	catch(e)
	{
		isEmbedded = true;
	}
	
	if (!isEmbedded)
	{
		windowResize();
		startResize(windowResize);
	}
};