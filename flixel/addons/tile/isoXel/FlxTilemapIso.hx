package flixel.addons.tile.isoXel;
import flixel.FlxObject;
import flixel.tile.FlxTilemap;
import flixel.tile.FlxTile;
import flixel.tile.FlxTilemapBuffer;
import flixel.system.layer.DrawStackItem;
import flixel.util.FlxPoint;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.geom.Point;
import flixel.util.FlxArrayUtil;
import flixel.system.layer.Region;
import flixel.util.loaders.TextureRegion;
import flixel.system.FlxCollisionType;
import flixel.system.FlxAssets;


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
class FlxTilemapIso extends FlxObject
{
	/**
	 * A set of generic tiles you can use. Useful for protyping.
	 */
	inline static public var imgAuto:String = FlxAssets.IMG_AUTO;
	/**
	 * An alternate set of generic tiles you can use. Useful for protyping.
	 */
	inline static public var imgAutoAlt:String = FlxAssets.IMG_AUTO_ALT;

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

	public var scaleX(default, set):Float = 1.0;
	public var scaleY(default, set):Float = 1.0;
	
	/**
	 * Set this flag to use one of the 16-tile binary auto-tile algorithms (OFF, AUTO, or ALT).
	 */
	public var auto:Int;
	/**
	 * Read-only variable, do NOT recommend changing after the map is loaded!
	 */
	public var widthInTiles:Int;
	/**
	 * Read-only variable, do NOT recommend changing after the map is loaded!
	 */
	public var heightInTiles:Int;
	/**
	 * Read-only variable, do NOT recommend changing after the map is loaded!
	 */
	public var totalTiles:Int;
	/**
	 * Helper variable for non-flash targets. Adjust it's value if you'll see tilemap tearing (empty pixels between tiles). To something like 1.02 or 1.03
	 */
	public var tileScaleHack:Float = 1.01;
	/**
	 * Set this to create your own image index remapper, so you can create your own tile layouts.
	 * Mostly useful in combination with the auto-tilers.
	 * 
	 * Normally, each tile's value in _data corresponds to the index of a 
	 * tile frame in the tilesheet. With this active, each value in _data
	 * is a lookup value to that index in customTileRemap.
	 * 
	 * Example:
	 *  customTileRemap = [10,9,8,7,6]
	 *  means: 0=10, 1=9, 2=8, 3=7, 4=6
	 */
	public var customTileRemap:Array<Int> = null;
	/**
	 * If these next two arrays are not null, you're telling FlxTilemap to 
	 * draw random tiles in certain places. 
	 * 
	 * _randomIndices is a list of tilemap values that should be replaced
	 * by a randomly selected value. The available values are chosen from
	 * the corresponding array in randomize_choices
	 * 
	 * So if you have:
	 *   randomIndices = [12,14]
	 *   randomChoices = [[0,1,2],[3,4,5,6,7]]
	 * 
	 * Everywhere the tilemap has a value of 12 it will be replaced by 0, 1, or, 2
	 * Everywhere the tilemap has a value of 14 it will be replaced by 3, 4, 5, 6, 7
	 */
	private var _randomIndices:Array<Int> = null;
	private var _randomChoices:Array<Array<Int>> = null;
	/**
	 * Setting this function allows you to control which choice will be selected for each element within _randomIndices array.
	 * Must return a 0-1 value that gets multiplied by _randomChoices[randIndex].length;
	 */
	private var _randomLambda:Void->Float = null;
	/**
	 * Rendering helper, minimize new object instantiation on repetitive methods.
	 */
	private var _flashPoint:Point;
	/**
	 * Rendering helper, minimize new object instantiation on repetitive methods.
	 */
	private var _flashRect:Rectangle;
	/**
	 * Internal list of buffers, one for each camera, used for drawing the tilemaps.
	 */
	private var _buffers:Array<FlxTilemapBuffer>;
	/**
	 * Internal representation of the actual tile data, as a large 1D array of integers.
	 */
	private var _data:Array<Int>;
	/**
	 * Internal representation of rectangles, one for each tile in the entire tilemap, used to speed up drawing.
	 */
	#if flash
	private var _rects:Array<Rectangle>;
	#end
	/**
	 * Internal, the width of a single tile.
	 */
	private var _tileWidth:Int;
	/**
	 * Internal, the depth of a single tile.
	 */
	private var _tileDepth:Int;
	/**
	 * Internal, the height of a single tile.
	 */
	private var _tileHeight:Int;
	
	private var _scaledTileWidth:Float;
	private var _scaledTileDepth:Float;
	private var _scaledTileHeight:Float;
	
	/**
	 * Internal collection of tile objects, one for each type of tile in the map (NOTE one for every single tile in the whole map).
	 */
	private var _tileObjects:Array<FlxTileIso>;
	
