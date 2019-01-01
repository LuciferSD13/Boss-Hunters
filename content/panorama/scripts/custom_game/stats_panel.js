GameEvents.Subscribe( "player_update_stats", UpdateStats);
GameEvents.Subscribe( "round_has_ended", ToggleStats);


function UpdateStats(arg)
{
	if (typeof arg != 'undefined') {
		for( pID in arg ){
			UpdateList(pID, "DT", Math.floor(arg[pID].DT + 0.5) )
			UpdateList(pID, "DD", Math.floor(arg[pID].DD + 0.5) )
			UpdateList(pID, "DH", Math.floor(arg[pID].DH + 0.5) )
		}
	}
}

function UpdateList(pID, tag, value)
{
	var PIDtag = $("#pID" + pID + tag)
	var holder = $("#" + tag + "Holder")
	if(PIDtag == null && holder != null){
		PIDtag = $.CreatePanel( "Label", holder, "pID" + pID + tag);
		PIDtag.AddClass("statsText")
	}
	var heroName = $.Localize( Entities.GetUnitName( Players.GetPlayerHeroEntityIndex( parseInt(pID) ) ) )
	var signifier = ""
	if(value / 1000000 > 1){ 
		value = (value / 1000000).toPrecision(3)
		signifier = "M"
	}else if(value / 1000 > 1){ 
		value = (value / 1000).toPrecision(3)
		signifier = "K"
	}
	PIDtag.text = heroName + " - " + value + signifier
}

function ToggleStats(arg)
{
	var teamInfo = $("#endRoundStats")
	if(arg != null)
	{
		teamInfo.SetHasClass("SetHidden", false )
		$("#CloseImageID").SetImage("file://{images}/custom_game/slideLeft.png")
	} else {
		teamInfo.SetHasClass("SetHidden", !(teamInfo.BHasClass("SetHidden")) )
		if(teamInfo.BHasClass("SetHidden")){
			$("#CloseImageID").SetImage("file://{images}/custom_game/slideRight.png")
		} else {
			$("#CloseImageID").SetImage("file://{images}/custom_game/slideLeft.png")
		}
	}
}