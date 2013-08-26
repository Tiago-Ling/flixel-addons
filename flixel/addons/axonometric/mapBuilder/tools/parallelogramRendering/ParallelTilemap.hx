package flixel.addons.axonometric.mapBuilder.tools.parallelogramRendering;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;		
import flixel.FlxObject;
import flixel.util.FlxPoint;
import flixel.FlxCamera;
import flixel.util.FlxRect;
import flixel.FlxG;
import flixel.addons.axonometric.mapBuilder.tools.ParallelogramReference;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxColor;
import flixel.util.FlxArrayUtil;
import flixel.system.layer.DrawStackItem;
import flixel.util.loaders.TextureRegion;
import flixel.system.layer.Region;


/**
 * this is a normal FlxTilemap (@author Adam Atomic) object modified to render paralelograms
 *
 * @author	AS3 Original: Miguel Ángel Piedras Carrillo; 
 * 			Original Haxe 2.10 Port: Masadow
 * 			Second Haxe Port: Tiago Ling Alexandre
 */	
class ParallelTilemap extends FlxObject
{		
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
	 * Rendering helper, minimize new object instantiation on repetitive methods.
	 */
	private var _flashPoint:Point;
	
	/**
	 * Rendering helper, minimize new object instantiation on repetitive methods.
	 */
	private var _flashRect:Rectangle;
	
	/**
	 * Internal reference to the bitmap data object that stores the original tile graphics.
	 */
	public var _tiles:BitmapData;
	
	/**
	 * Internal reference to the bitmap data object that stores the skewed graphics.
	 */		
	public var parallelogramReference:ParallelogramReference;		
	
	/**
	 * Internal list of buffers, one for camera, used for drawing the tilemaps.
	 */
	private var _buffers:Array<ParallelTilemapBuffer>;

	/**
	 * Internal representation of the actual tile data, as a large 1D array of Integers.
	 */
	private var _data:Array<Int>;

	#if flash
	private var _rects:Array<Rectangle>;
	#end

	/**
	 * Internal, the width of a single tile.
	 */
	public var _tileWidth:Int;
	
	/**
	 * Internal, the height of a single tile.
	 */
	public var _tileHeight:Int;

	/**
	 * Internal, the location to draw tiles, differs if there is offset present
	 */
	public var _drawlocation:FlxPoint;
	
	private var _tileObjects:Array<ParallelTile>;
	
	/**
	 * X position of the center of the tilemap(different from x)
	 */
	public var X:Float;
	
	/**
	 * Y position of the center of the tilemap(different from y)
	 */
	public var Y:Float;

	/**
	 * Vector that tells the first corner of the map
	 */
	public var BigAxisA:Point;
	
	/**
	 * Vector that tells the second corner of the map
	 */
	public var BigAxisB:Point;
	
	/**
	 * Vector that tells the oposite corner of the generated map
	 */
	public var BigGenerated:Point;
			
	/**
	 * Corner of the mpa
	 */
	public var BigUpperLeft:Point;
	
	/**
	 * Corner of the mpa
	 */
	public var BigLowerRight:Point;
	
	/**
	 * Corner of the mpa
	 */
	public var BigUpperRight:Point;
	
	/**
	 * Corner of the mpa
	 */
	public var BigLowerLeft:Point;

	/**
	 * Widht of the map rectangle
	 */
	public var BigRectanglewidht:Float;
	
	/**
	 * Height of the map rectangle
	 */
	public var BigRectangleheight:Float;
	
	/*
	 * Debug mode variable
	 */ 		
	public var tilemapdebug:Bool;

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
	 * Internal, used to sort of insert blank tiles in front of the tiles in the provided graphic.
	 */
	private var _startingIndex:Int;

	/**
	 * Helper variable for non-flash targets. Adjust it's value if you'll see tilemap tearing (empty pixels between tiles). To something like 1.02 or 1.03
	 */
	public var tileScaleHack:Float = 1.01;
	 