	#if !FLX_NO_DEBUG
	#if flash
	/**
	 * Internal, used for rendering the debug bounding box display.
	 */
	private var _debugTileNotSolid:BitmapData;
	/**
	 * Internal, used for rendering the debug bounding box display.
	 */
	private var _debugTilePartial:BitmapData;
	/**
	 * Internal, used for rendering the debug bounding box display.
	 */
	private var _debugTileSolid:BitmapData;
	/**
	 * Internal, used for rendering the debug bounding box display.
	 */
	private var _debugRect:Rectangle;
	#end
	/**
	 * Internal flag for checking to see if we need to refresh
	 * the tilemap display to show or hide the bounding boxes.
	 */
	private var _lastVisualDebug:Bool;
	#end
	/**
	 * Internal, used to sort of insert blank tiles in front of the tiles in the provided graphic.
	 */
	private var _startingIndex:Int;
	#if !flash
	/**
	 * Rendering helper, minimize new object instantiation on repetitive methods. Used only in cpp
	 */
	private var _helperPoint:Point;
	/**
	 * Internal representation of rectangles (actually id of rectangle in tileSheet), one for each tile in the entire tilemap, used to speed up drawing.
	 */
	private var _rectIDs:Array<Int>;
	#end
	
	/**
	 * The tilemap constructor just initializes some basic variables.
	 */
	public function new()
	{
		super();
		
		collisionType = FlxCollisionType.TILEMAP;
		
		auto = OFF;
		widthInTiles = 0;
		heightInTiles = 0;
		totalTiles = 0;
		_buffers = new Array<FlxTilemapBuffer>();
		_flashPoint = new Point();
		_flashRect = null;
		_data = null;
		_tileWidth = 0;
		_tileDepth = 0;
		_tileHeight = 0;
		
		#if flash
		_rects = null;
		#if !FLX_NO_DEBUG
		_debugRect = null;
		#end
		#else
		_rectIDs = null;
		#end
		_tileObjects = null;
		immovable = true;
		moves = false;
		cameras = null;
		#if !FLX_NO_DEBUG
		#if flash
		_debugTileNotSolid = null;
		_debugTilePartial = null;
		_debugTileSolid = null;
		#end
		_lastVisualDebug = FlxG.debugger.visualDebug;
		#end
		
		_startingIndex = 0;
		
		#if !flash
		_helperPoint = new Point();
		#end
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		_flashPoint = null;
		_flashRect = null;
		var i:Int = 0;
		var l:Int;
		
		if (_tileObjects != null)
		{
			l = _tileObjects.length;
			
			for (i in 0...l)
			{
				_tileObjects[i].destroy();
			}
			
			_tileObjects = null;
		}
		
		if (_buffers != null)
		{
			i = 0;
			l = _buffers.length;
			
			for (i in 0...l)
			{
				_buffers[i].destroy();
			}
			
			_buffers = null;
		}
		
		_data = null;
		
		#if flash
		_rects = null;
		#if !FLX_NO_DEBUG
		_debugRect = null;
		_debugTileNotSolid = null;
		_debugTilePartial = null;
		_debugTileSolid = null;
		#end
		#else
		_helperPoint = null;
		_rectIDs = null;
		#end

		super.destroy();
	}

	#if !FLX_NO_DEBUG
	/**
	 * Main logic loop for tilemap is pretty simple,
	 * just checks to see if visual debug got turned on.
	 * If it did, the tilemap is flagged as dirty so it
	 * will be redrawn with debug info on the next draw call.
	 */
	override public function update():Void
	{
		if (_lastVisualDebug != FlxG.debugger.visualDebug)
		{
			_lastVisualDebug = FlxG.debugger.visualDebug;
			setDirty();
		}
		
		super.update();
	}
	#end

	/**
	 * Internal function used in setTileByIndex() and the constructor to update the map.
	 * 
	 * NEED TEST
	 * 
	 * @param	Index		The index of the tile you want to update.
	 */
	private function updateTile(Index:Int):Void
	{
		var tile:FlxTileIso = _tileObjects[_data[Index]];
		
		if ((tile == null) || !tile.visible)
		{
			#if flash
			_rects[Index] = null;
			#else
			_rectIDs[Index] = -1;
			#end
			
			return;
		}
		
		#if flash
		var rx:Int = (_data[Index] - _startingIndex) * (_tileWidth + region.spacingX);
		var ry:Int = 0;
		
		if (Std.int(rx) >= region.width)
		{
			ry = Std.int(rx / region.width) * (_tileDepth + region.spacingY);
			rx %= region.width;
		}
		_rects[Index] = (new Rectangle(rx + region.startX, ry + region.startY, _tileWidth, _tileDepth));
		#else
		_rectIDs[Index] = framesData.frames[_data[Index] - _startingIndex].tileID;
		#end
	}

