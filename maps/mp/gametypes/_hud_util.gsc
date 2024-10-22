#include maps\mp\_utility;
setParent( element )
{
	if ( isDefined( self.parent ) && self.parent == element )
		return;
		
	if ( isDefined( self.parent ) )
		self.parent removeChild( self );
	self.parent = element;
	self.parent addChild( self );
	if ( isDefined( self.point ) )
		self setPoint( self.point, self.relativePoint, self.xOffset, self.yOffset );
	else
		self setPoint( "TOPLEFT" );
}
getParent()
{
	return self.parent;
}
addChild( element )
{
	element.index = self.children.size;
	self.children[self.children.size] = element;
}
removeChild( element )
{
	element.parent = undefined;
	if ( self.children[self.children.size-1] != element )
	{
		self.children[element.index] = self.children[self.children.size-1];
		self.children[element.index].index = element.index;
	}
	self.children[self.children.size-1] = undefined;
	
	element.index = undefined;
}
setPoint( point, relativePoint, xOffset, yOffset, moveTime )
{
	if ( !isDefined( moveTime ) )
		moveTime = 0;
	element = self getParent();
	if ( moveTime )
		self moveOverTime( moveTime );
	
	if ( !isDefined( xOffset ) )
		xOffset = 0;
	self.xOffset = xOffset;
	if ( !isDefined( yOffset ) )
		yOffset = 0;
	self.yOffset = yOffset;
		
	self.point = point;
	self.alignX = "center";
	self.alignY = "middle";
	if ( isSubStr( point, "TOP" ) )
		self.alignY = "top";
	if ( isSubStr( point, "BOTTOM" ) )
		self.alignY = "bottom";
	if ( isSubStr( point, "LEFT" ) )
		self.alignX = "left";
	if ( isSubStr( point, "RIGHT" ) )
		self.alignX = "right";
	if ( !isDefined( relativePoint ) )
		relativePoint = point;
	self.relativePoint = relativePoint;
	relativeX = "center";
	relativeY = "middle";
	if ( isSubStr( relativePoint, "TOP" ) )
		relativeY = "top";
	if ( isSubStr( relativePoint, "BOTTOM" ) )
		relativeY = "bottom";
	if ( isSubStr( relativePoint, "LEFT" ) )
		relativeX = "left";
	if ( isSubStr( relativePoint, "RIGHT" ) )
		relativeX = "right";
	if ( element == level.uiParent )
	{
		self.horzAlign = relativeX;
		self.vertAlign = relativeY;
	}
	else
	{
		self.horzAlign = element.horzAlign;
		self.vertAlign = element.vertAlign;
	}
	if ( relativeX == element.alignX )
	{
		offsetX = 0;
		xFactor = 0;
	}
	else if ( relativeX == "center" || element.alignX == "center" )
	{
		offsetX = int(element.width / 2);
		if ( relativeX == "left" || element.alignX == "right" )
			xFactor = -1;
		else
			xFactor = 1;	
	}
	else
	{
		offsetX = element.width;
		if ( relativeX == "left" )
			xFactor = -1;
		else
			xFactor = 1;
	}
	self.x = element.x + (offsetX * xFactor);
	if ( relativeY == element.alignY )
	{
		offsetY = 0;
		yFactor = 0;
	}
	else if ( relativeY == "middle" || element.alignY == "middle" )
	{
		offsetY = int(element.height / 2);
		if ( relativeY == "top" || element.alignY == "bottom" )
			yFactor = -1;
		else
			yFactor = 1;	
	}
	else
	{
		offsetY = element.height;
		if ( relativeY == "top" )
			yFactor = -1;
		else
			yFactor = 1;
	}
	self.y = element.y + (offsetY * yFactor);
	
	self.x += self.xOffset;
	self.y += self.yOffset;
	
	switch ( self.elemType )
	{
		case "bar":
			setPointBar( point, relativePoint, xOffset, yOffset );
			
			self.barFrame setParent( self getParent() );
			self.barFrame setPoint( point, relativePoint, xOffset, yOffset );
			break;
	}
	
	self updateChildren();
}
setPointBar( point, relativePoint, xOffset, yOffset )
{
	self.bar.horzAlign = self.horzAlign;
	self.bar.vertAlign = self.vertAlign;
	
	self.bar.alignX = "left";
	self.bar.alignY = self.alignY;
	self.bar.y = self.y;
	
	if ( self.alignX == "left" )
		self.bar.x = self.x;
	else if ( self.alignX == "right" )
		self.bar.x = self.x - self.width;
	else
		self.bar.x = self.x - int(self.width / 2);
	
	if ( self.alignY == "top" )
		self.bar.y = self.y;
	else if ( self.alignY == "bottom" )
		self.bar.y = self.y;
	self updateBar( self.bar.frac );
}
updateBar( barFrac, rateOfChange )
{
	if ( self.elemType == "bar" )
		updateBarScale( barFrac, rateOfChange );
}
updateBarScale( barFrac, rateOfChange ) 
{
	barWidth = int(self.width * barFrac + 0.5); 
	
	if ( !barWidth )
		barWidth = 1;
	
	self.bar.frac = barFrac;
	self.bar setShader( self.bar.shader, barWidth, self.height );
	
	assertEx( barWidth <= self.width, "barWidth <= self.width: " + barWidth + " <= " + self.width + " - barFrac was " + barFrac );
	
	
	if ( isDefined( rateOfChange ) && barWidth < self.width ) 
	{
		if ( rateOfChange > 0 )
		{
			
			assertex( ((1 - barFrac) / rateOfChange) > 0, "barFrac: " + barFrac + "rateOfChange: " + rateOfChange );
			self.bar scaleOverTime( (1 - barFrac) / rateOfChange, self.width, self.height );
		}
		else if ( rateOfChange < 0 )
		{
			
			assertex(  (barFrac / (-1 * rateOfChange)) > 0, "barFrac: " + barFrac + "rateOfChange: " + rateOfChange );
			self.bar scaleOverTime( barFrac / (-1 * rateOfChange), 1, self.height );
		}
	}
	self.bar.rateOfChange = rateOfChange;
	self.bar.lastUpdateTime = getTime();
}
createFontString( font, fontScale )
{
	fontElem = newClientHudElem( self );
	fontElem.elemType = "font";
	fontElem.font = font;
	fontElem.fontscale = fontScale;
	fontElem.x = 0;
	fontElem.y = 0;
	fontElem.width = 0;
	fontElem.height = int(level.fontHeight * fontScale);
	fontElem.xOffset = 0;
	fontElem.yOffset = 0;
	fontElem.children = [];
	fontElem setParent( level.uiParent );
	fontElem.hidden = false;
	return fontElem;
}
createServerFontString( font, fontScale, team )
{
	if ( isDefined( team ) )
		fontElem = newTeamHudElem( team );
	else
		fontElem = newHudElem( self );
	
	fontElem.elemType = "font";
	fontElem.font = font;
	fontElem.fontscale = fontScale;
	fontElem.x = 0;
	fontElem.y = 0;
	fontElem.width = 0;
	fontElem.height = int(level.fontHeight * fontScale);
	fontElem.xOffset = 0;
	fontElem.yOffset = 0;
	fontElem.children = [];
	fontElem setParent( level.uiParent );
	fontElem.hidden = false;
	
	return fontElem;
}
createServerTimer( font, fontScale, team )
{	
	if ( isDefined( team ) )
		timerElem = newTeamHudElem( team );
	else
		timerElem = newHudElem( self );
	timerElem.elemType = "timer";
	timerElem.font = font;
	timerElem.fontscale = fontScale;
	timerElem.x = 0;
	timerElem.y = 0;
	timerElem.width = 0;
	timerElem.height = int(level.fontHeight * fontScale);
	timerElem.xOffset = 0;
	timerElem.yOffset = 0;
	timerElem.children = [];
	timerElem setParent( level.uiParent );
	timerElem.hidden = false;
	
	return timerElem;
}
createClientTimer( font, fontScale )
{
	timerElem = newClientHudElem( self );
	timerElem.elemType = "timer";
	timerElem.font = font;
	timerElem.fontscale = fontScale;
	timerElem.x = 0;
	timerElem.y = 0;
	timerElem.width = 0;
	timerElem.height = int(level.fontHeight * fontScale);
	timerElem.xOffset = 0;
	timerElem.yOffset = 0;
	timerElem.children = [];
	timerElem setParent( level.uiParent );
	timerElem.hidden = false;
	
	return timerElem;
}
createIcon( shader, width, height )
{
	iconElem = newClientHudElem( self );
	iconElem.elemType = "icon";
	iconElem.x = 0;
	iconElem.y = 0;
	iconElem.width = width;
	iconElem.height = height;
	iconElem.xOffset = 0;
	iconElem.yOffset = 0;
	iconElem.children = [];
	iconElem setParent( level.uiParent );
	iconElem.hidden = false;
	
	if ( isDefined( shader ) )
		iconElem setShader( shader, width, height );
	
	return iconElem;
}
createServerIcon( shader, width, height, team )
{
	if ( isDefined( team ) )
		iconElem = newTeamHudElem( team );
	else
		iconElem = newHudElem( self );
	iconElem.elemType = "icon";
	iconElem.x = 0;
	iconElem.y = 0;
	iconElem.width = width;
	iconElem.height = height;
	iconElem.xOffset = 0;
	iconElem.yOffset = 0;
	iconElem.children = [];
	iconElem setParent( level.uiParent );
	iconElem.hidden = false;
	
	if ( isDefined( shader ) )
		iconElem setShader( shader, width, height );
	
	return iconElem;
}
createServerBar( color, width, height, flashFrac, team, selected )
{
	if ( isDefined( team ) )
		barElem = newTeamHudElem( team );
	else
		barElem = newHudElem( self );
	barElem.x = 0;
	barElem.y = 0;
	barElem.frac = 0;
	barElem.color = color;
	barElem.sort = -2;
	barElem.shader = "progress_bar_fill";
	barElem setShader( "progress_bar_fill", width, height );
	barElem.hidden = false;
	if ( isDefined( flashFrac ) )
	{
		barElem.flashFrac = flashFrac;
	}
	if ( isDefined( team ) )
		barElemFrame = newTeamHudElem( team );
	else
		barElemFrame = newHudElem( self );
	barElemFrame.elemType = "icon";
	barElemFrame.x = 0;
	barElemFrame.y = 0;
	barElemFrame.width = width;
	barElemFrame.height = height;
	barElemFrame.xOffset = 0;
	barElemFrame.yOffset = 0;
	barElemFrame.bar = barElem;
	barElemFrame.barFrame = barElemFrame;
	barElemFrame.children = [];
	barElemFrame.sort = -1;
	barElemFrame.color = (1,1,1);
	barElemFrame setParent( level.uiParent );
	if ( isDefined( selected ) )
		barElemFrame setShader( "progress_bar_fg_sel", width, height );
	else
		barElemFrame setShader( "progress_bar_fg", width, height );
	barElemFrame.hidden = false;
	if ( isDefined( team ) )
		barElemBG = newTeamHudElem( team );
	else
		barElemBG = newHudElem( self );
	barElemBG.elemType = "bar";
	barElemBG.x = 0;
	barElemBG.y = 0;
	barElemBG.width = width;
	barElemBG.height = height;
	barElemBG.xOffset = 0;
	barElemBG.yOffset = 0;
	barElemBG.bar = barElem;
	barElemBG.barFrame = barElemFrame;
	barElemBG.children = [];
	barElemBG.sort = -3;
	barElemBG.color = (0,0,0);
	barElemBG.alpha = 0.5;
	barElemBG setParent( level.uiParent );
	barElemBG setShader( "progress_bar_bg", width, height );
	barElemBG.hidden = false;
	
	return barElemBG;
}
createBar( color, width, height, flashFrac )
{
	barElem = newClientHudElem(	self );
	barElem.x = 0 ;
	barElem.y = 0;
	barElem.frac = 0;
	barElem.color = color;
	barElem.sort = -2;
	barElem.shader = "progress_bar_fill";
	barElem setShader( "progress_bar_fill", width, height );
	barElem.hidden = false;
	if ( isDefined( flashFrac ) )
	{
		barElem.flashFrac = flashFrac;
	}
	barElemFrame = newClientHudElem( self );
	barElemFrame.elemType = "icon";
	barElemFrame.x = 0;
	barElemFrame.y = 0;
	barElemFrame.width = width;
	barElemFrame.height = height;
	barElemFrame.xOffset = 0;
	barElemFrame.yOffset = 0;
	barElemFrame.bar = barElem;
	barElemFrame.barFrame = barElemFrame;
	barElemFrame.children = [];
	barElemFrame.sort = -1;
	barElemFrame.color = (1,1,1);
	barElemFrame setParent( level.uiParent );
	barElemFrame.hidden = false;
	
	barElemBG = newClientHudElem( self );
	barElemBG.elemType = "bar";
	if ( !level.splitScreen )
	{
		barElemBG.x = -2;
		barElemBG.y = -2;
	}
	barElemBG.width = width;
	barElemBG.height = height;
	barElemBG.xOffset = 0;
	barElemBG.yOffset = 0;
	barElemBG.bar = barElem;
	barElemBG.barFrame = barElemFrame;
	barElemBG.children = [];
	barElemBG.sort = -3;
	barElemBG.color = (0,0,0);
	barElemBG.alpha = 0.5;
	barElemBG setParent( level.uiParent );
	if ( !level.splitScreen )
		barElemBG setShader( "progress_bar_bg", width + 4, height + 4 );
	else
		barElemBG setShader( "progress_bar_bg", width + 0, height + 0 );
	barElemBG.hidden = false;
	
	return barElemBG;
}
getCurrentFraction()
{
	frac = self.bar.frac;
	if (isdefined(self.bar.rateOfChange))
	{
		frac += (getTime() - self.bar.lastUpdateTime) * self.bar.rateOfChange;
		if (frac > 1) frac = 1;
		if (frac < 0) frac = 0;
	}
	return frac;
}
createPrimaryProgressBar()
{
	bar = createBar( (1, 1, 1), level.primaryProgressBarWidth, level.primaryProgressBarHeight );
	if ( level.splitScreen )
		bar setPoint("TOP", undefined, level.primaryProgressBarX, level.primaryProgressBarY);
	else
		bar setPoint("CENTER", undefined, level.primaryProgressBarX, level.primaryProgressBarY);
	return bar;
}
createPrimaryProgressBarText()
{
	text = createFontString( "objective", level.primaryProgressBarFontSize );
	if ( level.splitScreen )
		text setPoint("TOP", undefined, level.primaryProgressBarTextX, level.primaryProgressBarTextY);
	else
		text setPoint("CENTER", undefined, level.primaryProgressBarTextX, level.primaryProgressBarTextY);
	
	text.sort = -1;
	return text;
}
createSecondaryProgressBar()
{
	secondaryProgressBarHeight = getDvarIntDefault( "scr_secondaryProgressBarHeight", level.secondaryProgressBarHeight );
	secondaryProgressBarX = getDvarIntDefault( "scr_secondaryProgressBarX", level.secondaryProgressBarX );
	secondaryProgressBarY = getDvarIntDefault( "scr_secondaryProgressBarY", level.secondaryProgressBarY );
	bar = createBar( (1, 1, 1), level.secondaryProgressBarWidth, secondaryProgressBarHeight );
	if ( level.splitScreen )
		bar setPoint("TOP", undefined, secondaryProgressBarX, secondaryProgressBarY);
	else
		bar setPoint("CENTER", undefined, secondaryProgressBarX, secondaryProgressBarY);
	return bar;
}
createSecondaryProgressBarText()
{
	secondaryProgressBarTextX = getDvarIntDefault( "scr_btx", level.secondaryProgressBarTextX );
	secondaryProgressBarTextY = getDvarIntDefault( "scr_bty", level.secondaryProgressBarTextY );
	text = createFontString( "objective", level.primaryProgressBarFontSize );
	if ( level.splitScreen )
		text setPoint("TOP", undefined, secondaryProgressBarTextX, secondaryProgressBarTextY);
	else
		text setPoint("CENTER", undefined, secondaryProgressBarTextX, secondaryProgressBarTextY);
	
	text.sort = -1;
	return text;
}
createTeamProgressBar( team )
{
	bar = createServerBar( (1,0,0), level.teamProgressBarWidth, level.teamProgressBarHeight, undefined, team );
	bar setPoint("TOP", undefined, 0, level.teamProgressBarY);
	return bar;
}
createTeamProgressBarText( team )
{
	text = createServerFontString( "default", level.teamProgressBarFontSize, team );
	text setPoint("TOP", undefined, 0, level.teamProgressBarTextY);
	return text;
}
setFlashFrac( flashFrac )
{
	self.bar.flashFrac = flashFrac;
}
hideElem()
{
	if ( self.hidden )
		return;
		
	self.hidden = true;
	if ( self.alpha != 0 )
		self.alpha = 0;
	
	if ( self.elemType == "bar" || self.elemType == "bar_shader" )
	{
		self.bar.hidden = true;
		if ( self.bar.alpha != 0 )
			self.bar.alpha = 0;
		self.barFrame.hidden = true;
		if ( self.barFrame.alpha != 0 )
			self.barFrame.alpha = 0;
	}
}
showElem()
{
	if ( !self.hidden )
		return;
		
	self.hidden = false;
	if ( self.elemType == "bar" || self.elemType == "bar_shader" )
	{
		if ( self.alpha != .5 )
			self.alpha = .5;
		
		self.bar.hidden = false;
		if ( self.bar.alpha != 1 )
			self.bar.alpha = 1;
		self.barFrame.hidden = false;
		if ( self.barFrame.alpha != 1 )
			self.barFrame.alpha = 1;
	}
	else
	{
		if ( self.alpha != 1 )
			self.alpha = 1;
	}
}
flashThread()
{
	self endon ( "death" );
	if ( !self.hidden )
		self.alpha = 1;
		
	while(1)
	{
		if ( self.frac >= self.flashFrac )
		{
			if ( !self.hidden )
			{
				self fadeOverTime(0.3);
				self.alpha = .2;
				wait(0.35);
				self fadeOverTime(0.3);
				self.alpha = 1;
			}
			wait(0.7);
		}
		else
		{
			if ( !self.hidden && self.alpha != 1 )
				self.alpha = 1;
			wait ( 0.05 );
		}
	}
}
destroyElem()
{
	tempChildren = [];
	for ( index = 0; index < self.children.size; index++ )
	{
		if ( isDefined( self.children[index] ) )
			tempChildren[tempChildren.size] = self.children[index];
	}
	for ( index = 0; index < tempChildren.size; index++ )
		tempChildren[index] setParent( self getParent() );
		
	if ( self.elemType == "bar" || self.elemType == "bar_shader" )
	{
		self.bar destroy();
		self.barFrame destroy();
	}
		
	self destroy();
}
setIconShader( shader )
{
	self setShader( shader, self.width, self.height );
}
setWidth( width )
{
	self.width = width;
}
setHeight( height )
{
	self.height = height;
}
setSize( width, height )
{
	self.width = width;
	self.height = height;
}
updateChildren()
{
	for ( index = 0; index < self.children.size; index++ )
	{
		child = self.children[index];
		child setPoint( child.point, child.relativePoint, child.xOffset, child.yOffset );
	}
}
createLoadoutIcon( verIndex, horIndex, xpos, ypos )
{
	iconsize = 32;
	if ( level.splitScreen )
		ypos = ypos - (80 + iconsize * (3 - verIndex));
	else
		ypos = ypos - (90 + iconsize * (3 - verIndex));
	
	if ( level.splitScreen )
		xpos = xpos - (5 + iconsize * horIndex);
	else
		xpos = xpos - (10 + iconsize * horIndex);
	icon = createIcon( "white", iconsize, iconsize );
	icon setPoint( "BOTTOM RIGHT", "BOTTOM RIGHT", xpos, ypos );
	icon.horzalign = "user_right";
	icon.vertalign = "user_bottom";
	icon.archived = false;
	icon.foreground = true;
	icon.overrridewhenindemo = true;
	return icon;
}
setLoadoutIconCoords( verIndex, horIndex, xpos, ypos )
{
	iconsize = 32;
	if ( level.splitScreen )
		ypos = ypos - (80 + iconsize * (3 - verIndex));
	else
		ypos = ypos - (90 + iconsize * (3 - verIndex));
	
	if ( level.splitScreen )
		xpos = xpos - (5 + iconsize * horIndex);
	else
		xpos = xpos - (10 + iconsize * horIndex);
	self setPoint( "BOTTOM RIGHT", "BOTTOM RIGHT", xpos, ypos );
	self.horzalign = "user_right";
	self.vertalign = "user_bottom";
	self.archived = false;
	self.foreground = true;
}
setLoadoutTextCoords( xCoord)
{
	self setPoint( "RIGHT", "LEFT", xCoord, 0 );
}
createLoadoutText( icon, xCoord )
{
	text = createFontString( "default", 1.4 );
	text setParent( icon );
	text setPoint( "RIGHT", "LEFT", xCoord, 0 );
	text.archived = false;
	text.alignX = "right";
	text.alignY = "middle";
	text.foreground = true;
	text.overrridewhenindemo = true;
	return text;
}
showLoadoutAttribute( iconElem, icon, alpha, textElem, text )
{
	iconsize = 32;
	iconElem.alpha = alpha;
	if ( alpha )
		iconElem setShader( icon, iconsize, iconsize );
	if ( isdefined( textElem ) )
	{
		textElem.alpha = alpha;
		if ( alpha )
			textElem setText( text );
	}
}
hideLoadoutAttribute( iconElem, fadeTime, textElem, hideTextOnly )
{
	if ( isdefined( fadeTime ) )
	{
		if ( !isDefined( hideTextOnly ) || !hideTextOnly )
		{
			iconElem fadeOverTime( fadeTime );
		}
		if ( isDefined( textElem ) )
		{
			textElem fadeOverTime( fadeTime );
		}
	}
	
	if ( !isDefined( hideTextOnly ) || !hideTextOnly )
		iconElem.alpha = 0;
	if ( isDefined( textElem ) )
		textElem.alpha = 0;
}
showPerk( index, perk, ypos )
{
	
	assert( game["state"] != "postgame" );
	
	if ( !isdefined( self.perkicon ) )
	{
		self.perkicon = [];
		self.perkname = [];
	}
	
	if ( !isdefined( self.perkicon[ index ] ) )
	{
		assert( !isdefined( self.perkname[ index ] ) );
		
		if( index==3 ) 
			self.perkicon[ index ] = createLoadoutIcon( 4, 0, 200, ypos ); 
		else
			self.perkicon[ index ] = createLoadoutIcon( index, 0, 200, ypos ); 
			
		self.perkname[ index ] = createLoadoutText( self.perkicon[ index ], 160 );
	}
	else 
	{
		if( index==3 ) 
			self.perkicon[ index ] setLoadoutIconCoords( 4, 0, 200, ypos ); 
		else
			self.perkicon[ index ] setLoadoutIconCoords( index, 0, 200, ypos ); 
		self.perkname[ index ] setLoadoutTextCoords( 160 ); 
	}
	if ( perk == "specialty_null" || perk == "weapon_null" )
	{
		alpha = 0;
	}
	else
	{
		assertex( isDefined( level.perkIcons[ perk ] ), perk );
		assertex( isDefined( level.perkNames[ perk ] ), perk );
		alpha = 1;
	}
	
	showLoadoutAttribute( self.perkicon[ index ], level.perkIcons[ perk ], alpha, self.perkname[ index ], level.perkNames[ perk ] );
	self.perkicon[ index ] moveOverTime( 0.3 );
	self.perkicon[ index ].x = -5;
	self.perkicon[ index ].hidewheninmenu = true;
	self.perkname[ index ] moveOverTime( 0.3 );
	self.perkname[ index ].x = -40;
	self.perkname[ index ].hidewheninmenu = true;
}
hidePerk( index, fadeTime, hideTextOnly )
{
	if ( !isdefined( fadeTime ) )
		fadeTime = 0.05;
	
	if ( GetDvarInt( #"scr_game_perks" ) == 1 )
	{
		if ( game["state"] == "postgame" )
		{
			
			
			if ( isdefined( self.perkicon ) )
			{
			    
			    assert( !isdefined( self.perkicon[ index ] ) );
			    assert( !isdefined( self.perkname[ index ] ) );
			}
			return;
		}
		assert( isdefined( self.perkicon[ index ] ) );
		assert( isdefined( self.perkname[ index ] ) );
	
		if ( IsDefined( self.perkicon ) && IsDefined( self.perkicon[ index ] ) && IsDefined( self.perkname ) && IsDefined( self.perkname[ index ] ) )
		{
			hideLoadoutAttribute( self.perkicon[ index ], fadeTime, self.perkname[ index ], hideTextOnly );
		}
	}
}
showKillstreak( index, killstreak, xpos, ypos )
{
	
	assert( game["state"] != "postgame" );
	
	if ( !isdefined( self.killstreakIcon ) )
		self.killstreakIcon = [];
	
	if ( !isdefined( self.killstreakIcon[ index ] ) )
	{	
		
		
		
		self.killstreakIcon[ index ] = createLoadoutIcon( 3, self.killstreak.size - 1 - index, xpos, ypos ); 
	}
	if ( killstreak == "killstreak_null" || killstreak == "weapon_null" )
	{
		alpha = 0;
	}
	else
	{
		assertex( isDefined( level.killstreakIcons[ killstreak ] ), killstreak );
		alpha = 1;
	}
	
	showLoadoutAttribute( self.killstreakIcon[ index ], level.killstreakIcons[ killstreak ], alpha );
}
hideKillstreak( index, fadetime )
{
	
	if ( isHardPointsEnabled() )
	{
		if ( game["state"] == "postgame" )
		{
			
			assert( !isdefined( self.killstreakIcon[ index ] ) );
			return;
		}
		assert( isdefined( self.killstreakIcon[ index ] ) );
	
		hideLoadoutAttribute( self.killstreakIcon[ index ], fadetime );
	}
}