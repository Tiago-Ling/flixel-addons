package flixel.addons.tile.isoXel;
import flixel.tile.FlxTilemap;
import flixel.tile.FlxTilemapBuffer;
import flixel.tile.FlxTile;

/**
 * Support for isometric tilemap
 * Started 27/11/2013
 * 
 * TODO:
	 * Autotiling
	 * Slopes
 * @author Masadow
 * @see FlxTilemap
 * @version 1.0.0
 */
class FlxTilemapIso extends FlxTilemap
{

	/**
	 * No auto-tiling.
	 * Copied from FlxTilemap
	 */
	inline static public var OFF:Int = 0;
	/**
	 * Good for levels with thin walls that don'tile need interior corner art.
	 * Copied from FlxTilemap
	 */
	inline static public var AUTO:Int = 1;
	/**
	 * Better for levels with thick walls that look better with interior corner art.
	 * Copied from FlxTilemap
	 */
	inline static public var ALT:Int = 2;
	
	public function new()
	{
		super();
	}
	
	/**
	 * Internal function that actually renders the tilemap to the tilemap buffer.  Called by draw().
	 * @param	Buffer		The <code>FlxTilemapBuffer</code> you are rendering to.
	 * @param	Camera		The related <code>FlxCamera</code>, mainly for scroll values.
	 */
	override private function drawTilemap(Buffer:FlxTilemapBuffer, Camera:FlxCamera):Void
	{
		#if flash
		Buffer.fill();
		#else
		_helperPoint.x = x - Camera.scroll.x * scrollFactor.x; //copied from getScreenXY()
		_helperPoint.y = y - Camera.scroll.y * scrollFactor.y;
		
		var tileID:Int;
		var drawX:Float;
		var drawY:Float;
		
		var hackScaleX:Float = tileScaleHack * scaleX;
		var hackScaleY:Float = tileScaleHack * scaleY;
		
		#if !js
		var drawItem:DrawStackItem = Camera.getDrawStackItem(cachedGraphics, false, 0);
		#else
		var drawItem:DrawStackItem = Camera.getDrawStackItem(cachedGraphics, false);
		#end
		var currDrawData:Array<Float> = drawItem.drawData;
		var currIndex:Int = drawItem.position;
		#end
		
		// Copy tile images into the tile buffer
		_point.x = (Camera.scroll.x * scrollFactor.x) - x; //modified from getScreenXY()
		_point.y = (Camera.scroll.y * scrollFactor.y) - y;
		
		var screenXInTiles:Int = Math.floor(_point.x / _scaledTileWidth);
		var screenYInTiles:Int = Math.floor(_point.y / _scaledTileHeight);
		var screenRows:Int = Buffer.rows;
		var screenColumns:Int = Buffer.columns;
		
		// Bound the upper left corner
		if (screenXInTiles < 0)
		{
			screenXInTiles = 0;
		}
		if (screenXInTiles > widthInTiles - screenColumns)
		{
			screenXInTiles = widthInTiles - screenColumns;
		}
		if (screenYInTiles < 0)
		{
			screenYInTiles = 0;
		}
		if (screenYInTiles > heightInTiles - screenRows)
		{
			screenYInTiles = heightInTiles - screenRows;
		}
		
		var rowIndex:Int = screenYInTiles * widthInTiles + screenXInTiles;
		_flashPoint.y = 0;
		var row:Int = 0;
		var column:Int;
		var columnIndex:Int;
		var tile:FlxTile;
		
		#if !FLX_NO_DEBUG
		var debugTile:BitmapData;
		#end 
		
		while (row < screenRows)
		{
			columnIndex = rowIndex;
			column = 0;
			_flashPoint.x = (heightInTiles * _scaledTileWidth / 2 - (_scaledTileWidth / 2 * (row + 1)));
			_flashPoint.y = row * (_scaledTileHeight / 2);
			
			while (column < screenColumns)
			{
				#if flash
				_flashRect = _rects[columnIndex];
				
				if (_flashRect != null)
				{
					Buffer.pixels.copyPixels(cachedGraphics.bitmap, _flashRect, _flashPoint, null, null, true);
					
					#if !FLX_NO_DEBUG
					if (FlxG.debugger.visualDebug && !ignoreDrawDebug) 
					{
						tile = _tileObjects[_data[columnIndex]];
						
						if(tile != null)
						{
							if (tile.allowCollisions <= FlxObject.NONE)
							{
								// Blue
								debugTile = _debugTileNotSolid; 
							}
							else if (tile.allowCollisions != FlxObject.ANY)
							{
								// Pink
								debugTile = _debugTilePartial; 
							}
							else
							{
								// Green
								debugTile = _debugTileSolid; 
							}
							
							Buffer.pixels.copyPixels(debugTile, _debugRect, _flashPoint, null, null, true);
						}
					}
					#end
				}
				#else
				tileID = _rectIDs[columnIndex];
				
				if (tileID != -1)
				{
					drawX = _helperPoint.x + (columnIndex % widthInTiles) * (_scaledTileWidth / 2);
					drawY = _helperPoint.y + Math.floor(columnIndex / widthInTiles) * (_scaledTileHeight / 2);
					
					#if !js
					currDrawData[currIndex++] = drawX;
					currDrawData[currIndex++] = drawY;
					#else
					currDrawData[currIndex++] = Math.floor(drawX);
					currDrawData[currIndex++] = Math.floor(drawY);
					#end
					currDrawData[currIndex++] = tileID;
					
					// Tilemap tearing hack
					currDrawData[currIndex++] = hackScaleX; 
					currDrawData[currIndex++] = 0;
					currDrawData[currIndex++] = 0;
					// Tilemap tearing hack
					currDrawData[currIndex++] = hackScaleY; 
					
					#if !js
					// Alpha
					currDrawData[currIndex++] = 1.0; 
					#end
				}
				#end
				
				#if flash
				_flashPoint.x += _scaledTileWidth / 2;
				_flashPoint.y += _scaledTileHeight / 2;
				#end
				column++;
				columnIndex++;
			}
			
			rowIndex += widthInTiles;
			row++;
		}
		
		#if !flash
		drawItem.position = currIndex;
		#end
		
		Buffer.x = screenXInTiles * _scaledTileWidth;
		Buffer.y = screenYInTiles * _scaledTileHeight;
	}	
	
}