	/**
	 * Load the tilemap with string data and a tile graphic.
	 * 
	 * @param	MapData      	A string of comma and line-return delineated indices indicating what order the tiles should go in, or an <code>Array of Int</code>. YOU MUST SET <code>widthInTiles</code> and <code>heightInTyles</code> manually BEFORE CALLING <code>loadMap</code> if you pass an Array!
	 * @param	TileGraphic		All the tiles you want to use, arranged in a strip corresponding to the numbers in MapData.
	 * @param	TileWidth		The width of your tiles (e.g. 8) - defaults to height of the tile graphic if unspecified.
	 * @param	TileDepth		The depth of your tiles (e.g. 8) - defaults to width if unspecified.
	 * @param	TileHeight		The height of your tiles (e.g. 8) - defaults to 0 if unspecified.
	 * @param	AutoTile		Whether to load the map using an automatic tile placement algorithm.  Setting this to either AUTO or ALT will override any values you put for StartingIndex, DrawIndex, or CollideIndex.
	 * @param	StartingIndex	Used to sort of insert empty tiles in front of the provided graphic.  Default is 0, usually safest ot leave it at that.  Ignored if AutoTile is set.
	 * @param	DrawIndex		Initializes all tile objects equal to and after this index as visible. Default value is 1.  Ignored if AutoTile is set.
	 * @param	CollideIndex	Initializes all tile objects equal to and after this index as allowCollisions = ANY.  Default value is 1.  Ignored if AutoTile is set.  Can override and customize per-tile-type collision behavior using <code>setTileProperties()</code>.
	 * @return	A reference to this instance of FlxTilemap, for chaining as usual :)
	 */
	public function loadMap(MapData:Dynamic, TileGraphic:Dynamic, TileWidth:Int = 0, TileDepth:Int = 0, TileHeight:Int = 0, AutoTile:Int = 0, StartingIndex:Int = 0, DrawIndex:Int = 1, CollideIndex:Int = 1):FlxTilemapIso
	{
		auto = AutoTile;
		_startingIndex = (StartingIndex <= 0) ? 0 : StartingIndex;
		
		// Populate data if MapData is a CSV string
		if (Std.is(MapData, String))
		{
			// Figure out the map dimensions based on the data string
			_data = new Array<Int>();
			var columns:Array<String>;
			var rows:Array<String> = MapData.split("\n");
			heightInTiles = rows.length;
			widthInTiles = 0;
			var row:Int = 0;
			var column:Int;
			
			while (row < heightInTiles)
			{
				columns = rows[row++].split(",");
				
				if (columns.length <= 1)
				{
					heightInTiles = heightInTiles - 1;
					continue;
				}
				if (widthInTiles == 0)
				{
					widthInTiles = columns.length;
				}
				column = 0;
				
				while (column < widthInTiles)
				{
					_data.push(Std.parseInt(columns[column++]));
				}
			}
		}
		// Data is already set up as an Array<Int>
		// DON'T FORGET TO SET 'widthInTiles' and 'heightInTyles' manually BEFORE CALLING loadMap() if you pass an Array<Int>!
		else if (Std.is(MapData, Array))
		{
			_data = MapData;
		}
		else
		{
			throw "Unexpected MapData format '" + Type.typeof(MapData) + "' passed into loadMap. Map data must be CSV string or Array<Int>.";
		}
		
		// Pre-process the map data if it's auto-tiled
		var i:Int;
		totalTiles = _data.length;
		
		if (auto > OFF)
		{
			_startingIndex = 1;
			DrawIndex = 1;
			CollideIndex = 1;
			i = 0;
			
			while (i < totalTiles)
			{
				autoTile(i++);
			}
		}
		
		if (customTileRemap != null) 
		{
			i = 0;
			while ( i < totalTiles) 
			{
				var old_index = _data[i];
				var new_index = old_index;
				if (old_index < customTileRemap.length)
				{
					new_index = customTileRemap[old_index];
				}
				_data[i] = new_index;
				i++;
			}
		}
		
		if (_randomIndices != null)
		{
			var randLambda:Void->Float = _randomLambda != null ? _randomLambda : Math.random;
			
			i = 0;
			while (i < totalTiles)
			{
				var old_index = _data[i];
				var j = 0;
				var new_index = old_index;
				for (rand in _randomIndices) 
				{
					if (old_index == rand) 
					{
						var k:Int = Std.int(randLambda() * _randomChoices[j].length);
						new_index = _randomChoices[j][k];
					}
					j++;
				}
				_data[i] = new_index;
				i++;
			}
		}
		
		// Figure out the size of the tiles
		cachedGraphics = FlxG.bitmap.add(TileGraphic);
		_tileWidth = TileWidth;
		
		if (_tileWidth <= 0)
		{
			_tileWidth = cachedGraphics.bitmap.height;
		}
		
		_tileDepth = TileDepth;
		
		if (_tileDepth <= 0)
		{
			_tileDepth = _tileWidth;
		}
		
		_tileHeight = TileHeight;
		
		if (_tileHeight < 0)
		{
			_tileHeight = 0;
		}
		
		if (!Std.is(TileGraphic, TextureRegion))
		{
			region = new Region(0, 0, _tileWidth, _tileDepth);
			region.width = cachedGraphics.bitmap.width;
			region.height = cachedGraphics.bitmap.height;
		}
		else
		{
			var spriteRegion:TextureRegion = cast TileGraphic;
			region = spriteRegion.region.clone();
			if (region.tileWidth > 0)
			{
				_tileWidth = region.tileWidth;
			}
			else
			{
				region.tileWidth = _tileWidth;
			}

			if (region.tileHeight > 0)
			{
				_tileDepth = region.tileWidth;
			}
			else
			{
				region.tileHeight = _tileDepth;
			}
		}
		
		// Create some tile objects that we'll use for overlap checks (one for each tile)
		_tileObjects = new Array<FlxTileIso>();
		
		var length:Int = region.numTiles;
		length += _startingIndex;
		
		for (i in 0...length)
		{
			_tileObjects[i] = new FlxTileIso(this, i, _tileWidth, _tileDepth, _tileHeight, (i >= DrawIndex), (i >= CollideIndex) ? allowCollisions : FlxObject.NONE);
		}
		
		// Create debug tiles for rendering bounding boxes on demand
		#if (flash && !FLX_NO_DEBUG)
		_debugTileNotSolid = makeDebugTile(FlxColor.BLUE);
		_debugTilePartial = makeDebugTile(FlxColor.PINK);
		_debugTileSolid = makeDebugTile(FlxColor.GREEN);
		#end
		
		_scaledTileWidth = _tileWidth * scaleX;
		_scaledTileDepth = _tileDepth * scaleY;
		_scaledTileHeight = _tileHeight * scaleY;
		
		// Then go through and create the actual map
		width = widthInTiles * _scaledTileWidth;
		height = heightInTiles * _scaledTileDepth + _scaledTileHeight;
		
		#if flash
		#if !FLX_NO_DEBUG
		_debugRect = new Rectangle(0, 0, _tileWidth, _tileDepth);
		#end
		
		_rects = new Array<Rectangle>();
		FlxArrayUtil.setLength(_rects, totalTiles);
		
		i = 0;
		while (i < totalTiles)
		{
			updateTile(i++);
		}
		#else
		updateFrameData();
		#end
		
		return this;		
	}