	public function new()
	{
		super();
		widthInTiles = 0;
		heightInTiles = 0;
		totalTiles = 0;
		_buffers = new Array<ParallelTilemapBuffer>();
		_flashPoint = new Point();
		_flashRect = null;
		_data = null;
		_tileWidth = 0;
		_tileHeight = 0;
		#if flash
		_rects = null;
		#else
		_rectIDs = null;
		#end
		_tiles = null;
		_tileObjects = null;
		immovable = true;
		cameras = null;

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
		_tiles = null;
		
		var i:Int = 0;
		var l:Int = _tileObjects.length;
		while (i < l) 
		{
			_tileObjects[i++].destroy();
		}
		_tileObjects = null;
		i = 0;
		l = _buffers.length;
		while (i < l) 
		{

			_buffers[i++].destroy();
		}
		_buffers = null;
		_data = null;
		#if flash
		_rects = null;
		#else
		_helperPoint = null;
		_rectIDs = null;
		#end		

		super.destroy();
	}
	
	/**
	* sets the map in a specified location
	* 
	* @param	x		the x coordinate of the map
	* @param	y		the y coordinate of the map
	*/
	public function setLocation(x:Float, y:Float):Void 
	{									
		this.x = x + BigUpperLeft.x;			
		this.y = y + BigUpperLeft.y;
		this.X = x;
		this.Y = y;
	}
	