	/**
	 * An internal function used by the binary auto-tilers.
	 * 
	 * NEED TEST
	 * 
	 * @param	Index		The index of the tile you want to analyze.
	 */
	private function autoTile(Index:Int):Void
	{
		if (_data[Index] == 0)
		{
			return;
		}
		
		_data[Index] = 0;
		
		// UP
		if ((Index-widthInTiles < 0) || (_data[Index-widthInTiles] > 0))
		{
			_data[Index] += 1;
		}
		// RIGHT
		if ((Index%widthInTiles >= widthInTiles-1) || (_data[Index+1] > 0))
		{
			_data[Index] += 2;
		}
		// DOWN
		if ((Std.int(Index+widthInTiles) >= totalTiles) || (_data[Index+widthInTiles] > 0)) 
		{
			_data[Index] += 4;
		}
		// LEFT
		if ((Index%widthInTiles <= 0) || (_data[Index-1] > 0))
		{
			_data[Index] += 8;
		}
		
		// The alternate algo checks for interior corners
		if ((auto == ALT) && (_data[Index] == 15))
		{
			// BOTTOM LEFT OPEN
			if ((Index%widthInTiles > 0) && (Std.int(Index+widthInTiles) < totalTiles) && (_data[Index+widthInTiles-1] <= 0))
			{
				_data[Index] = 1;
			}
			// TOP LEFT OPEN
			if ((Index%widthInTiles > 0) && (Index-widthInTiles >= 0) && (_data[Index-widthInTiles-1] <= 0))
			{
				_data[Index] = 2;
			}
			// TOP RIGHT OPEN
			if ((Index%widthInTiles < widthInTiles-1) && (Index-widthInTiles >= 0) && (_data[Index-widthInTiles+1] <= 0))
			{
				_data[Index] = 4;
			}
			// BOTTOM RIGHT OPEN
			if ((Index % widthInTiles < widthInTiles - 1) && (Std.int(Index + widthInTiles) < totalTiles) && (_data[Index + widthInTiles + 1] <= 0))
			{
				_data[Index] = 8;
			}
		}
		
		_data[Index] += 1;
	}
	
	/**
	 * Draws the tilemap buffers to the cameras.
	 */
	override public function draw():Void
	{
		if (cameras == null)
		{
			cameras = FlxG.cameras.list;
		}
		
		var camera:FlxCamera;
		var buffer:FlxTilemapBuffer;
		var i:Int = 0;
		var l:Int = cameras.length;
		
		while (i < l)
		{
			camera = cameras[i];
			
			if (!camera.visible || !camera.exists)
			{
				continue;
			}
			
			if (_buffers[i] == null)
			{
				_buffers[i] = new FlxTilemapBufferIso(_tileWidth, _tileDepth, widthInTiles, heightInTiles, camera, scaleX, scaleY);
				_buffers[i].forceComplexRender = forceComplexRender;
			}
			
			buffer = _buffers[i++];
			buffer.dirty = true;
			#if flash
			if (!buffer.dirty)
			{
				// Copied from getScreenXY()
				_point.x = x - (camera.scroll.x * scrollFactor.x) + buffer.x; 
				_point.y = y - (camera.scroll.y * scrollFactor.y) + buffer.y;
				buffer.dirty = (_point.x > 0) || (_point.y > 0) || (_point.x + buffer.width < camera.width) || (_point.y + buffer.height < camera.height);
			}
			
			if (buffer.dirty)
			{
				drawTilemap(buffer, camera);
				buffer.dirty = false;
			}
			
			// Copied from getScreenXY()
			_flashPoint.x = x - (camera.scroll.x * scrollFactor.x) + buffer.x; 
			_flashPoint.y = y - (camera.scroll.y * scrollFactor.y) + buffer.y;
			buffer.draw(camera, _flashPoint, scaleX, scaleY);
			#else
			drawTilemap(buffer, camera);
			#end
			
			#if !FLX_NO_DEBUG
			FlxBasic._VISIBLECOUNT++;
			#end
		}
	}

	/**
	 * Internal function that actually renders the tilemap to the tilemap buffer.  Called by draw().
	 * @param	Buffer		The <code>FlxTilemapBuffer</code> you are rendering to.
	 * @param	Camera		The related <code>FlxCamera</code>, mainly for scroll values.
	 */
	private function drawTilemap(Buffer:FlxTilemapBuffer, Camera:FlxCamera):Void
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
		var screenYInTiles:Int = Math.floor(_point.y / _scaledTileDepth);
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
			_flashPoint.y = row * (_scaledTileDepth / 2);
			
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
					drawX = _helperPoint.x + heightInTiles * _scaledTileWidth / 2 - (_scaledTileWidth / 2 * (row + 1)) + column * _scaledTileWidth / 2;
					drawY = _helperPoint.y + row * _scaledTileDepth / 2 + column * _scaledTileDepth / 2;
					
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
				_flashPoint.y += _scaledTileDepth / 2;
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
		Buffer.y = screenYInTiles * _scaledTileDepth;
	}	

	/**
	 * Find the index of the tile at given position.
	 * Result is -1 if the point is outside map.
	 * 
	 * @param	Point		A point in world coordinates.
	 * @return	An Int containing the index of the tile at this coordinate. -1 if no tile were found.
	 */
	public function getIndexFromPoint(Point:FlxPoint):Int
	{
		//Calculate corrected mouse position
		var x0 = Point.x - heightInTiles * _scaledTileWidth / 2 - x;
		var y0 = Point.y - y;

		//Calculate coordinates
		var row = Std.int(y0 / _scaledTileDepth - x0 / _scaledTileWidth);
		var col = Std.int(y0 / _scaledTileDepth + x0 / _scaledTileWidth);

		//Check if the coordinates are valid
		if (row < 0 || row >= heightInTiles || col < 0 || col >= widthInTiles)
			return -1;

		//Finally compute the index
		return row * widthInTiles + col;
	}
	
	/**
	 * Find a path through the tilemap.  Any tile with any collision flags set is treated as impassable.
	 * If no path is discovered then a null reference is returned.
	 * 
	 * @param	Start		The start point in world coordinates.
	 * @param	End			The end point in world coordinates.
	 * @param	Simplify	Whether to run a basic simplification algorithm over the path data, removing extra points that are on the same line.  Default value is true.
	 * @param	RaySimplify	Whether to run an extra raycasting simplification algorithm over the remaining path data.  This can result in some close corners being cut, and should be used with care if at all (yet).  Default value is false.
	 * @param   WideDiagonal   Whether to require an additional tile to make diagonal movement. Default value is true;
	 * @return	An Array of FlxPoints, containing all waypoints from the start to the end.  If no path could be found, then a null reference is returned.
	 */
	public function findPath(Start:FlxPoint, End:FlxPoint, Simplify:Bool = true, RaySimplify:Bool = false, WideDiagonal:Bool = true):Array<FlxPoint>
	{
		// Figure out what tile we are starting and ending on.
		var startIndex:Int = getIndexFromPoint(Start);
		var endIndex:Int = getIndexFromPoint(End);

		// Check that the start and end are clear.
		if (startIndex == -1 || endIndex == -1 || (_tileObjects[_data[startIndex]].allowCollisions > 0) || (_tileObjects[_data[endIndex]].allowCollisions > 0))
		{
			return null;
		}
		
		// Figure out how far each of the tiles is from the starting tile
		var distances:Array<Int> = computePathDistance(startIndex, endIndex, WideDiagonal);
		
		if (distances == null)
		{
			return null;
		}

		// Then count backward to find the shortest path.
		var points:Array<FlxPoint> = new Array<FlxPoint>();
		walkPath(distances, endIndex, points);
		
		// Reset the start and end points to be exact
		var node:FlxPoint;
		node = points[points.length-1];
		node.x = Start.x;
		node.y = Start.y;
		node = points[0];
		node.x = End.x;
		node.y = End.y;

		// Some simple path cleanup options
		if (Simplify)
		{
			simplifyPath(points);
		}
		if (RaySimplify)
		{
			raySimplifyPath(points);
		}
		
		// Finally load the remaining points into a new path object and return it
		var path:Array<FlxPoint> = [];
		var i:Int = points.length - 1;
		
		while (i >= 0)
		{
			node = points[i--];
			
			if (node != null)
			{
				path.push(node);
			}
		}
		
		return path;
	}

	/**
	 * Pathfinding helper function, recursively walks the grid and finds a shortest path back to the start.
	 * 
	 * @param	Data	A Flash <code>Array</code> of distance information.
	 * @param	Start	The tile we're on in our walk backward.
	 * @param	Points	A Flash <code>Array</code> of <code>FlxPoint</code> nodes composing the path from the start to the end, compiled in reverse order.
	 */
	private function walkPath(Data:Array<Int>, Start:Int, Points:Array<FlxPoint>):Void
	{
		//drawX = _helperPoint.x + heightInTiles * _scaledTileWidth / 2 - (_scaledTileWidth / 2 * (row + 1)) + column * _scaledTileWidth / 2;
		//drawY = _helperPoint.y + row * _scaledTileHeight / 2 + column * _scaledTileHeight / 2;
		Points.push(new FlxPoint(	x + _scaledTileWidth * 0.5 * (heightInTiles + Math.floor(Start % widthInTiles) - Math.floor(Start / widthInTiles)),
									y + _scaledTileDepth * 0.5 * (Math.floor(Start / widthInTiles) + Math.floor(Start % widthInTiles) + 1)));

		if (Data[Start] == 0)
		{
			return;
		}
		
		// Basic map bounds
		var left:Bool = (Start % widthInTiles) > 0;
		var right:Bool = (Start % widthInTiles) < (widthInTiles - 1);
		var up:Bool = (Start / widthInTiles) > 0;
		var down:Bool = (Start / widthInTiles) < (heightInTiles - 1);
		
		var current:Int = Data[Start];
		var i:Int;
		
		if (up)
		{
			i = Start - widthInTiles;
			
			if (i >= 0 && (Data[i] >= 0) && (Data[i] < current))
			{
				return walkPath(Data, i, Points);
			}
		}
		if (right)
		{
			i = Start + 1;
			
			if (i >= 0 && (Data[i] >= 0) && (Data[i] < current))
			{
				return walkPath(Data, i, Points);
			}
		}
		if (down)
		{
			i = Start + widthInTiles;
			
			if (i >= 0 && (Data[i] >= 0) && (Data[i] < current))
			{
				return walkPath(Data, i, Points);
			}
		}
		if (left)
		{
			i = Start - 1;
			
			if (i >= 0 && (Data[i] >= 0) && (Data[i] < current))
			{
				return walkPath(Data, i, Points);
			}
		}
		if (up && right)
		{
			i = Start - widthInTiles + 1;
			
			if (i >= 0 && (Data[i] >= 0) && (Data[i] < current))
			{
				return walkPath(Data, i, Points);
			}
		}
		if (right && down)
		{
			i = Start + widthInTiles + 1;
			
			if (i >= 0 && (Data[i] >= 0) && (Data[i] < current))
			{
				return walkPath(Data, i, Points);
			}
		}
		if (left && down)
		{
			i = Start + widthInTiles - 1;
			
			if (i >= 0 && (Data[i] >= 0) && (Data[i] < current))
			{
				return walkPath(Data, i, Points);
			}
		}
		if (up && left)
		{
			i = Start - widthInTiles - 1;
			
			if (i >= 0 && (Data[i] >= 0) && (Data[i] < current))
			{
				return walkPath(Data, i, Points);
			}
		}
		
		return;
	}

	/**
	 * Adjust collision settings and/or bind a callback function to a range of tiles.
	 * This callback function, if present, is triggered by calls to overlap() or overlapsWithCallback().
	 * 
	 * @param	Tile				The tile or tiles you want to adjust.
	 * @param	AllowCollisions		Modify the tile or tiles to only allow collisions from certain directions, use FlxObject constants NONE, ANY, LEFT, RIGHT, etc.  Default is "ANY".
	 * @param	Callback			The function to trigger, e.g. <code>lavaCallback(Tile:FlxTile, Object:FlxObject)</code>.
	 * @param	CallbackFilter		If you only want the callback to go off for certain classes or objects based on a certain class, set that class here.
	 * @param	Range				If you want this callback to work for a bunch of different tiles, input the range here.  Default value is 1.
	 */
	public function setTileProperties(Tile:Int, AllowCollisions:Int = 0x1111, ?Callback:FlxObject->FlxObject->Void, ?CallbackFilter:Class<Dynamic>, Range:Int = 1):Void
	{
		if (Range <= 0)
		{
			Range = 1;
		}
		
		var tile:FlxTileIso;
		var i:Int = Tile;
		var l:Int = Tile + Range;
		
		while (i < l)
		{
			tile = _tileObjects[i++];
			tile.allowCollisions = AllowCollisions;
			tile.callbackFunction = Callback;
			tile.filter = CallbackFilter;
		}
	}

	private function set_scaleX(Scale:Float):Float
	{
		Scale = Math.abs(Scale);
		scaleX = Scale;
		_scaledTileWidth = _tileWidth * Scale;
		width = widthInTiles * _scaledTileWidth;
		
		if (cameras != null)
		{
			var i:Int = 0;
			var l:Int = cameras.length;
			while (i < l)
			{
				if (_buffers[i] != null)
				{
					_buffers[i].updateColumns(_tileWidth, widthInTiles, Scale, cameras[i]);
				}
				i++;
			}
		}
		
		return Scale;
	}

	/**
	 * Pathfinding helper function, strips out extra points on the same line.
	 * 
	 * @param	Points		An array of <code>FlxPoint</code> nodes.
	 */
	private function simplifyPath(Points:Array<FlxPoint>):Void
	{
		var deltaPrevious:Float;
		var deltaNext:Float;
		var last:FlxPoint = Points[0];
		var node:FlxPoint;
		var i:Int = 1;
		var l:Int = Points.length - 1;
		
		while(i < l)
		{
			node = Points[i];
			deltaPrevious = (node.x - last.x)/(node.y - last.y);
			deltaNext = (node.x - Points[i + 1].x) / (node.y - Points[i + 1].y);
			
			if ((last.x == Points[i + 1].x) || (last.y == Points[i + 1].y) || (deltaPrevious == deltaNext))
			{
				Points[i] = null;
			}
			else
			{
				last = node;
			}
			
			i++;
		}
	}

	/**
	 * Pathfinding helper function, floods a grid with distance information until it finds the end point.
	 * NOTE: Currently this process does NOT use any kind of fancy heuristic! It's pretty brute.
	 * 
	 * NEED TEST for WideDiagonal
	 * 
	 * @param	StartIndex	The starting tile's map index.
	 * @param	EndIndex	The ending tile's map index.
	 * @param   WideDiagonal Whether to require an additional tile to make diagonal movement. Default value is true.
	 * @return	A Flash <code>Array</code> of <code>FlxPoint</code> nodes.  If the end tile could not be found, then a null <code>Array</code> is returned instead.
	 */
	private function computePathDistance(StartIndex:Int, EndIndex:Int, WideDiagonal:Bool):Array<Int>
	{
		// Create a distance-based representation of the tilemap.
		// All walls are flagged as -2, all open areas as -1.
		var mapSize:Int = widthInTiles * heightInTiles;
		var distances:Array<Int> = new Array<Int>(/*mapSize*/);
		FlxArrayUtil.setLength(distances, mapSize);
		var i:Int = 0;
		
		while(i < mapSize)
		{
			if (_tileObjects[_data[i]].allowCollisions != FlxObject.NONE)
			{
				distances[i] = -2;
			}
			else
			{
				distances[i] = -1;
			}
			i++;
		}
		
		distances[StartIndex] = 0;
		var distance:Int = 1;
		var neighbors:Array<Int> = [StartIndex];
		var current:Array<Int>;
		var currentIndex:Int;
		var left:Bool;
		var right:Bool;
		var up:Bool;
		var down:Bool;
		var currentLength:Int;
		var foundEnd:Bool = false;
		
		while(neighbors.length > 0)
		{
			current = neighbors;
			neighbors = new Array<Int>();
			
			i = 0;
			currentLength = current.length;
			while(i < currentLength)
			{
				currentIndex = current[i++];
				
				if(currentIndex == Std.int(EndIndex))
				{
					foundEnd = true;
					// Neighbors.length = 0;
					neighbors = [];
					break;
				}
				
				// Basic map bounds
				left = currentIndex % widthInTiles > 0;
				right = currentIndex % widthInTiles < widthInTiles - 1;
				up = currentIndex / widthInTiles > 0;
				down = currentIndex / widthInTiles < heightInTiles - 1;
				
				var index:Int;
				
				if (up)
				{
					index = currentIndex - widthInTiles;
					
					if (distances[index] == -1)
					{
						distances[index] = distance;
						neighbors.push(index);
					}
				}
				if (right)
				{
					index = currentIndex + 1;
					
					if (distances[index] == -1)
					{
						distances[index] = distance;
						neighbors.push(index);
					}
				}
				if (down)
				{
					index = currentIndex + widthInTiles;
					
					if (distances[index] == -1)
					{
						distances[index] = distance;
						neighbors.push(index);
					}
				}
				if (left)
				{
					index = currentIndex - 1;
					
					if (distances[index] == -1)
					{
						distances[index] = distance;
						neighbors.push(index);
					}
				}
				if (up && right)
				{
					index = currentIndex - widthInTiles + 1;
					
					if (WideDiagonal && (distances[index] == -1) && (distances[currentIndex-widthInTiles] >= -1) && (distances[currentIndex+1] >= -1))
					{
						distances[index] = distance;
						neighbors.push(index);
					}
					else if (!WideDiagonal && (distances[index] == -1))
					{
						distances[index] = distance;
						neighbors.push(index);
					}
				}
				if (right && down)
				{
					index = currentIndex + widthInTiles + 1;
					
					if (WideDiagonal && (distances[index] == -1) && (distances[currentIndex+widthInTiles] >= -1) && (distances[currentIndex+1] >= -1))
					{
						distances[index] = distance;
						neighbors.push(index);
					}
					else if (!WideDiagonal && (distances[index] == -1))
					{
						distances[index] = distance;
						neighbors.push(index);
					}
				}
				if (left && down)
				{
					index = currentIndex + widthInTiles - 1;
					
					if (WideDiagonal && (distances[index] == -1) && (distances[currentIndex+widthInTiles] >= -1) && (distances[currentIndex-1] >= -1))
					{
						distances[index] = distance;
						neighbors.push(index);
					}
					else if (!WideDiagonal && (distances[index] == -1))
					{
						distances[index] = distance;
						neighbors.push(index);
					}
				}
				if (up && left)
				{
					index = currentIndex - widthInTiles - 1;
					
					if (WideDiagonal && (distances[index] == -1) && (distances[currentIndex-widthInTiles] >= -1) && (distances[currentIndex-1] >= -1))
					{
						distances[index] = distance;
						neighbors.push(index);
					}
					else if (!WideDiagonal && (distances[index] == -1))
					{
						distances[index] = distance;
						neighbors.push(index);
					}
				}
			}
			
			distance++;
		}
		if (!foundEnd)
		{
			distances = null;
		}
		
		return distances;
	}

	/**
	 * Shoots a ray from the start point to the end point.
	 * If/when it passes through a tile, it stores that point and returns false.
	 * 
	 * NEED TEST
	 * 
	 * @param	Start		The world coordinates of the start of the ray.
	 * @param	End			The world coordinates of the end of the ray.
	 * @param	Result		A <code>Point</code> object containing the first wall impact.
	 * @param	Resolution	Defaults to 1, meaning check every tile or so.  Higher means more checks!
	 * @return	Returns true if the ray made it from Start to End without hitting anything.  Returns false and fills Result if a tile was hit.
	 */
	public function ray(Start:FlxPoint, End:FlxPoint, ?Result:FlxPoint, Resolution:Float = 1):Bool
	{
		var step:Float = _scaledTileWidth;
		
		if (_scaledTileDepth < _scaledTileWidth)
		{
			step = _scaledTileDepth;
		}
		
		step /= Resolution;
		var deltaX:Float = End.x - Start.x;
		var deltaY:Float = End.y - Start.y;
		var distance:Float = Math.sqrt(deltaX * deltaX + deltaY * deltaY);
		var steps:Int = Math.ceil(distance / step);
		var stepX:Float = deltaX / steps;
		var stepY:Float = deltaY / steps;
		var curX:Float = Start.x - stepX - x;
		var curY:Float = Start.y - stepY - y;
		var tileX:Int;
		var tileY:Int;
		var i:Int = 0;
		
		while (i < steps)
		{
			curX += stepX;
			curY += stepY;
			
			if ((curX < 0) || (curX > width) || (curY < 0) || (curY > height))
			{
				i++;
				continue;
			}
			
			tileX = Math.floor(curX / _scaledTileWidth);
			tileY = Math.floor(curY / _scaledTileDepth);
			
			if (_tileObjects[_data[tileY * widthInTiles + tileX]].allowCollisions != FlxObject.NONE)
			{
				// Some basic helper stuff
				tileX *= Std.int(_scaledTileWidth);
				tileY *= Std.int(_scaledTileDepth);
				var rx:Float = 0;
				var ry:Float = 0;
				var q:Float;
				var lx:Float = curX - stepX;
				var ly:Float = curY - stepY;
				
				// Figure out if it crosses the X boundary
				q = tileX;
				
				if (deltaX < 0)
				{
					q += _scaledTileWidth;
				}
				
				rx = q;
				ry = ly + stepY * ((q - lx) / stepX);
				
				if ((ry > tileY) && (ry < tileY + _scaledTileDepth))
				{
					if (Result != null)
					{
						Result.x = rx;
						Result.y = ry;
					}
					
					return false;
				}
				
				// Else, figure out if it crosses the Y boundary
				q = tileY;
				
				if (deltaY < 0)
				{
					q += _scaledTileDepth;
				}
				
				rx = lx + stepX * ((q - ly) / stepY);
				ry = q;
				
				if ((rx > tileX) && (rx < tileX + _scaledTileWidth))
				{
					if (Result != null)
					{
						Result.x = rx;
						Result.y = ry;
					}
					
					return false;
				}
				
				return true;
			}
			
			i++;
		}
		
		return true;
	}

	/**
	 * Pathfinding helper function, strips out even more points by raycasting from one point to the next and dropping unnecessary points.
	 * 
	 * @param	Points		An array of <code>FlxPoint</code> nodes.
	 */
	private function raySimplifyPath(Points:Array<FlxPoint>):Void
	{
		var source:FlxPoint = Points[0];
		var lastIndex:Int = -1;
		var node:FlxPoint;
		var i:Int = 1;
		var l:Int = Points.length;
		
		while(i < l)
		{
			node = Points[i++];
			
			if (node == null)
			{
				continue;
			}
			
			if (ray(source,node,_point))	
			{
				if (lastIndex >= 0)
				{
					Points[lastIndex] = null;
				}
			}
			else
			{
				source = Points[lastIndex];
			}
			
			lastIndex = i - 1;
		}
	}

	private function set_scaleY(Scale:Float):Float
	{
		Scale = Math.abs(Scale);
		scaleY = Scale;
		_scaledTileDepth = _tileDepth * Scale;
		_scaledTileHeight = _tileHeight * Scale;
		height = heightInTiles * _scaledTileDepth;
		
		if (cameras != null)
		{
			var i:Int = 0;
			var l:Int = cameras.length;
			while (i < l)
			{
				if (_buffers[i] != null)
				{
					_buffers[i].updateRows(_tileDepth, heightInTiles, Scale, cameras[i]);
				}
				i++;
			}
		}
		
		return Scale;
	}
}