	/**
	 * Load the tilemap with string data and a tile graphic.
	 * 
	 * @param	MapData					A string of comma and line-return delineated indices indicating what order the tiles should go in.
	 * @param	parallelogramRef		instance of ParallelogramReference, used to avoid excesive object pooling
	 * 
	 * @return	A pointer this instance of ParallelTilemap
	 */
	public function loadMap(mapData:String, parallelogramRef:ParallelogramReference):ParallelTilemap
	{
		this.parallelogramReference = parallelogramRef;
		
		var positiveAngle:Bool = parallelogramRef.positiveAngle;
		var rotatetile:Bool = parallelogramRef.rotatetile;
		var inverttile:Bool = parallelogramRef.inverttile;
		var TileWidth:Int = parallelogramRef.a;
		var TileHeight:Int = parallelogramRef.b;			
		var DrawIndex:Int = 1;
		var CollideIndex:Int = 1;

		//Figure out the map dimensions based on the data string
		var columns:Array<Dynamic>;
		var rows:Array<Dynamic> = mapData.split("\n");
		heightInTiles = rows.length;
		_data = new Array<Int>();
		var row:Int = 0;
		var column:Int;
		while (row < heightInTiles)
		{
			columns = rows[row++].split(",");
			if (widthInTiles == 0) widthInTiles=columns.length;
			column = 0;
			while (column < widthInTiles)
			{
				_data.push(columns[column++]);
			}
		}
		
		if (rotatetile || inverttile || positiveAngle)
		{
			ModifyMapData(rotatetile, inverttile, positiveAngle);
		}

		var i:Int;
		totalTiles = widthInTiles * heightInTiles;
		
		//Figure out the size of the tiles
		_tiles = parallelogramRef._tiles;

		setCachedGraphics(FlxG.bitmap.add(_tiles));

		_tileWidth = TileWidth;
		if (_tileWidth == 0) 
		{
			_tileWidth = _cachedGraphics.bitmap.height;
		}
		_tileHeight = TileHeight;
		if (_tileHeight == 0)
		{
			_tileHeight = _tileWidth;
		}

		if (!Std.is(_tiles, TextureRegion))
		{
			_region = new Region(0, 0, _tileWidth, _tileHeight);
			_region.width = _cachedGraphics.bitmap.width;
			_region.height = _cachedGraphics.bitmap.height;
		}
		else
		{
			var spriteRegion:TextureRegion = cast _tiles;
			_region = spriteRegion.region.clone();
			if (_region.tileWidth > 0)
			{
				_tileWidth = _region.tileWidth;
			}
			else
			{
				_region.tileWidth = _tileWidth;
			}
			
			if (_region.tileHeight > 0)
			{
				_tileHeight = _region.tileWidth;
			}
			else
			{
				_region.tileHeight = _tileHeight;
			}
		}
		//create some tile objects that we'll use for overlap checks(one for tile)
		i = 0;
		var l:Int = Std.int((_tiles.width / _tileWidth) * (_tiles.height / _tileHeight));
			
		_tileObjects = new Array<ParallelTile>();
		var ac:Int;
		while(i < l)
		{
			_tileObjects[i] = new ParallelTile(this, i, parallelogramRef.Rectanglewidht - 5, parallelogramRef.Rectangleheight - 5,
				(i >= DrawIndex), (i >= CollideIndex) ? allowCollisions : FlxObject.NONE);
			i++;
		}			
		
		//Then go through and create the actual map
		setBigParalelogram(widthInTiles, heightInTiles, parallelogramRef);
		_drawlocation = new FlxPoint(-BigUpperLeft.x + parallelogramRef.UpperLeft.x, -BigUpperLeft.y + parallelogramRef.UpperLeft.y);
		width = BigRectanglewidht;
		height = BigRectangleheight;

		#if flash
		_rects = new Array<Rectangle>();
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
		
	public function ModifyMapData(rotatetile:Bool, inverttile:Bool, positiveAngle:Bool):Void 
	{
		var temp_data:Array<Int>;
		var tempval:Int;
		var row:Int = 0;
		var column:Int = 0;
		
		if (positiveAngle)
		{
			temp_data = new Array<Int>();
			while (row < heightInTiles) 
			{
				while (column < widthInTiles) 
				{
					temp_data.push(_data[row * widthInTiles + (widthInTiles - column - 1)]);
					column++;
				}
				column = 0;
				row++;
			}
			_data = null;
			_data = temp_data;
		}

		row = 0;
		column = 0;
		
		if (rotatetile) 
		{
			temp_data = new Array<Int>();
			while (column < widthInTiles) 
			{
				while (row < heightInTiles) 
				{
					temp_data.push(_data[(heightInTiles - row - 1) * widthInTiles + column]);
					row++;
				}
				row = 0;
				column++;
			}
			_data = null;
			_data = temp_data;				
			tempval = widthInTiles;
			widthInTiles = heightInTiles;
			heightInTiles = tempval;
			
			tempval = _tileWidth;
			_tileWidth = _tileHeight;
			_tileHeight = tempval;
		}			
	
		row = 0;
		column = 0;
		
		if (inverttile)
		{
			temp_data = new Array<Int>();
			while (row < heightInTiles) 
			{
				while (column < widthInTiles) 
				{
					temp_data.push(_data[(heightInTiles - row - 1) * widthInTiles + column]);
					column++;
				}
				column = 0;
				row++;
			}
			_data = null;
			_data = temp_data;				
		}
	
		row = 0;
		column = 0;

	}
			
	private function drawTilemap(Buffer:ParallelTilemapBuffer, Camera:FlxCamera):Void
	{
		//Same
		#if flash
		Buffer.fill();
		#else

		//Modification
		_helperPoint.x = x - Camera.scroll.x * scrollFactor.x; //copied from getScreenXY()
		_helperPoint.y = y - Camera.scroll.y * scrollFactor.y;
		//Original
		// _drawlocation.x = x - Camera.scroll.x * scrollFactor.x; //copied from getScreenXY()
		// _drawlocation.y = y - Camera.scroll.y * scrollFactor.y;

		var tileID:Int;
		var drawX:Float;
		var drawY:Float;

		#if !js
		var drawItem:DrawStackItem = Camera.getDrawStackItem(_cachedGraphics, false, 0);
		#else
		var drawItem:DrawStackItem = Camera.getDrawStackItem(_cachedGraphics, false);
		#end
		var currDrawData:Array<Float> = drawItem.drawData;
		var currIndex:Int = drawItem.position;
		#end

		//Copy tile images Into the tile buffer
		_point.x = Std.int(Camera.scroll.x * scrollFactor.x) - _drawlocation.x;//modified from getScreenXY()
		_point.y = Std.int(Camera.scroll.y * scrollFactor.y) - _drawlocation.y;

		var screenXInTiles:Int = Std.int(1.79769313486231e+308);
		var screenYInTiles:Int = Std.int(1.79769313486231e+308);
		var screenRows:Int = Buffer.rows;
		var screenColumns:Int = Buffer.columns;
		
		//Bound the upper left corner
		if (screenXInTiles < 0)
			screenXInTiles = 0;
		if (screenXInTiles > widthInTiles - screenColumns)
			screenXInTiles = widthInTiles - screenColumns;
		if (screenYInTiles < 0)
			screenYInTiles = 0;
		if (screenYInTiles > heightInTiles - screenRows)
			screenYInTiles = heightInTiles - screenRows;
		
		var rowIndex:Int = screenYInTiles * widthInTiles + screenXInTiles;
		_flashPoint.y = 0;
		var row:Int = 0;
		var column:Int;
		var columnIndex:Int;

		var tile:ParallelTile;
		var CurrPos:Point;
		var debugTile:BitmapData;

		var ref:FlxPoint;
		#if flash
		Buffer.pixels.lock();			
		DrawBigSiluette(Buffer.pixels);	
		#end
		var founddrawable:Bool = false;
		var cancel:Bool = false;

		while(row < screenRows)
		{
			if (founddrawable)
				cancel = true;

			columnIndex = rowIndex;
			column = 0;

			while(column < screenColumns)
			{
				#if flash
				_flashRect = _rects[columnIndex];

				if (_flashRect != null)
				{
					CurrPos = parallelogramReference.Get2dPos(row, column);
					_flashPoint.x =_drawlocation.x + CurrPos.x;
					_flashPoint.y =_drawlocation.y + CurrPos.y;
					ref = getScreenXY(new FlxPoint(_flashPoint.x, _flashPoint.y), Camera);
					
					if ((ref.x > 0 && ref.x < Camera.width) || (ref.y > 0 && ref.y < Camera.height)) {
						Buffer.pixels.copyPixels(parallelogramReference.ParalelogramTiles, _flashRect, _flashPoint, null, null, true);
						founddrawable = true;
						cancel = false;
					}
				}
				#else

				tileID = _rectIDs[columnIndex];
				
				if (tileID != -1)
				{
					//Original
					// drawX = _helperPoint.x + (columnIndex % widthInTiles) * _tileWidth;
					// drawY = _helperPoint.y + Math.floor(columnIndex / widthInTiles) * _tileHeight;

					//Modified
					CurrPos = parallelogramReference.Get2dPos(row,column);
					drawX = _helperPoint.x + CurrPos.x;
					drawY = _helperPoint.y + CurrPos.y;

					#if !js
					currDrawData[currIndex++] = drawX;
					currDrawData[currIndex++] = drawY;
					#else
					currDrawData[currIndex++] = Math.floor(drawX);
					currDrawData[currIndex++] = Math.floor(drawY);
					#end
					currDrawData[currIndex++] = tileID;
					
					// Tilemap tearing hack
					currDrawData[currIndex++] = tileScaleHack;
					currDrawData[currIndex++] = 0;
					currDrawData[currIndex++] = 0;
					// Tilemap tearing hack
					currDrawData[currIndex++] = tileScaleHack; 
					
					#if !js
					// Alpha
					currDrawData[currIndex++] = 1.0; 
					#end
				}
				#end

				columnIndex++;
				column++;
			}

			rowIndex += widthInTiles;
			row++;
			if (cancel)
				break;
		}
		
		#if flash
		Buffer.pixels.unlock();
		#end

		#if !flash
		drawItem.position = currIndex;
		#end

		//Modified with _drawLocation
		Buffer.x = screenXInTiles * _tileWidth - (_drawlocation.x - x);
		Buffer.y = screenYInTiles * _tileHeight - (_drawlocation.y - y);
	}
			
	private function Get2dPos(row:Float, column:Float, ref:ParallelogramReference):Point 
	{
		var c:Float = ref.a * column;
		var r:Float = ref.b * row;

		return  new Point(ref.axA.x * c + ref.axB.x * r, ref.axA.y * c + ref.axB.y * r);
	}
			
	/**
	 * Draws the tilemap buffers to the cameras and handles flickering.
	 */
	override public function draw():Void
	{
		if (cameras == null) 
		{
			cameras = FlxG.cameras.list;
		}

		var camera:FlxCamera;
		var buffer:ParallelTilemapBuffer;
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
				_buffers[i] = new ParallelTilemapBuffer(Std.int(parallelogramReference.Rectanglewidht - 5), Std.int(parallelogramReference.Rectangleheight - 5),
					widthInTiles, heightInTiles, camera, Std.int(BigRectanglewidht + 2), Std.int(BigRectangleheight + 2));

				_buffers[i].forceComplexRender = forceComplexRender;
			}

			buffer = _buffers[i++];

			#if flash
			if (!buffer.dirty)
			{
				_point = getScreenXY(new FlxPoint(X, Y), camera);
				buffer.dirty = (_point.x > 0 && _point.x < camera.width) || (_point.y > 0 && _point.y < camera.height);
				//Maybe this is a typo? Try to remove later
				if (!buffer.dirty) 
				{
					buffer.dirty;
				}
			}

			if (buffer.dirty)
			{
				drawTilemap(buffer, camera);
				buffer.dirty = false;
			}

			_flashPoint.x =_drawlocation.x - Std.int(camera.scroll.x * scrollFactor.x) + buffer.x;//copied from getScreenXY()
			_flashPoint.y =_drawlocation.y - Std.int(camera.scroll.y * scrollFactor.y) + buffer.y;

			_flashPoint.x += (_flashPoint.x > 0) ? 0.0000001 : -0.0000001;
			_flashPoint.y += (_flashPoint.y > 0) ? 0.0000001 : -0.0000001;

			buffer.draw(camera, _flashPoint);
			#else
			drawTilemap(buffer, camera);
			#end
		}
	}
	
	/**
	 * Set the dirty flag on all the tilemap buffers.
	 * Basically forces a reset of the drawn tilemaps, even if it wasn'tile necessary.
	 * 
	 * @param	Dirty		Whether to flag the tilemap buffers as dirty or not.
	 */
	public function setDirty(Dirty:Bool = true):Void
	{
		var i:Int = 0;
		var l:Int = _buffers.length;
		while (i < l)
		{
			_buffers[i++].dirty = Dirty;
		}
	}				
			
	private function updateTile(Index:Int):Void
	{
		/*									
			_data.push(uint(columns[column++]));
			_tileObjects   ----->Brush
		*/
		
		var tile:ParallelTile = _tileObjects[_data[Index]];

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
		var rx:Int = Std.int((_data[Index]) * parallelogramReference.Rectanglewidht);
		var ry:Int = 0;

		if (rx >= parallelogramReference.ParalelogramTiles.width)
		{
			ry = Std.int(rx / parallelogramReference.ParalelogramTiles.width * parallelogramReference.Rectangleheight);
			rx %= Std.int(parallelogramReference.Rectanglewidht);
		}
		_rects[Index] = (new Rectangle(rx, ry, parallelogramReference.Rectanglewidht - 5, 
			parallelogramReference.Rectangleheight - 5));
		#else
		_rectIDs[Index] = _framesData.frames[Std.int(_data[Index] - _startingIndex)].tileID;
		#end
	}
	
	/**
	 * Creates the axis of the tilemap
	 * 
	 * @param	amountA			amounnt of tiles on the axis A(columns)
	 * @param	amountB			amounnt of tiles on the axis B(rows)
	 */				
	public function setBigParalelogram(amountA:Float, amountB:Float, ref:ParallelogramReference):Void 
	{
		tilemapdebug = ref.tilemapdebug;	
		BigAxisA = new Point(ref.axA.x * (ref.a * amountA), ref.axA.y * (ref.a * amountA));
		BigAxisB = new Point(ref.axB.x * (ref.b * amountB), ref.axB.y * (ref.b * amountB));	
		BigGenerated = new Point(BigAxisA.x + BigAxisB.x, BigAxisA.y + BigAxisB.y);	
		BigUpperLeft = new Point(Math.min(Math.min(BigAxisA.x, BigAxisB.x), Math.min(BigGenerated.x, 0)),
									Math.min(Math.min(BigAxisA.y, BigAxisB.y), Math.min(BigGenerated.y, 0)));
		BigLowerRight = new Point(Math.max(Math.max(BigAxisA.x, BigAxisB.x), Math.max(BigGenerated.x, 0)),
									Math.max(Math.max(BigAxisA.y, BigAxisB.y), Math.max(BigGenerated.y, 0)));
		BigUpperRight = new Point(BigLowerRight.x , BigUpperLeft .y);
		BigLowerLeft = new Point(BigUpperLeft .x , BigLowerRight.y);
		BigRectanglewidht = BigUpperRight.x - BigUpperLeft.x;
		BigRectangleheight = BigLowerLeft.y  - BigUpperLeft.y;
	}

	/**
	 * debugging method
	 * 
	 * @param	pixels			la imagen en donde se va a pintar
	 */				
	public function DrawBigSiluette(pixels:BitmapData):Void 
	{
		var gfx:Graphics=FlxSpriteUtil.flashGfx;
		var cx:Float=0;
		var cy:Float=0;

		if(tilemapdebug){
			//white cross
			gfx.clear();
			gfx.lineStyle(1, FlxColor.WHITE, 0.5);
			gfx.moveTo(cx, cy);
			gfx.lineTo(cx + pixels.width, cy + pixels.height);			
			gfx.moveTo(cx + pixels.width, cy);						
			gfx.lineTo(cx, cy + pixels.height);
			pixels.draw(FlxSpriteUtil.flashGfxSprite);														
			
			//red cross
			gfx.clear();			
			gfx.lineStyle(1, FlxColor.RED, 0.5);
			gfx.moveTo(cx, cy);
			gfx.lineTo(cx + BigRectanglewidht, cy + BigRectangleheight);			
			gfx.moveTo(cx + BigRectanglewidht, cy);
			gfx.lineTo(cx, cy + BigRectangleheight);
			pixels.draw(FlxSpriteUtil.flashGfxSprite);

			//siluette
			gfx.clear();
			gfx.lineStyle(1, FlxColor.BLUE, 0.5);
			cx = -BigUpperLeft.x;
			cy = -BigUpperLeft.y;
			gfx.moveTo(cx, cy);
			gfx.lineTo(cx + BigAxisA.x, cy + BigAxisA.y);
			gfx.moveTo(cx, cy);			
			gfx.lineTo(cx + BigAxisB.x, cy + BigAxisB.y);
			gfx.moveTo(cx + BigAxisA.x, cy + BigAxisA.y);
			gfx.lineTo(cx + BigGenerated.x, cy + BigGenerated.y);
			gfx.moveTo(cx + BigAxisB.x, cy + BigAxisB.y);
			gfx.lineTo(cx + BigGenerated.x, cy + BigGenerated.y);
			pixels.draw(FlxSpriteUtil.flashGfxSprite);			
		}
	}

	/**
	 * Use this method for creating tileSheet for FlxTilemap. Must be called after loadMap() method.
	 * If you forget to call it then you will not see this FlxTilemap on c++ target
	 */
	override public function updateFrameData():Void
	{
		if (_cachedGraphics != null && _tileWidth >= 1 && _tileHeight >= 1)
		{
			_framesData = _cachedGraphics.tilesheet.getSpriteSheetFrames(_region, new Point(0, 0));
			#if !flash
			_rectIDs = new Array<Int>();
			FlxArrayUtil.setLength(_rectIDs, totalTiles);
			#end
			var i:Int = 0;
			
			while (i < totalTiles)
			{
				updateTile(i++);
			}
		}
	}

}